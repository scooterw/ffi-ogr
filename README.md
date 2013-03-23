ffi-ogr
... for convenient access to OGR functionality from Ruby

To run: `ogr_console`

To read shapefile:

```ruby

OGR::ShpReader.new.read('/path/to/shapefile.shp')
