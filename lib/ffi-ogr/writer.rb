module OGR
  class Writer
    include OGR::FFIOGR

    attr_accessor :ds

    def initialize;end

    def set_output(path, options={})
      path = File.expand_path(path)
      ds = OGR_Dr_CreateDataSource(@driver, path, nil)
      @ds = OGR::Tools.cast_data_source(ds)
      @ds
    end

    def self.create_from_file_type(path)
      path = File.expand_path(path)

      unless File.exists? path
        if path =~ /.shp/
          writer = ShpWriter.new
        elsif path =~ /.geojson|.json/
          writer = GeoJSONWriter.new
        end

        writer.set_output(path)
        writer
      else
        raise RuntimeError.new("Path already exists: #{path}")
      end
    end

    def export(output_path)
      writer = Writer.create_from_file_type output_path
      data_source = writer.ds

      # @ds -> data_source
    end
  end
end
