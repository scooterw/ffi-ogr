require 'fileutils'
require 'securerandom'
require 'faraday'

module OGR
  class HttpReader
    def read(url, writeable=false)
      file_extension = url.split('.').last
      driver = OGR::DRIVER_TYPES[file_extension]

      if driver.nil?
        unless url =~ /FeatureServer/
          raise RuntimeError.new "File type not supported."
        else
          # ? assume Esri Feature Service ?
          file_extension = 'json'
          driver = OGR::DRIVER_TYPES[file_extension]
        end
      end

      file_name = "#{SecureRandom.urlsafe_base64}.#{file_extension}"

      http_resource = Faraday.get(url).body

      File.open(file_name, 'wb') do |f|
        f.write http_resource
      end

      ds = Reader.new(driver).read(file_name, writeable)

      FileUtils.rm file_name

      ds
    end
  end
end

