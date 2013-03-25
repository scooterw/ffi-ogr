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

    def add_geometry(geometry_type)
      geometry = FFIOGR.OGR_G_CreateGeometry(geometry_type)
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
