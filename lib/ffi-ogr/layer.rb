module OGR
  class Layer
    attr_accessor :ptr, :name, :geometry_type

    def initialize(ptr)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      #@ptr = FFI::AutoPointer.new(ptr)
      @ptr.autorelease = false
    end

    def self.release(ptr);end

    def free
      @ptr.free
    end

    def sync
      FFIOGR.OGR_L_SyncToDisk(@ptr)
    end

    def get_envelope
      envelope = FFI::MemoryPointer.new :pointer, 4
      FFIOGR.OGR_L_GetExtent(@ptr, envelope, 0)
      OGR::Envelope.new(envelope.read_array_of_double(4))
    end
    alias_method :envelope, :get_envelope

    def get_name
      FFIOGR.OGR_L_GetName(@ptr)
    end
    alias_method :name, :get_name

    def get_geometry_type
      FFIOGR.OGR_L_GetGeomType(@ptr)
    end
    alias_method :geometry_type, :get_geometry_type

    def get_spatial_ref
      OGR::Tools.cast_spatial_reference(FFIOGR.OGR_L_GetSpatialRef(@ptr))
    end
    alias_method :spatial_ref, :get_spatial_ref

    def add_field(name, field_type, options={})
      type = field_type.to_sym
      precision = options[:precision] || 1
      width = options[:width] || 32

      field = FFIOGR.OGR_Fld_Create(name, field_type.to_sym)

      if type == :real
        FFIOGR.OGR_Fld_SetPrecision(field, precision)
      else
        FFIOGR.OGR_Fld_SetWidth(field, width)
      end

      FFIOGR.OGR_L_CreateField(@ptr, field, 1)
      FFIOGR.OGR_Fld_Destroy(field)
    end

    def create_feature
      feature = FFIOGR.OGR_F_Create(FFIOGR.OGR_L_GetLayerDefn(@ptr))
      OGR::Tools.cast_feature(feature)
    end

    def add_feature(feature)
      FFIOGR.OGR_L_CreateFeature(@ptr, feature.ptr)
    end

    def get_features
      features = []

      FFIOGR.OGR_L_ResetReading(@ptr)
      num_features = FFIOGR.OGR_L_GetFeatureCount(@ptr, 0)

      for i in (0...num_features) do
        features << OGR::Tools.cast_feature(FFIOGR.OGR_L_GetNextFeature(@ptr))
      end

      features
    end
    alias_method :features, :get_features
  end
end
