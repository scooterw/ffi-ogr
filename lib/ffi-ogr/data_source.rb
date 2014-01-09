module OGR
  class DataSource
    include FFIOGR

    attr_accessor :ptr

    def initialize(ptr)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ptr.autorelease = false
    end

    def self.release(ptr);end

    def free
      FFIOGR.OGR_DS_Destroy(@ptr)
    end

    def copy(output_type, output_path, driver_options=nil)
      driver = OGRGetDriverByName(OGR::DRIVER_TYPES[output_type.downcase])
      new_ds = FFIOGR.OGR_Dr_CopyDataSource(driver, @ptr, File.expand_path(output_path), driver_options)
      FFIOGR.OGR_DS_Destroy(new_ds)
    end

    def copy_with_transform(output_type, output_path, spatial_ref=nil, driver_options=nil)
      writer = OGR::Writer.new(OGR::DRIVER_TYPES[output_type.downcase])
      writer.set_output(output_path)
      out = writer.ptr

      layers.each do |layer|
        name = layer.name
        geometry_type = layer.geometry_type
        old_sr = layer.spatial_ref

        ct = OGR::CoordinateTransformation.find_transformation(old_sr, spatial_ref) unless spatial_ref.nil? || (spatial_ref == old_sr)

        sr = spatial_ref.nil? ? nil : spatial_ref.ptr

        new_layer = out.add_layer name, geometry_type, sr, driver_options

        ptr = layer.ptr

        layer_definition = FFIOGR.OGR_L_GetLayerDefn(ptr)
        field_count = FFIOGR.OGR_FD_GetFieldCount(layer_definition)

        for i in (0...field_count)
          fd = FFIOGR.OGR_FD_GetFieldDefn(layer_definition, i)
          name = FFIOGR.OGR_Fld_GetNameRef(fd)
          type = FFIOGR.OGR_Fld_GetType(fd)

          opts = {}

          opts[:precision] = FFIOGR.OGR_Fld_GetPrecision(fd) if type == :real
          opts[:width] = FFIOGR.OGR_Fld_GetWidth(fd) if type == :string

          new_layer.add_field name, type
        end

        layer.features.each do |feature|
          geometry = OGR::Tools.cast_geometry(feature.geometry)
          geometry.transform ct if ct

          new_feature = new_layer.create_feature
          new_feature.add_geometry geometry

          ptr = feature.ptr
          field_count = FFIOGR.OGR_F_GetFieldCount(ptr)

          for i in (0...field_count)
            fd = FFIOGR.OGR_F_GetFieldDefnRef(ptr, i)
            field_name = FFIOGR.OGR_Fld_GetNameRef(fd)
            field_type = FFIOGR.OGR_Fld_GetType(fd)

            case field_type
            when :integer
              field_value = FFIOGR.OGR_F_GetFieldAsInteger(ptr, i)
            when :real
              field_value = FFIOGR.OGR_F_GetFieldAsDouble(ptr, i)
            else
              field_value = FFIOGR.OGR_F_GetFieldAsString(ptr, i)
            end

            new_feature.set_field_value field_name, field_value, field_type
          end

          new_layer.add_feature new_feature
        end

        new_layer.sync
      end
      out.free
    end

    def add_layer(name, geometry_type, spatial_ref=nil, options=nil)
      layer = FFIOGR.OGR_DS_CreateLayer(@ptr, name, spatial_ref, geometry_type.to_sym, options)
      OGR::Tools.cast_layer(layer)
    end

    def num_layers
      FFIOGR.OGR_DS_GetLayerCount(@ptr)
    end

    def get_layers
      layers = []

      for i in (0...num_layers) do
        layers << OGR::Tools.cast_layer(OGR_DS_GetLayer(@ptr, i))
      end

      layers
    end
    alias_method :layers, :get_layers

    def get_features
      layers.map {|l| l.features}
    end
    alias_method :features, :get_features

    def get_geometries(as_geojson=false)
      unless as_geojson
        features.map {|feature| feature.map {|f| OGR::Tools.cast_geometry(f.geometry)}}
      else
        features.map {|feature| feature.map {|f| OGR::Tools.cast_geometry(f.geometry).to_geojson}}
      end
    end
    alias_method :geometries, :get_geometries

    def get_fields
      features.map {|feature| feature.map {|f| f.fields}}
    end
    alias_method :fields, :get_fields

    def to_format(format, output_path, spatial_ref=nil)
      raise RuntimeError.new("Output path not specified.") if output_path.nil?

      # TODO: handle parsing of spatial_ref -> copy options

      unless spatial_ref
        copy format, output_path, spatial_ref
      else
        if spatial_ref[:spatial_ref].instance_of? OGR::SpatialReference
          copy_with_transform format, output_path, spatial_ref[:spatial_ref]
        else
          raise RuntimeError.new("Invalid spatial reference specified.")
        end
      end
    end

    def to_shp(output_path, spatial_ref=nil)
      to_format('shapefile', output_path, spatial_ref)
    end

    def to_csv(output_path, spatial_ref=nil)
      to_format('csv', output_path, spatial_ref)
    end

    def to_kml(output_path, spatial_ref=nil)
      warn "KML output will always be in EPSG:4326" unless spatial_ref.nil?
      to_format('kml', output_path, spatial_ref)
    end

    def to_geojson(output_path, options=nil)
      raise RuntimeError.new("Output path not specified.") if output_path.nil?

      unless options.nil?
        spatial_ref = options[:spatial_ref] ? options[:spatial_ref] : nil

        if options[:bbox]
          # this segfaults -- working on solution
          bbox = FFI::MemoryPointer.from_string "WRITE_BBOX=YES"
          driver_options = FFI::MemoryPointer.new :pointer, 1
          driver_options[0].put_pointer 0, bbox
        else
          driver_options = nil
        end

        if spatial_ref
          copy_with_transform('geojson', output_path, spatial_ref, driver_options)
        else
          copy('geojson', output_path, driver_options)
        end
      else
        copy('geojson', output_path, nil)
      end
    end

    def to_json(pretty=false)
      h = {
        type: 'FeatureCollection',
        bbox: nil,
        features: []
      }

      layers.each do |layer|
        h[:bbox] = layer.envelope.to_a true
        geometry_type = layer.geometry_type.to_s.capitalize

        layer.features.each do |feature|
          properties = feature.fields
          geometry = OGR::Tools.cast_geometry(feature.geometry).to_geojson
          h[:features] << {type: geometry_type, geometry: geometry, properties: properties}
        end
      end

      unless pretty
        MultiJson.dump(h)
      else
        MultiJson.dump(h, pretty: true)
      end
    end
  end
end
