require File.expand_path 'spec/spec_helper'
require 'rspec/expectations'
require File.expand_path 'lib/ffi-ogr'
require 'fileutils'

describe OGR::DataSource do

  after(:all) do
    FileUtils.rm './spec/data/ds_csv_test.csv'
    FileUtils.rm './spec/data/ds_kml_test.csv'
    FileUtils.rm_rf './spec/data/ds_shp_test'
  end

  it "should convert to CSV" do
    csv_file_name = './spec/data/ds_csv_test.csv'

    ds = OGR::Reader.new('ESRI Shapefile').read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'

    csv = ds.to_csv csv_file_name
    File.exist?(csv_file_name).should be true
  end

  it "should convert to KML" do
    kml_file_name = './spec/data/ds_kml_test.kml'

    ds = OGR::Reader.new('ESRI Shapefile').read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'

    kml = ds.to_kml kml_file_name
    File.exist?(kml_file_name).should be true
  end
  
  it "should convert to SHP" do
    FileUtils.mkdir './spec/data/ds_shp_test'
    shp_file_name = './spec/data/ds_shp_test/ds_shp_test.shp'
    shx_file_name = './spec/data/ds_shp_test/ds_shp_test.shx'

    ds = OGR::Reader.new('geojson').read './spec/data/ne_110m_coastline.geojson'

    shp = ds.to_shp shp_file_name
    (File.exist?(shp_file_name) && File.exist?(shx_file_name)).should be true
  end

end

