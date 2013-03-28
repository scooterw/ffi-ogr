module OGR
  class Layer
    attr_accessor :ptr, :name, :geometry_type

    def initialize(ptr, auto_free=true)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @name = FFIOGR.OGR_L_GetName(@ptr)
      @geometry_type = FFIOGR.OGR_L_GetGeomType(@ptr)
      #@ptr.autorelease = auto_free
    end

    def self.release(ptr);end

    def sync
      FFIOGR.OGR_L_SyncToDisk(@ptr)
    end

    def add_field(name, field_type, field_width=32)
      field = FFIOGR.OGR_Fld_Create(name, field_type.to_sym)
      FFIOGR.OGR_Fld_SetWidth(field, field_width)
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
