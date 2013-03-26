module OGR
  class Point < Geometry
    def self.create(coords)
      point = OGR::Tools.cast_geometry(FFIOGR.OGR_G_CreateGeometry(:point))
      point.add_point(coords)
      point
    end

    def get_x
      FFIOGR.OGR_G_GetX(@ptr, 0)
    end
    alias_method :x, :get_x

    def get_y
      FFIOGR.OGR_G_GetY(@ptr, 0)
    end
    alias_method :y, :get_y

    def get_z
      FFIOGR.OGR_G_GetZ(@ptr, 0)
    end
    alias_method :z, :get_z
  end
end
