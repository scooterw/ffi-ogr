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

    def copy(driver_name, output_path, driver_options=nil)
      driver = OGRGetDriverByName driver_name
      new_ds = FFIOGR.OGR_Dr_CopyDataSource(driver, @ptr, File.expand_path(output_path), driver_options)
      FFIOGR.OGR_DS_Destroy(new_ds)
    end

    def copy_with_transform(driver_name, output_path, spatial_ref=nil, driver_options=nil)
      writer = OGR::Writer.new driver_name
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

          opts = {}.tap do |o|
            case type
            when :real
              o[:precision] = FFIOGR.OGR_Fld_GetPrecision fd
            when :string
              o[:width] = FFIOGR.OGR_Fld_GetWidth fd
            end
          end

          new_layer.add_field name, type, opts
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

    def to_format(format, output_path, options={})
      raise RuntimeError.new("Output path not specified.") if output_path.nil?

      spatial_ref = options.delete :spatial_ref

      driver_options = parse_driver_options options

      driver_name = OGR::DRIVER_TYPES[format]

      unless spatial_ref
        copy driver_name, output_path, driver_options
      else
        if spatial_ref.instance_of? OGR::SpatialReference
          copy_with_transform driver_name, output_path, spatial_ref, driver_options
        else
          raise RuntimeError.new("Invalid spatial reference specified.")
        end
      end
    end

    def to_shp(output_path, options={})
      to_format('shapefile', output_path, options)
    end

    def to_csv(output_path, options={})
      to_format('csv', output_path, options)
    end

    def to_kml(output_path, options={})
      format = OGR.drivers.include?('LIBKML') ? 'kml' : 'kml_lite'

      warn "GDAL is compiled without LIBKML support. Without LIBKML support KML output will always be in EPSG:4326" if format == 'kml_lite'

      to_format(format, output_path, options)
    end

    def to_geojson(output_path, options={})
      to_format('geojson', output_path, options)
    end

    def parse_driver_options(options)
      tf_values = {
        true => "YES",
        false => "NO"
      }

      pointers = [].tap do |ptrs|
        options.each do |k,v|
          tf_value = tf_values[v] || v
          ptrs << FFI::MemoryPointer.from_string("#{k.to_s.upcase}=#{tf_value.upcase}")
        end
      end

      pointers << nil

      driver_options = FFI::MemoryPointer.new :pointer, pointers.size

      pointers.each_with_index do |ptr, i|
        driver_options[i].put_pointer 0, ptr
      end

      driver_options
    end

    def to_json(pretty=false)
      h = {
        type: 'FeatureCollection',
        features: []
      }

      layers.each do |layer|
        h[:features].tap do |features|
          layer.features.each do |feature|
            features << {
              type: 'Feature',
              geometry: OGR::Tools.cast_geometry(feature.geometry).to_geojson,
              properties: feature.fields
            }
          end
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

