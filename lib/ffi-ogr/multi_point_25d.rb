module OGR
  class MultiPoint25D < Geometry
    def self.create(points)
      multi_point = OGR::Tools.cast_geometry(FFIOGR.OGR_G_CreateGeometry(:multi_point_25d))

      points.each do |point|
        pt = OGR::Point.create(point)
        multi_point.add_geometry(pt)
      end

      multi_point
    end
  end
end
