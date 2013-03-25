module OGR
  class Geometry
    attr_reader :ptr

    def initialize(ptr, auto_free=true)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      #@ptr.autorelease = auto_free
    end

    def self.release(ptr);end

    def flatten
      FFIOGR.OGR_G_FlattenTo2D(@ptr)
    end

    def geom_type
      FFIOGR.OGR_G_GetGeometryType(@ptr)
    end

    def get_length
      FFIOGR.OGR_G_Length(@ptr)
    end
    alias_method :length, :get_length

    def get_area
      FFIOGR.OGR_G_Area(@ptr)
    end
    alias_method :area, :get_area

    def get_boundary
      FFIOGR.OGR_G_Boundary(@ptr)
    end
    alias_method :boundary, :get_boundary

    def to_geojson
      MultiJson.load(FFIOGR.OGR_G_ExportToJson(@ptr))
    end

    def to_kml(elevation=nil)
      elevation = String(elevation) unless elevation.nil?
      FFIOGR.OGR_G_ExportToKML(@ptr, elevation)
    end

    def to_gml
      FFIOGR.OGR_G_ExportToGML(@ptr)
    end
  end
end
