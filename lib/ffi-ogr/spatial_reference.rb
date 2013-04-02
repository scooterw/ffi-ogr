module OGR
  class SpatialReference
    attr_accessor :ptr

    def initialize(ptr, auto_free=true)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ptr.autorelease = auto_free
    end

    def self.release(ptr)
      FFIOGR.OSRDestroySpatialReference(@ptr)
    end

    def self.create
      OGR::Tools.cast_spatial_reference(FFIOGR.OSRNewSpatialReference(nil))
    end

    def self.from_wkt(wkt)
      sr = OGR::Tools.cast_spatial_reference(FFIOGR.OSRNewSpatialReference(nil))
      sr.import_wkt(wkt)
      sr
    end

    def self.from_proj4(proj4)
      sr = OGR::Tools.cast_spatial_reference(FFIOGR.OSRNewSpatialReference(nil))
      sr.import_proj4(proj4)
      sr
    end

    def self.from_epsg(epsg_code)
      sr = OGR::Tools.cast_spatial_reference(FFIOGR.OSRNewSpatialReference(nil))
      sr.import_epsg(epsg_code)
      sr
    end

    def import_wkt(wkt)
      FFIOGR.OSRImportFromWkt(@ptr, wkt)
    end

    def import_proj4(proj4)
      FFIOGR.OSRImportFromProj4(@ptr, proj4)
    end

    def import_epsg(epsg_code)
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

    def get_coordinate_transformation(out_sr)
      if out_sr.instance_of? Integer
        out_sr = OGR::SpatialReference.from_epsg out_sr
      elsif out_sr.instance_of? String
        begin
          out_sr = OGR::SpatialReference.from_wkt out_sr
        rescue
          out_sr = OGR::SpatialReference.from_proj4 out_sr
        end
      end

      if out_sr.instance_of? OGR::SpatialReference
        FFIOGR.OSRNewCoordinateTransformation(@ptr, out_sr.ptr)
      else
        raise RuntimeError.new("Could not obtain spatial reference information")
      end
    end
  end
end
