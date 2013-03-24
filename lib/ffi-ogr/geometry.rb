module OGR
  class Geometry
    attr_reader :ptr

    def initialize(ptr, auto_free=true)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ptr.autorelease = auto_free
    end

    def self.release(ptr)
      FFIOGR.OGR_G_DestroyGeometry(ptr)
    end

    def geom_type
      FFIOGR.OGR_G_GetGeometryType(@ptr)
    end

    def to_geojson
      MultiJson.load(FFIOGR.OGR_G_ExportToJson(@ptr))
    end

    def to_kml
      FFIOGR.OGR_G_ExportToKML(@ptr)
    end
  end
end
