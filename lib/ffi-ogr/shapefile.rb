module OGR
  class Shapefile
    include FFIOGR

    def initialize(ptr, auto_free=true)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ptr.autorelease = auto_free
    end

    def self.release(ptr)
      FFIOGR.OGR_DS_Destroy(ptr)
    end

    def to_geojson(pretty=false)
      features = []

      num_layers = OGR_DS_GetLayerCount(@ptr)

      for i in (0...num_layers) do
        h_layer = OGR_DS_GetLayer(@ptr, i)
        OGR_L_ResetReading(h_layer)

        num_features = OGR_L_GetFeatureCount(h_layer, 0)

        for j in (0...num_features) do
          h_feature = OGR_L_GetNextFeature(h_layer)

          unless h_feature.null?
            properties = {}

            field_defn = OGR_L_GetLayerDefn(h_layer)
            num_fields = OGR_FD_GetFieldCount(field_defn)

            for k in (0...num_fields) do
              fd = OGR_FD_GetFieldDefn(field_defn, k)

              field_name = OGR_Fld_GetNameRef(fd)

              field_type = OGR_Fld_GetType(fd)

              case field_type
              when :integer
                field_value = OGR_F_GetFieldAsInteger(h_feature, k)
              when :real
                field_value = OGR_F_GetFieldAsDouble(h_feature, k)
              else
                field_value = OGR_F_GetFieldAsString(h_feature, k)
              end

              properties[field_name] = field_value
            end

            h_geometry = OGR_F_GetGeometryRef(h_feature)
            geometry = MultiJson.load(OGR_G_ExportToJson(h_geometry))

            feature = {
              type: 'Feature',
              geometry: geometry,
              properties: properties
            }

            features << feature
          end

          OGR_F_Destroy(h_feature)
        end
      end

      MultiJson.dump({type: 'FeatureCollection', features: features}, pretty: pretty)
    end
  end
end
