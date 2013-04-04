module OGR
  class CoordinateTransformation
    attr_accessor :ptr

    def initialize(ptr)
      @ptr = FFI::AutoPointer.new(ptr, self.class.method(:release))
      @ptr.autorelease = false
    end

    def self.release(ptr);end

    def free
      FFIOGR.OCTDestroyCoordinateTransformation(@ptr)
    end

    def self.find_transformation(in_sr, out_sr)
      bad_sr = []

      if !in_sr.instance_of?(OGR::SpatialReference)
        bad_sr << 'Input SR'
      elsif !out_sr.instance_of?(OGR::SpatialReference)
        bad_sr << 'Output SR'
      end

      raise RuntimeError.new("Invalid Spatial Reference(s): #{bad_sr.join(', ')}") if bad_sr.size > 0

      FFIOGR.OCTNewCoordinateTransformation(in_sr.ptr, out_sr.ptr)
    end
  end
end
