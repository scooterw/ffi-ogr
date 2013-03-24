module OGR
  class Shapefile
    include FFIOGR

    attr_accessor :ptr

    def initialize(*args)
      if args.first.instance_of? FFI::Pointer
        @shp = FFI::AutoPointer.new(args.first, self.class.method(:release))
        @shp.autorelease = true
      else
        @shp = 'shapefile'
      end
    end

    def self.release(ptr)
      FFIOGR.OGR_DS_Destroy(ptr)
    end

    def get_layers
      layers = []

      num_layers = OGR_DS_GetLayerCount(@shp)

      for i in (0...num_layers) do
        layers << OGR_DS_GetLayer(@shp, i)
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
      if @shp && @shp.instance_of?(FFI::AutoPointer)
        ptr_to_geojson(pretty)
      else
        shp_to_geojson(pretty)
      end
    end

    def shp_to_geojson(pretty=false)
      @shp
    end

    def ptr_to_geojson(pretty=false)
      MultiJson.dump({type: 'FeatureCollection', features: features.map {|f| f.to_geojson}}, pretty: pretty)
    end
  end
end
