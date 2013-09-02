module OGR
  class CSVWriter < Writer
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("CSV")
    end
  end
end
