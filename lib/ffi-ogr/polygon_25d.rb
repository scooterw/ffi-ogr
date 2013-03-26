module OGR
  class Polygon25D < Geometry
    def self.create(rings)
      polygon = OGR::Tools.cast_geometry(FFIOGR.OGR_G_CreateGeometry(:polygon_25d))

      rings.each do |ring|
        lr = LinearRing.create(ring)
        polygon.add_geometry(lr)
      end

      polygon
    end
  end
end
