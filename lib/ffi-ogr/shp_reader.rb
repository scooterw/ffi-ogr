module OGR
  class ShpReader
    include OGR::FFIOGR

    TF_MAP = {
      true => 1,
      false => 0,
      1 => true,
      0 => false
    }

    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("ESRI Shapefile")
    end

    def read(shp_path, writeable=false)
      ds = OGR_Dr_Open(@driver, File.expand_path(shp_path), TF_MAP[writeable])
      OGR::Tools.cast_data_source(ds)
    end
  end
end
