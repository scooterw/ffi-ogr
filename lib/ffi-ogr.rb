require 'ffi'

module OGR
  OGR_BASE = File.join(File.dirname(__FILE__), 'ffi-ogr')

  autoload :ShpReader, File.join(OGR_BASE, 'shp_reader')

  module FFIOGR
    def self.search_paths
      @search_paths ||= begin
        if ENV['GDAL_LIBRARY_PATH']
        elsif FFI::Platform.windows?
          ENV['PATH'].split(File::PATH_SEPARATOR)
        else
          ['/usr/local/{lib64,lib}', '/opt/local/{lib64,lib}', '/usr/{lib64,lib}']
          ['/usr/local/{lib64,lib}', '/opt/local/{lib64,lib}', '/usr/{lib64,lib}', '/usr/lib/{x86_64,i386}-linux-gnu']
        end
      end
    end

    def self.find_lib(lib)
      if ENV['GDAL_LIBRARY_PATH'] && File.file?(ENV['GDAL_LIBRARY_PATH'])
        ENV['GDAL_LIBRARY_PATH']
      else
        Dir.glob(search_paths.map {|path|
          File.expand_path(File.join(path, "#{lib}.#{FFI::Platform::LIBSUFFIX}"))
        }).first
      end
    end

    def self.gdal_library_path
      @gdal_library_path ||= begin
        find_lib('{lib,}gdal{,-?}')
      end
    end

    extend ::FFI::Library

    ffi_lib(gdal_library_path)

    enum :ogr_field_type, [
      :integer, 0,
      :integer_list, 1,
      :real, 2,
      :real_list, 3,
      :string, 4,
      :string_list, 5,
      :wide_string, 6,
      :wide_string_list, 7,
      :binary, 8,
      :date, 9,
      :time, 10,
      :date_time, 11
    ]

    enum :ogr_geometry_type, [
      :wkb_unknown, 0,
      :wkb_point, 1,
      :wkb_line_string, 2,
      :wkb_polygon, 3,
      :wkb_multi_point, 4,
      :wkb_multi_line_string, 5,
      :wkb_multi_polygon, 6,
      :wkb_geometry_collection, 7,
      :wkb_none, 100,
      :wkb_linear_ring, 101,
      :wkb_point_25d, 0x80000001,
      :wkb_line_string_25d, 0x80000002,
      :wkb_polygon_25d, 0x80000003,
      :wkb_multi_point_25d, 0x80000004,
      :wkb_multi_line_string_25d, 0x80000005,
      :wkb_multi_polygon_25d, 0x80000006,
      :wkb_geometry_collection_25d, 0x80000007
    ]

    attach_function :OGRRegisterAll, [], :void
    attach_function :OGR_Dr_GetName, [:pointer], :string
    attach_function :OGR_Dr_Open, [:pointer, :string, :int], :pointer
    attach_function :OGRGetDriverCount, [], :int
    attach_function :OGRGetDriver, [:int], :pointer
    attach_function :OGRGetDriverByName, [:string], :pointer
    attach_function :OGROpen, [:string, :int, :pointer], :pointer
    attach_function :OGR_DS_GetLayerByName, [:pointer, :string], :pointer
    attach_function :OGR_L_ResetReading, [:pointer], :void
    attach_function :OGR_L_GetNextFeature, [:pointer], :pointer
    attach_function :OGR_L_GetLayerDefn, [:pointer], :pointer
    attach_function :OGR_FD_GetFieldCount, [:pointer], :int
    attach_function :OGR_FD_GetFieldDefn, [:pointer, :int], :pointer
    attach_function :OGR_Fld_GetType, [:pointer], :ogr_field_type
    attach_function :OGR_F_GetFieldAsInteger, [:pointer, :int], :int
    attach_function :OGR_F_GetFieldAsDouble, [:pointer, :int], :double
    attach_function :OGR_F_GetFieldAsString, [:pointer, :int], :string
    attach_function :OGR_F_GetGeometryRef, [:pointer], :pointer
    attach_function :OGR_G_GetGeometryType, [:pointer], :ogr_geometry_type
    attach_function :OGR_G_GetX, [:pointer, :int], :double
    attach_function :OGR_G_GetY, [:pointer, :int], :double
    attach_function :OGR_F_Destroy, [:pointer], :void
    attach_function :OGR_DS_Destroy, [:pointer], :void
  end

  class << self;end
end
