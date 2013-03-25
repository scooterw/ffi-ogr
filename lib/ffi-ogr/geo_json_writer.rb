module OGR
  class GeoJSONWriter < Writer
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("GeoJSON")
    end
  end
end
