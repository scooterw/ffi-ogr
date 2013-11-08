require File.expand_path 'spec/spec_helper'
require File.expand_path 'lib/ffi-ogr'

describe OGR::Reader do

  it "should create datasource from GeoJSON file" do
    ds = OGR::Reader.new('geojson').read './spec/data/ne_110m_coastline.geojson'
    ds.class.should eq OGR::DataSource
  end

  it "should create datasource from shapefile" do
    ds = OGR::Reader.new('ESRI Shapefile').read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
    ds.class.should eq OGR::DataSource
  end

  it "should create datasource from KML file" do
    ds = OGR::Reader.new('kml').read './spec/data/ne_110m_coastline.kml'
    ds.class.should eq OGR::DataSource
  end

end

