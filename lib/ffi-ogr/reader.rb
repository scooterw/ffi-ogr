module OGR
  class Reader
    include OGR::FFIOGR

    attr_accessor :type

    TF_MAP = {
      true => 1,
      false => 0,
      1 => true,
      0 => false
    }

    def initialize(driver_name)
      OGRRegisterAll()
      @driver = OGRGetDriverByName(driver_name)
      raise RuntimeError.new "Invalid driver name" if @driver.null?
      @type = driver_name
    end

    def read(file_path, writeable=false)
      ds = OGR_Dr_Open(@driver, File.expand_path(file_path), TF_MAP[writeable])
      OGR::Tools.cast_data_source(ds)
    end
  end
end

