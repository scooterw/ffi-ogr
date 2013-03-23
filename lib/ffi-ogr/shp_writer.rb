module OGR
  class ShpWriter
    include OGR::FFIOGR

    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("ESRI Shapefile")
    end

    def write;end
  end
end
