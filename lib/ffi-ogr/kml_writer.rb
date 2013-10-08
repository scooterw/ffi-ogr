module OGR
  class KMLWriter < Writer
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("KML")
    end
  end
end

