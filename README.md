ffi-ogr
... for convenient access to OGR functionality from Ruby

To run: `bin/ogr_console`

To read a shapefile:

```ruby

shp = OGR::ShpReader.new.read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
# => #<OGR::DataSource:0x007fba4d19c328 @ds=#<FFI::AutoPointer address=0x007fba4c4cdc50>>

shp.to_geojson
# => geojson feature collection from Shapefile

shp.to_geojson true
# => "pretty print" geojson feature collection from Shapefile
```

A reader may also be inferred by file extension (currently works for shp and json/geojson):

```ruby

shp = OGR::Reader.from_file_type './spec/data/ne_110m_coastline/ne_110m_coastline.shp'

```

To create a shapefile:

```ruby

writer = OGR::ShpWriter.new
writer.set_output '~/Documents/shapefiles/my_new.shp'

shp = writer.ds

# add layer to shp : add_layer(name, geometry_type, spatial_reference)
# currently does not handle spatial reference, will automatically be nil
layer = shp.add_layer 'first_layer', :point

# add field to layer : add_field(name, field_type, width) NOTE: width defaults to 32
layer.add_field 'name', :string

# create feature on layer
feature = layer.create_feature

# add field value to feature : set_field_value(field_name, field_value, field_type) NOTE: type can be inferred
feature.set_field_value 'name', 'my_feature'

# create point
point = OGR::Point.create [-104.789322, 38.992961]

# add point to first_feature
feature.add_geometry point

# add feature to first_layer
layer.add_feature feature

# sync to disk
layer.sync

```

A writer may also be inferred by file extension (currently works for shp and json/geojson):

```ruby

writer = OGR::Writer.from_file_type '~/Documents/shapefiles/my_new.shp'

```

Tested on: MRI 1.9.3-p392 and JRuby 1.7.3
