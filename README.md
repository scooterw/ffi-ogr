ffi-ogr
... for convenient access to OGR functionality from Ruby

To run: `bin/ogr_console`

To read from a known file type (currently SHP, JSON/GeoJSON, raw Github GeoJSON URL, Esri Feature Service URL):

```ruby
data = OGR.read('https://raw.github.com/colemanm/hurricanes/master/fl_2004_hurricanes.geojson')
=> #<OGR::DataSource:0x007fb830aa3af8 @ptr=#<FFI::AutoPointer address=0x007fb8311ab990>>

# output to SHP file
data.to_shp '/~Desktop/github_to_shp.shp'
=> nil
```

To read a shapefile:

```ruby
shp = OGR::ShpReader.new.read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
# => #<OGR::DataSource:0x007fba4d19c328 @ptr=#<FFI::AutoPointer address=0x007fba4c4cdc50>>

shp.to_geojson '~/Desktop/output.geojson'
# => Output GeoJSON to specified file
```

To reproject a shapefile:

```ruby
shp = OGR::ShpReader.new.read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
# => #<OGR::DataSource:0x007fba4d19c328 @ptr=#<FFI::AutoPointer address=0x007fba4c4cdc50>>

shp.to_json
# => Output GeoJSON string

shp.to_json true
# => Output GeoJSON string (pretty print)

# from_epsg(integer), from_proj4(string), from_wkt(string)
new_sr = OGR::SpatialReference.from_epsg 3857
# => #<OGR::SpatialReference:0x007fd859a0e6f8 @ptr=#<FFI::AutoPointer address=0x007fd85a11c100>>

shp.to_shp '~/Desktop/reprojected_shp.shp', {spatial_ref: new_sr}
# => Output reprojected SHP to specified file
```

A reader may also be inferred by file extension (currently works for shp and json/geojson):

```ruby
shp = OGR::Reader.from_file_type './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
```

To create a shapefile:

```ruby
writer = OGR::ShpWriter.new
writer.set_output '~/Documents/shapefiles/my_new.shp'

shp = writer.ptr

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

Tested on: MRI 1.9.3 / 2.0.0 and JRuby 1.7.3+
