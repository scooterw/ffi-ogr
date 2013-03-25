module OGR
  class GenericWriter < Writer
    def initialize(driver_name)
      OGRRegisterAll()
      @driver = OGRGetDriverByName(driver_name)
      raise RuntimeError.new("Invalid driver name") if @driver.null?
    end
  end
end
