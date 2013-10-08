module OGR
  class Reader
    include OGR::FFIOGR

    TF_MAP = {
      true => 1,
      false => 0,
      1 => true,
      0 => false
    }

    # Reader Class NOT to be used directly
    # Use subclasses e.g. ShpReader
    def initialize;end

    def self.from_file_type(path)
      path = File.expand_path(path)

      if path =~ /.shp/
        ShpReader.new
      elsif path =~ /.geojson|.json/
        GeoJSONReader.new
      elsif path =~ /.kml/
        KMLReader.new
      else
        raise RuntimeError.new("Could not determine appropriate reader for this file type")
      end
    end

    def read(file_path, writeable=false)
      ds = OGR_Dr_Open(@driver, File.expand_path(file_path), TF_MAP[writeable])
      OGR::Tools.cast_data_source(ds)
    end
  end
end
