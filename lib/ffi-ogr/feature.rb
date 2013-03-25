module OGR
  class Feature
    attr_accessor :ptr

    def initialize(ptr, auto_free=true)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ptr.autorelease = auto_free
    end

    def self.release(ptr)
      FFIOGR.OGR_F_Destroy(ptr)
    end

    def add_geometry(geometry_type, wkt_geometry=nil)
      geometry_type = geometry_type.to_sym
      geometry = nil

      if wkt_geometry
        if wkt_geometry.instance_of?(String)
          geometry = FFIOGR.OGR_G_CreateGeometry(geometry_type)
          FFIOGR.OGR_G_CreateFromWkt(wkt_geometry, nil, geometry, -1) # verify -1 acceptability
        end
      else
        case geometry_type
        when :point
          geometry = create_point(wkt_geometry)
        when :line_string
          geometry = create_line_string(wkt_geometry)
        when :polygon
          geometry = create_polygon(wkt_geometry)
        end
      end

      FFIOGR.OGR_F_SetGeometry(@ptr, geometry)
      FFIOGR.OGR_G_DestroyGeometry(geometry)
    end

    def create_point(geometry)
      x = Float(g[0])
      y = Float(g[1])
      z = Float(g[2]) if g.size == 3

      point = FFIOGR.OGR_G_CreateGeometry(:point)
      unless z
        FFIOGR.OGR_G_SetPoint_2D(point, 0, x, y)
      else
        FFIOGR.OGR_G_SetPoint(point, 0, x, y, z)
      end

      point
    end

    def create_line_string(geometry)
      ls = FFIOGR.OGR_G_CreateGeometry(:line_string)

      geometry.each_index do |i|
        g = geometry[i]
        x = Float(g[0])
        y = Float(g[1])
        z = Float(g[2]) if g.size == 3

        unless z
          FFIOGR.OGR_G_SetPoint_2D(ls, i, x, y)
        else
          FFIOGR.OGR_G_SetPoint(ls, i, x, y, z)
        end
      end

      ls
    end

    # MUST HANDLE POLYGONS WITH HOLES
    # MUST HANDLE MULTI* GEOMETRIES
    def create_polygon(geometry)
      FFIOGR.OGR_G_ForceToPolygon(create_line_string(geometry))
    end

    def set_field_value(name, value, field_type=nil)
      field_index = FFIOGR.OGR_F_GetFieldIndex(@ptr, name)

      unless field_type.nil?
        field_definition = FFIOGR.OGR_F_GetFieldDefnRef(@ptr, field_index)
        field_type = FFIOGR.OGR_Fld_GetType(field_definition)
      else
        field_type = field_type.to_sym
      end

      case field_type
      when :integer
        FFIOGR.OGR_F_SetFieldInteger(@ptr, field_index, Integer(value))
      when :real
        FFIOGR.OGR_F_SetFieldDouble(@ptr, field_index, Float(value))
      when :string
        FFIOGR.OGR_F_SetFieldString(@ptr, field_index, String(value))
      when :binary
        FFIOGR.OGR_F_SetFieldBinary(@ptr, field_index, value) # check this
      end
    end

    def get_geometry
      FFIOGR.OGR_F_GetGeometryRef(@ptr)
    end
    alias_method :geometry, :get_geometry

    def get_field_count
      FFIOGR.OGR_F_GetFieldCount(@ptr)
    end
    alias_method :field_count, :get_field_count

    def get_fields
      fields = {}

      for i in (0...field_count)
        fd = FFIOGR.OGR_F_GetFieldDefnRef(@ptr, i)
        field_name = FFIOGR.OGR_Fld_GetNameRef(fd)
        field_type = FFIOGR.OGR_Fld_GetType(fd)

        case field_type
        when :integer
          field_value = FFIOGR.OGR_F_GetFieldAsInteger(@ptr, i)
        when :real
          field_value = FFIOGR.OGR_F_GetFieldAsDouble(@ptr, i)
        else
          field_value = FFIOGR.OGR_F_GetFieldAsString(@ptr, i)
        end

        fields[field_name] = field_value
      end

      fields
    end
    alias_method :fields, :get_fields

    def to_geojson
      {type: 'Feature', geometry: OGR::Tools.cast_geometry(geometry).to_geojson, properties: fields}
    end
  end
end
