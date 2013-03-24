module OGR
  module Tools
    class << self
      def cast_shapefile(shp_ptr, options={})
        options = {auto_free: true}.merge(options)
        raise RuntimeError.new("SHP pointer is NULL") if shp_ptr.null?
        Shapefile.new shp_ptr, options[:auto_free]
      end
    end
  end
end
