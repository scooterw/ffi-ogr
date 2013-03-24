module OGR
  module Tools
    class << self
      def cast_data_source(ds_ptr, options={})
        options = {auto_free: true}.merge(options)
        raise RuntimeError.new("Data Source pointer is NULL") if ds_ptr.null?
        DataSource.new ds_ptr, options[:auto_free]
      end

      def cast_feature(f_ptr, options={})
        options = {auto_free: true}.merge(options)
        raise RuntimeError.new("Feature pointer is NULL") if f_ptr.null?
        Feature.new f_ptr, options[:auto_free]
      end

      def cast_geometry(geom_ptr, options={})
        options = {auto_free: true}.merge(options)
        raise RuntimeError.new("Geometry pointer is NULL") if geom_ptr.null?

        geom_type = FFIOGR.OGR_G_GetGeometryType(geom_ptr)

        klass = case geom_type
        when :wkb_point
          OGR::Point
        when :wkb_line_string
          OGR::LineString
        when :wkb_polygon
          OGR::Polygon
        when :wkb_multi_point
          OGR::MultiPoint
        when :wkb_multi_line_string
          OGR::MultiLineString
        when :wkb_multi_polygon
          OGR::MultiPolygon
        end

        klass.new(geom_ptr, options[:auto_free])
      end
    end
  end
end
