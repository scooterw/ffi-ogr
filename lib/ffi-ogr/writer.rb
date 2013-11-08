module OGR
  class Writer
    include OGR::FFIOGR

    attr_accessor :ptr, :type

    def initialize(driver_name)
      OGRRegisterAll()
      @driver = OGRGetDriverByName(driver_name)
      raise RuntimeError.new "Invalid driver name" if @driver.null?
      @type = driver_name
    end

    def set_output(path, options={})
      path = File.expand_path(path)
      ds = OGR_Dr_CreateDataSource(@driver, path, nil)
      @ptr = OGR::Tools.cast_data_source(ds)
      @ptr
    end
  end
end

