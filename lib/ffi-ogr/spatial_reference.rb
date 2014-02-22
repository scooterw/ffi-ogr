module OGR
  class SpatialReference
    attr_accessor :ptr

    def initialize(ptr)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ptr.autorelease = false
    end

    def self.release(ptr);end

    def free
      FFIOGR.OSRDestroySpatialReference(@ptr)
    end

    def check_int(sr_import, format = 'epsg')
      begin
        Integer(sr_import)
      rescue => ex
        raise RuntimeError.new "Format: #{format} requires an integer value"
      end
    end

    def check_string(sr_import, format)
      raise RuntimeError.new "Format: #{format} requires a string value" unless sr_import.instance_of? String
    end

    def self.import(sr_import, format = 'epsg')
      sr = OGR::Tools.cast_spatial_reference(FFIOGR.OSRNewSpatialReference(nil))

      case format
      when 'epsg'
        sr.import_epsg sr_import
      when 'wkt'
        sr.import_wkt sr_import
      when 'proj4'
        sr.import_proj4 sr_import
      else
        raise RuntimeError.new "Format: #{format} is not currently supported"
      end

      sr
    end

    def import_wkt(wkt)
      check_string wkt, 'wkt'
      wkt_ptr = FFI::MemoryPointer.from_string wkt
      wkt_ptr_ptr = FFI::MemoryPointer.new :pointer
      wkt_ptr_ptr.put_pointer 0, wkt_ptr
      FFIOGR.OSRImportFromWkt(@ptr, wkt_ptr_ptr)
    end

    def import_proj4(proj4_string)
      check_string proj4_string, 'proj4'
      FFIOGR.OSRImportFromProj4(@ptr, proj4_string)
    end

    def import_epsg(epsg_code)
      epsg_code = check_int epsg_code, 'epsg'
      FFIOGR.OSRImportFromEPSG(@ptr, epsg_code)
    end

    def to_wkt(pretty=false)
      ptr = FFI::MemoryPointer.new :pointer

      unless pretty
        FFIOGR.OSRExportToWkt(@ptr, ptr)
      else
        FFIOGR.OSRExportToPrettyWkt(@ptr, ptr, 4)
      end
      str_ptr = ptr.read_pointer

      return str_ptr.null? ? nil : str_ptr.read_string
    end

    def to_proj4
      ptr = FFI::MemoryPointer.new :pointer
      FFIOGR.OSRExportToProj4(@ptr, ptr)
      str_ptr = ptr.read_pointer
      return str_ptr.null? ? nil: str_ptr.read_string
    end

    def ==(other)
      self.to_wkt == other.to_wkt
    end

    def find_transformation(out_sr)
      CoordinateTransformation.find_transformation self, out_sr
    end
  end
end

