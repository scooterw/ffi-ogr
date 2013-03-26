module OGR
  class Point25D < Geometry
    def self.create(coords)
      point = OGR::Tools.cast_geometry(FFIOGR.OGR_G_CreateGeometry(:point_25d))
      point.add_point(coords)
      point
    end
  end
end
