module OGR
  class ShpReader < Reader
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("ESRI Shapefile")
    end
  end
end
