module OGR
  class MultiLineString25D < Geometry
    def self.create(line_strings)
      multi_line_string = OGR::Tools.cast_geometry(FFIOGR.OGR_G_CreateGeometry(:multi_line_string_25d))

      line_strings.each do |line_string|
        ls = OGR::LineString.create(line_string)
        multi_line_string.add_geometry(ls)
      end

      multi_line_string
    end
  end
end
