module OGR
  class OptionsStruct < FFI::Struct
    layout :length, :size_t,
           :options, :pointer

    def to_a
      self[:options].get_array_of_string 0, self[:length]
    end
  end
end
