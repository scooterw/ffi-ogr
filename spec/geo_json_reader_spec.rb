require File.expand_path 'lib/ffi-ogr'

describe OGR::GeoJSONReader do
  it "should create datasource" do
    ds = OGR::GeoJSONReader.new.read './spec/data/ne_110m_coastline.geojson'
    ds.class.should eq OGR::DataSource
  end
end

