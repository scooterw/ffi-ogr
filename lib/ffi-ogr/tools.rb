module OGR
  module Tools
    class << self
      def cast_spatial_reference(sr_ptr, auto_free=true)
        raise RuntimeError.new("Spatial Reference pointer is NULL") if sr_ptr.null?
        SpatialReference.new sr_ptr
      end

      def cast_coordinate_transformation(ct_ptr, auto_free=true)
        raise RuntimeError.new("Coordinate Transformation pointer is NULL") if ct_ptr.null?
        CoordinateTransformation.new ct_ptr
      end

      def cast_data_source(ds_ptr, auto_free=true)
        raise RuntimeError.new("Data Source pointer is NULL") if ds_ptr.null?
        DataSource.new ds_ptr
      end

      def cast_layer(l_ptr, auto_free=true)
        raise RuntimeError.new("Layer pointer is NULL") if l_ptr.null?
        Layer.new l_ptr
      end

      def cast_feature(f_ptr, auto_free=true)
        raise RuntimeError.new("Feature pointer is NULL") if f_ptr.null?
        Feature.new f_ptr
      end

      def cast_geometry(geom_ptr, auto_free=true)
        #options = {auto_free: true}.merge(options)
        raise RuntimeError.new("Geometry pointer is NULL") if geom_ptr.null?

        geom_type = FFIOGR.OGR_G_GetGeometryType(geom_ptr)

        klass = case geom_type
        when :point
          OGR::Point
        when :line_string
          OGR::LineString
        when :polygon
          OGR::Polygon
        when :multi_point
          OGR::MultiPoint
        when :multi_line_string
          OGR::MultiLineString
        when :multi_polygon
          OGR::MultiPolygon
        when :geometry_collection
          OGR::GeometryCollection
        when :linear_ring
          OGR::LinearRing
        when :point_25d
          OGR::Point25D
        when :line_string_25d
          OGR::LineString25D
        when :polygon_25d
          OGR::Polygon25D
        when :multi_point_25d
          OGR::MultiPoint25D
        when :multi_line_string_25d
          OGR::MultiLineString25D
        when :multi_polygon_25d
          OGR::MultiPolygon25D
        when :geometry_collection_25d
          OGR::GeometryCollection25D
        end

        klass.new(geom_ptr)
      end
    end
  end
end
