module OGR
  class LinearRing < Geometry
    def self.create(points)
      points << points.first unless points.first == points.last

      lr = OGR::Tools.cast_geometry(FFIOGR.OGR_G_CreateGeometry(:linear_ring))

      points.each do |point|
        lr.add_point(point)
      end

      lr
    end
  end
end
