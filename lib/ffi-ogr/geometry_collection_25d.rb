module OGR
  class GeometryCollection25D < Geometry
    def self.create(geometries)
      geometry_collection = OGR::Tools.cast_geometry(FFIOGR.OGR_G_CreateGeometry(:geometry_collection_25d))

      if geometries.size > 0
        geometries.each do |geometry|
          geometry_collection.add_geometry(geometry)
        end
      end

      geometry_collection
    end
  end
end
