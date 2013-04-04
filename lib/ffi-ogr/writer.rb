module OGR
  class Writer
    include OGR::FFIOGR

    attr_accessor :ptr

    def initialize;end

    def set_output(path, options={})
      path = File.expand_path(path)
      ds = OGR_Dr_CreateDataSource(@driver, path, nil)
      @ptr = OGR::Tools.cast_data_source(ds)
      @ptr
    end

    def self.from_file_type(path)
      path = File.expand_path(path)

      unless File.exists? path
        if path =~ /.shp/
          writer = ShpWriter.new
        elsif path =~ /.geojson|.json/
          writer = GeoJSONWriter.new
        else
          raise RuntimeError.new("Could not determine appropriate writer for this file type")
        end

        writer.set_output(path)
        writer
      else
        raise RuntimeError.new("Path already exists: #{path}")
      end
    end

    def export(output_path)
      writer = Writer.from_file_type output_path
      data_source = writer.ds

      # @ptr -> data_source
    end
  end
end
