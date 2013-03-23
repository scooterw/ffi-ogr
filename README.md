ffi-ogr
... for convenient access to OGR functionality from Ruby

To run: `ogr_console`

```ruby

shp = OGR::ShpReader.new.read '/path/to/shapefile.shp'
# => #<FFI::Pointer address=0x007feb5c40ba00>

geo_json_from_previous_read = OGR::ShpReader.new.to_geojson shp
# => geojson feature collection from Shapefile
# "pretty print" option if true as second argument

geo_json_from_file = OGR::ShpReader.new.to_geojson '/path/to/shapefile.shp'
# => geojson feature collection from Shapefile

```

Tested on: MRI 1.9.3-p392 and JRuby 1.7.3
