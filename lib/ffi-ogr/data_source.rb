module OGR
  class DataSource
    include FFIOGR

    attr_accessor :ds

    def initialize(ptr=nil, auto_free=true)
      @ds = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ds.autorelease = auto_free
    end

    def self.release(ptr)
      FFIOGR.OGR_DS_Destroy(ptr)
    end

    def add_layer(name, geometry_type, spatial_ref=nil, options={})
      # need to add spatial reference mapping
      # need to add options as StringList ...
      layer = FFIOGR.OGR_DS_CreateLayer(@ds, name, spatial_ref, geometry_type.to_sym, nil)
      OGR::Tools.cast_layer(layer)
    end

    def get_layers
      layers = []

      num_layers = OGR_DS_GetLayerCount(@ds)

      for i in (0...num_layers) do
        layers << OGR_DS_GetLayer(@ds, i)
      end

      layers
    end
    alias_method :layers, :get_layers

    def get_features
      features = []

      layers.each do |layer|
        OGR_L_ResetReading(layer)

        num_features = OGR_L_GetFeatureCount(layer, 0)

        for i in (0...num_features) do
          features << OGR::Tools.cast_feature(OGR_L_GetNextFeature(layer))
        end
      end

      features
    end
    alias_method :features, :get_features

    def get_geometries
      features.map {|f| OGR::Tools.cast_geometry(f.geometry)}
    end
    alias_method :geometries, :get_geometries

    def get_fields
      features.map {|f| f.fields}
    end
    alias_method :fields, :get_fields

    def to_geojson(pretty=false)
      MultiJson.dump({type: 'FeatureCollection', features: features.map {|f| f.to_geojson}}, pretty: pretty)
    end
  end
end
