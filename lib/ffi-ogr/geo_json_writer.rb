module OGR
  class GeoJSONWriter < Writer
    include OGR::FFIOGR

    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("GeoJSON")
    end
  end
end
