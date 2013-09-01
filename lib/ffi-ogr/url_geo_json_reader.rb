require 'fileutils'
require 'securerandom'
require 'faraday'

module OGR
  class UrlGeoJSONReader < GeoJSONReader
    def read(url, writeable=false)
      file_name = "#{SecureRandom.urlsafe_base64}.json"
      remote_json = Faraday.get(url).body

      File.open(file_name, 'wb') do |f|
        f.write(remote_json)
      end

      data_source = super(file_name, writeable)

      FileUtils.rm(file_name)

      data_source
    end
  end
end
