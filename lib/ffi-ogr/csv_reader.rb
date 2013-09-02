module OGR
  class CSVReader < Reader
    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("CSV")
    end
  end
end
