require 'fileutils'
require 'securerandom'
require 'faraday'

module OGR
  class UrlCSVReader < CSVReader
    def read(url, writeable=false)
      file_name = "#{SecureRandom.urlsafe_base64}.csv"
      remote_csv = Faraday.get(url).body

      File.open(file_name, 'wb') do |f|
        f.write(remote_csv)
      end

      ds = super(file_name, writeable)

      FileUtils.rm(file_name)

      ds
    end
  end
end
