ffi-ogr
... for convenient access to OGR functionality from Ruby

To run: `ogr_console`

To read shapefile:

```ruby

OGR::ShpReader.new.read('/path/to/shapefile.shp')

Tested on: MRI 1.9.3-p392 and JRuby 1.7.3
