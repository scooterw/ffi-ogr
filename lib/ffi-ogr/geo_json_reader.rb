module OGR
  class GeoJSONReader < Reader
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("GeoJSON")
    end
  end
end
