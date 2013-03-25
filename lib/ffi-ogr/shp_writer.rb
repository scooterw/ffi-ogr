module OGR
  class ShpWriter < Writer
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("ESRI Shapefile")
    end
  end
end
