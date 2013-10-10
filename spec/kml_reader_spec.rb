require File.expand_path 'lib/ffi-ogr'

describe OGR::KMLReader do
  it "should create datasource" do
    ds = OGR::KMLReader.new.read './spec/data/ne_110m_coastline.kml'
    ds.class.should eq OGR::DataSource
  end
end
