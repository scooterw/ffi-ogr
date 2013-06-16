require 'fileutils'
require 'securerandom'
require 'faraday'

module OGR
  class FeatureServiceReader < GeoJSONReader
    def read(url, writeable=false)
      # NEED TO MAKE TEMP DIR CONFIGURABLE
      file_name = "#{SecureRandom.urlsafe_base64}.json"
      esri_json = Faraday.get(url).body

      File.open(file_name, 'wb') do |f|
        f.write(esri_json)
      end

      data_source = super(file_name, writeable)

      FileUtils.rm(file_name)

      data_source
    end
  end
end
