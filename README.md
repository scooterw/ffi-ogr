[![Build Status](https://travis-ci.org/scooterw/ffi-ogr.png?branch=master)](https://travis-ci.org/scooterw/ffi-ogr)
[![Code Climate](https://codeclimate.com/github/scooterw/ffi-ogr.png)](https://codeclimate.com/github/scooterw/ffi-ogr)

GDAL must be installed:

Mac:
```
brew install gdal
```

Ubuntu:
```
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 16126D3A3E5C1192
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:ubuntugis/ppa -y
sudo apt-get update -qq
sudo apt-get install libgdal-dev
```

ffi-ogr
... for convenient access to OGR functionality from Ruby

To run: `bin/ogr_console`

To read from a known file type (currently SHP, JSON/GeoJSON, CSV, raw Github GeoJSON URL, raw (spatial) CSV URL, Esri Feature Service URL):

```ruby
data = OGR.read('https://raw.github.com/colemanm/hurricanes/master/fl_2004_hurricanes.geojson')
=> #<OGR::DataSource:0x007fb830aa3af8 @ptr=#<FFI::AutoPointer address=0x007fb8311ab990>>

# output to SHP file
data.to_shp '~/Desktop/github_to_shp.shp'
=> nil

# output to CSV file
data.to_csv '~/Desktop/github_to_csv.csv'
=> nil
```

To read a shapefile:

```ruby
shp = OGR.read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
# => #<OGR::DataSource:0x007fba4d19c328 @ptr=#<FFI::AutoPointer address=0x007fba4c4cdc50>>

shp.to_geojson '~/Desktop/output.geojson'
# => Output GeoJSON to specified file
```

To reproject a shapefile:

```ruby
shp = OGR.read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
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

To create a shapefile:

```ruby
writer = OGR.create_writer '~/Documents/shapefiles/my_new.shp'

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

A writer may be fetched by driver type:

```ruby
writer = OGR.get_writer 'shp'
writer.set_output '~/Documents/shapefiles/my_new.shp'
```

Tested on: MRI (1.9/2.0), JRuby (1.9/2.0), and Rubinius (1.9/2.0)
