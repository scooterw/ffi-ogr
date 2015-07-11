require 'fileutils'
require 'securerandom'
require 'faraday'
require 'faraday_middleware'

module OGR
  class HttpReader

    TF_MAP = {
      true => 1,
      false => 0,
      1 => true,
      0 => false
    }

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

      connection = Faraday.new url do |conn|
        conn.use FaradayMiddleware::FollowRedirects
        conn.adapter Faraday.default_adapter
      end

      http_data = connection.get.body

      ogr_driver = OGR::FFIOGR::OGRGetDriverByName driver
      data_source = OGR::FFIOGR::OGR_Dr_Open ogr_driver, http_data, TF_MAP[writeable]
      OGR::Tools.cast_data_source data_source
    end
  end
end

