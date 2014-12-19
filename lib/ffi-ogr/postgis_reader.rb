require 'yaml'

module OGR
  class PostgisReader
    include OGR::FFIOGR

    attr_accessor :db_config

    TF_MAP = {
      true => 1,
      false => 0,
      1 => true,
      0 => false
    }

    def initialize(db_config_file)
      @db_config = parse_db_config db_config_file
      @driver = OGRGetDriverByName 'PostgreSQL'
      @type = 'PostgreSQL'
    end

    def parse_db_config(db_config_file)
      conf = YAML.load_file(File.expand_path(db_config_file))

      db_config = 'PG:'
      
      if conf['dbname']
        db_config = db_config + "dbname='#{conf['dbname']}'"
        if conf['host']
          db_config = db_config + " host='#{conf['host']}'"
          if conf['port']
            db_config = db_config + " port='#{conf['port']}'"
            db_config = db_config + " user='#{conf['user']}'" if conf['user']
            db_config = db_config + " password='#{conf['password']}'" if conf['password']
          else
            raise RuntimeError.new 'port must be specified'
          end
        else
          raise RuntimeError.new 'host must be specified'
        end
      else
        raise RuntimeError.new 'dbname must be specified'
      end

      db_config
    end

    def execute_query(query, writeable = false)
      pg_driver = OGR_Dr_Open @driver, @db_config, TF_MAP[writeable]
      result_set = OGR_DS_ExecuteSQL pg_driver, query, nil, nil
      # result_set is OGRLayer
      # must call OGR_DS_ReleaseResultSet(pg_driver, result_set) to clean up
    end
  end
end
