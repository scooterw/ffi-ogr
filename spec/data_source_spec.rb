require 'rspec/expectations'
require File.expand_path 'lib/ffi-ogr'
require 'fileutils'

describe OGR::DataSource do
  after(:all) do
    FileUtils.rm './spec/data/ds_csv_test.csv'
  end

  it "should convert to CSV" do
    csv_file_name = './spec/data/ds_csv_test.csv'

    ds = OGR::ShpReader.new.read './spec/data/ne_110m_coastline/ne_110m_coastline.shp'
    csv = ds.to_csv csv_file_name
    File.exist?(csv_file_name).should be true
  end
end
