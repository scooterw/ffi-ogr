module OGR
  class Feature
    attr_accessor :ptr

    def initialize(ptr)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      #@ptr = FFI::AutoPointer.new(ptr)
      @ptr.autorelease = false
    end

    def self.release(ptr);end

    def free
      FFIOGR.OGR_F_Destroy(@ptr)
    end

    def set_field_value(name, value, field_type=nil)
      field_index = FFIOGR.OGR_F_GetFieldIndex(@ptr, name)

      unless field_type.nil?
        field_type = field_type.to_sym
      else
        field_definition = FFIOGR.OGR_F_GetFieldDefnRef(@ptr, field_index)
        field_type = FFIOGR.OGR_Fld_GetType(field_definition)
      end

      case field_type
      when :integer
        FFIOGR.OGR_F_SetFieldInteger(@ptr, field_index, Integer(value))
      when :real
        #dbl_ptr = FFI::MemoryPointer.new(:double, 1)
        #dbl_ptr.write_double(Float(value))

        FFIOGR.OGR_F_SetFieldDouble(@ptr, field_index, value)
      when :string
        FFIOGR.OGR_F_SetFieldString(@ptr, field_index, String(value))
      when :binary
        FFIOGR.OGR_F_SetFieldBinary(@ptr, field_index, to_binary(value))
      end
    end

    def add_geometry(geometry)
      #FFIOGR.OGR_F_SetGeometry(@ptr, geometry.ptr)
      FFIOGR.OGR_F_SetGeometryDirectly(@ptr, geometry.ptr)
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

    def transform_to(out_sr)
      geom = OGR::Tools.cast_geometry(geometry)
      geom.transform(out_sr)
      p geom.ptr
      add_geometry(geom)
    end

    def to_geojson
      {type: 'Feature', geometry: OGR::Tools.cast_geometry(geometry).to_geojson, properties: fields}
    end
  end
end
