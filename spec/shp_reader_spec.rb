require File.expand_path 'lib/ffi-ogr'

describe OGR::ShpReader do

  it "should create datasource" do
    ds = OGR::ShpReader.new.read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
    ds.class.should eq OGR::DataSource
  end

end

