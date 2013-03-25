module OGR
  class ShpWriter
    include OGR::FFIOGR

    def initialize
      OGRRegisterAll()
      @driver = OGRGetDriverByName("ESRI Shapefile")
    end

    def set_output(shp_path=nil, options={})
      unless shp_path.nil?
        shp_path = File.expand_path(shp_path)
      else
        shp_path = "shp_out.shp"
      end

      ds = OGR_Dr_CreateDataSource(@driver, shp_path, nil)
      @ds = OGR::Tools.cast_data_source(ds)
      @ds
    end

    def get_output
      @ds
    end
    alias_method :output, :get_output

    def write(ds, output_path)
      set_output output_path

      ds.layers.each do |layer|
        name = OGR_L_GetName(layer)
        geometry_type = OGR_L_GetGeometryType(layer)
        new_layer = @ds.add_layer(name, geometry_type)

      end
    end
  end
end
