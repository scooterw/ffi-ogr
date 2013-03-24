module OGR
  class Point < Geometry
    # Point
    def get_x
      FFIOGR.OGR_G_GetX(@ptr)
    end
    alias_method :x, :get_x

    def get_y
      FFIOGR.OGR_G_GetY(@ptr)
    end
    alias_method :y, :get_y

    def get_z
      FFIOGR.OGR_G_GetZ(@ptr)
    end
    alias_method :z, :get_z
  end
end
