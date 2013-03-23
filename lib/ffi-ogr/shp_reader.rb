module OGR
  class ShpReader
    include OGR::FFIOGR

    TF_MAP = {
      true => 1,
      false => 0
    }

    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriver(0)
    end

    def read(shp_path, write=false)
      OGR_Dr_Open(@driver, shp_path, TF_MAP[write])
    end
  end
end
