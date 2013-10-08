module OGR
  class KMLReader < Reader
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("KML")
    end
  end
end

