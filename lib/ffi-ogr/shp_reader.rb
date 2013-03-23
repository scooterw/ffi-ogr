module OGR
  class ShpReader
    include OGR::FFIOGR

    TF_MAP = {
      true => 1,
      false => 0
    }

    def initialize(*args)
      OGRRegisterAll() if OGRGetDriverCount() == 0
      @driver = OGRGetDriver(0)
    end

    def read(shp_path, writeable=false)
      OGR_Dr_Open(@driver, File.expand_path(shp_path), TF_MAP[writeable])
    end

    def self.test(shp)
      h_layer = OGR::FFIOGR.OGR_DS_GetLayer(shp, 0)
      OGR::FFIOGR.OGR_L_ResetReading(h_layer)

      # 0 == false; does not force long scan count
      feature_count = OGR::FFIOGR.OGR_L_GetFeatureCount(h_layer, 0)

      for n in (0...feature_count) do
        h_feature = OGR::FFIOGR.OGR_L_GetNextFeature(h_layer)

        if h_feature.address != 0
          field_defn = OGR::FFIOGR.OGR_L_GetLayerDefn(h_layer)
          field_count = OGR::FFIOGR.OGR_FD_GetFieldCount(field_defn)

          for i in (0...field_count) do
            fd = OGR::FFIOGR.OGR_FD_GetFieldDefn(field_defn, i)
            field_type = OGR::FFIOGR.OGR_Fld_GetType(fd)

            field_name = OGR::FFIOGR.OGR_Fld_GetNameRef(fd)

            case field_type
            when :integer
              field_value = OGR::FFIOGR.OGR_F_GetFieldAsInteger(h_feature, i)
            when :real
              field_value = OGR::FFIOGR.OGR_F_GetFieldAsDouble(h_feature, i)
            when :string
              field_value = OGR::FFIOGR.OGR_F_GetFieldAsString(h_feature, i)
            else
              field_value = OGR::FFIOGR.OGR_F_GetFieldAsString(h_feature, i)
            end

            p "#{field_name}: #{field_value}"
          end
        end
      end
    end
  end
end
