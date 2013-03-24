require 'ffi'
require 'multi_json'

module OGR
  OGR_BASE = File.join(File.dirname(__FILE__), 'ffi-ogr')

  autoload :ShpReader, File.join(OGR_BASE, 'shp_reader')
  autoload :DataSource, File.join(OGR_BASE, 'data_source')
  autoload :Tools, File.join(OGR_BASE, 'tools')
  autoload :Feature, File.join(OGR_BASE, 'feature')
  autoload :Geometry, File.join(OGR_BASE, 'geometry')
  autoload :Point, File.join(OGR_BASE, 'point')
  autoload :LineString, File.join(OGR_BASE, 'line_string')
  autoload :Polygon, File.join(OGR_BASE, 'polygon')
  autoload :MultiPoint, File.join(OGR_BASE, 'multi_point')
  autoload :MultiLineString, File.join(OGR_BASE, 'multi_line_string')
  autoload :MultiPolygon, File.join(OGR_BASE, 'multi_polygon')

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

    enum :ogr_justification, [
      :undefined, 0,
      :left, 1,
      :right, 2
    ]

    attach_function :OGRRegisterAll, [], :void
    attach_function :OGR_Dr_GetName, [:pointer], :string
    attach_function :OGR_Dr_Open, [:pointer, :string, :int], :pointer
    attach_function :OGR_Dr_TestCapability, [:pointer, :string], :int
    attach_function :OGR_Dr_CreateDataSource, [:pointer, :string, :string], :pointer
    attach_function :OGR_Dr_CopyDataSource, [:pointer, :pointer, :string, :string], :pointer
    attach_function :OGR_Dr_DeleteDataSource, [:pointer, :string], :pointer
    attach_function :OGRGetDriverCount, [], :int
    attach_function :OGRGetDriver, [:int], :pointer
    attach_function :OGRGetDriverByName, [:string], :pointer
    attach_function :OGROpen, [:string, :int, :pointer], :pointer
    attach_function :OGR_DS_Destroy, [:pointer], :void
    attach_function :OGR_DS_GetName, [:pointer], :string
    attach_function :OGR_DS_GetLayerCount, [:pointer], :int
    attach_function :OGR_DS_GetLayer, [:pointer, :int], :pointer
    attach_function :OGR_DS_GetLayerByName, [:pointer, :string], :pointer
    attach_function :OGR_DS_DeleteLayer, [:pointer, :int], :pointer
    attach_function :OGR_DS_GetDriver, [:pointer], :pointer
    attach_function :OGR_DS_CreateLayer, [:pointer, :string, :pointer, :ogr_geometry_type, :string], :pointer
    attach_function :OGR_DS_CopyLayer, [:pointer, :pointer, :string, :string], :pointer
    attach_function :OGR_DS_TestCapability, [:pointer, :string], :int
    attach_function :OGR_DS_ExecuteSQL, [:pointer, :string, :pointer, :string], :pointer
    attach_function :OGR_DS_ReleaseResultSet, [:pointer, :pointer], :void
    attach_function :OGR_DS_SyncToDisk, [:pointer], :pointer
    attach_function :OGR_L_GetGeomType, [:pointer], :ogr_geometry_type
    attach_function :OGR_L_GetSpatialFilter, [:pointer], :pointer
    attach_function :OGR_L_SetSpatialFilter, [:pointer, :pointer], :void
    attach_function :OGR_L_SetSpatialFilterRect, [:pointer, :double, :double, :double, :double], :void
    attach_function :OGR_L_SetAttributeFilter, [:pointer, :string], :pointer
    attach_function :OGR_L_ResetReading, [:pointer], :void
    attach_function :OGR_L_GetNextFeature, [:pointer], :pointer
    attach_function :OGR_L_SetNextByIndex, [:pointer, :long], :pointer
    attach_function :OGR_L_GetFeature, [:pointer, :long], :pointer
    attach_function :OGR_L_SetFeature, [:pointer, :pointer], :pointer
    attach_function :OGR_L_CreateFeature, [:pointer, :pointer], :pointer
    attach_function :OGR_L_DeleteFeature, [:pointer, :long], :pointer
    attach_function :OGR_L_GetLayerDefn, [:pointer], :pointer
    attach_function :OGR_L_GetSpatialRef, [:pointer], :pointer
    attach_function :OGR_L_GetFeatureCount, [:pointer, :int], :int
    attach_function :OGR_L_GetExtent, [:pointer, :pointer, :int], :pointer
    attach_function :OGR_FD_GetFieldCount, [:pointer], :int
    attach_function :OGR_FD_GetFieldDefn, [:pointer, :int], :pointer
    attach_function :OGR_Fld_Create, [:string, :ogr_field_type], :pointer
    attach_function :OGR_Fld_Destroy, [:pointer], :void
    attach_function :OGR_Fld_SetName, [:pointer, :string], :void
    attach_function :OGR_Fld_GetNameRef, [:pointer], :string
    attach_function :OGR_Fld_GetType, [:pointer], :ogr_field_type
    attach_function :OGR_Fld_SetType, [:pointer, :ogr_field_type], :void
    attach_function :OGR_Fld_GetJustify, [:pointer], :ogr_justification
    attach_function :OGR_Fld_SetJustify, [:pointer, :ogr_justification], :void
    attach_function :OGR_Fld_GetWidth, [:pointer], :int
    attach_function :OGR_Fld_SetWidth, [:pointer, :int], :void
    attach_function :OGR_Fld_GetPrecision, [:pointer], :int
    attach_function :OGR_Fld_SetPrecision, [:pointer, :int], :void
    attach_function :OGR_Fld_Set, [:pointer, :string, :ogr_field_type, :int, :int, :ogr_justification], :void
    attach_function :OGR_Fld_IsIgnored, [:pointer], :int
    attach_function :OGR_Fld_SetIgnored, [:pointer, :int], :void
    attach_function :OGR_F_GetFieldAsInteger, [:pointer, :int], :int
    attach_function :OGR_F_GetFieldAsDouble, [:pointer, :int], :double
    attach_function :OGR_F_GetFieldAsString, [:pointer, :int], :string
    #attach_function :OGR_F_GetFieldAsIntegerList, [:pointer, :int, :pointer], :pointer
    #attach_function :OGR_F_GetFieldAsDoubleList, [:pointer, :int, :pointer], :pointer
    #attach_function :OGR_F_GetFieldAsStringList, [:pointer, :int], :pointer
    #attach_function :OGR_F_GetFieldAsBinary, [:pointer, :int, :pointer], :pointer
    #attach_function :OGR_F_GetFieldAsDateTime, [:pointer, :int, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :pointer
    attach_function :OGR_F_GetDefnRef, [:pointer], :pointer
    attach_function :OGR_F_GetFieldCount, [:pointer], :int
    attach_function :OGR_F_GetFieldDefnRef, [:pointer, :int], :pointer
    attach_function :OGR_F_GetFieldIndex, [:pointer, :string], :int
    attach_function :OGR_F_IsFieldSet, [:pointer, :int], :int
    attach_function :OGR_F_GetGeometryRef, [:pointer], :pointer
    attach_function :OGR_F_GetFID, [:pointer], :long
    attach_function :OGR_F_SetFID, [:pointer, :long], :pointer
    attach_function :OGR_G_CreateFromWkb, [:pointer, :pointer, :pointer, :int], :pointer
    attach_function :OGR_G_CreateFromWkt, [:pointer, :pointer, :pointer], :pointer
    attach_function :OGR_G_DestroyGeometry, [:pointer], :void
    attach_function :OGR_G_CreateGeometry, [:ogr_geometry_type], :pointer
    attach_function :OGR_G_ApproximateArcAngles, [:double, :double, :double, :double, :double, :double, :double, :double, :double], :pointer
    attach_function :OGR_G_ForceToPolygon, [:pointer], :pointer
    #attach_function :OGR_G_ForceToLineString, [:pointer], :pointer
    attach_function :OGR_G_ForceToMultiPolygon, [:pointer], :pointer
    attach_function :OGR_G_ForceToMultiPoint, [:pointer], :pointer
    attach_function :OGR_G_ForceToMultiLineString, [:pointer], :pointer
    attach_function :OGR_G_GetDimension, [:pointer], :int
    attach_function :OGR_G_GetCoordinateDimension, [:pointer], :int
    attach_function :OGR_G_SetCoordinateDimension, [:pointer, :int], :void
    attach_function :OGR_G_Clone, [:pointer], :pointer
    attach_function :OGR_G_GetEnvelope, [:pointer, :pointer], :void
    attach_function :OGR_G_GetEnvelope3D, [:pointer, :pointer], :void
    attach_function :OGR_G_ImportFromWkb, [:pointer, :pointer, :int], :pointer
    attach_function :OGR_G_ExportToWkb, [:pointer, :pointer, :pointer], :pointer
    attach_function :OGR_G_WkbSize, [:pointer], :int
    attach_function :OGR_G_ImportFromWkt, [:pointer, :pointer], :pointer
    attach_function :OGR_G_ExportToWkt, [:pointer, :pointer], :pointer
    attach_function :OGR_G_GetGeometryType, [:pointer], :ogr_geometry_type
    attach_function :OGR_G_GetGeometryName, [:pointer], :string
    attach_function :OGR_G_DumpReadable, [:pointer, :pointer, :string], :void
    attach_function :OGR_G_FlattenTo2D, [:pointer], :void
    attach_function :OGR_G_CloseRings, [:pointer], :void
    attach_function :OGR_G_CreateFromGML, [:string], :pointer
    attach_function :OGR_G_ExportToGML, [:pointer], :string
    #attach_function :OGR_G_ExportToGMLEx, [:pointer, :pointer], :string
    attach_function :OGR_G_ExportToKML, [:pointer, :string], :string
    attach_function :OGR_G_ExportToJson, [:pointer], :string
    attach_function :OGR_G_ExportToJsonEx, [:pointer, :string], :string
    attach_function :OGR_G_AssignSpatialReference, [:pointer, :pointer], :void
    attach_function :OGR_G_GetSpatialReference, [:pointer], :pointer
    attach_function :OGR_G_Transform, [:pointer, :pointer], :pointer
    attach_function :OGR_G_TransformTo, [:pointer, :pointer], :pointer
    attach_function :OGR_G_Simplify, [:pointer, :double], :pointer
    attach_function :OGR_G_SimplifyPreserveTopology, [:pointer, :double], :pointer
    attach_function :OGR_G_Segmentize, [:pointer, :double], :pointer
    attach_function :OGR_G_Intersects, [:pointer, :pointer], :int
    attach_function :OGR_G_Equals, [:pointer, :pointer], :int
    attach_function :OGR_G_Disjoint, [:pointer, :pointer], :int
    attach_function :OGR_G_Touches, [:pointer, :pointer], :int
    attach_function :OGR_G_Crosses, [:pointer, :pointer], :int
    attach_function :OGR_G_Within, [:pointer, :pointer], :int
    attach_function :OGR_G_Contains, [:pointer, :pointer], :int
    attach_function :OGR_G_Overlaps, [:pointer, :pointer], :int
    attach_function :OGR_G_Boundary, [:pointer], :pointer
    attach_function :OGR_G_ConvexHull, [:pointer], :pointer
    attach_function :OGR_G_Buffer, [:pointer, :double, :int], :pointer
    attach_function :OGR_G_Intersection, [:pointer, :pointer], :pointer
    attach_function :OGR_G_Union, [:pointer, :pointer], :pointer
    attach_function :OGR_G_UnionCascaded, [:pointer], :pointer
    #attach_function :OGR_G_PointOnSurface, [:pointer], :pointer
    attach_function :OGR_G_Difference, [:pointer, :pointer], :pointer
    attach_function :OGR_G_SymDifference, [:pointer, :pointer], :pointer
    attach_function :OGR_G_Distance, [:pointer, :pointer], :double
    attach_function :OGR_G_Length, [:pointer], :double
    attach_function :OGR_G_Area, [:pointer], :double
    attach_function :OGR_G_Centroid, [:pointer, :pointer], :int
    attach_function :OGR_G_Empty, [:pointer], :void
    attach_function :OGR_G_IsEmpty, [:pointer], :int
    attach_function :OGR_G_IsValid, [:pointer], :int
    attach_function :OGR_G_IsSimple, [:pointer], :int
    attach_function :OGR_G_IsRing, [:pointer], :int
    attach_function :OGR_G_Polygonize, [:pointer], :pointer
    attach_function :OGR_G_GetPointCount, [:pointer], :int
    attach_function :OGR_G_GetPoints, [:pointer, :pointer, :int, :pointer, :int, :pointer, :int], :int
    attach_function :OGR_G_GetX, [:pointer, :int], :double
    attach_function :OGR_G_GetY, [:pointer, :int], :double
    attach_function :OGR_G_GetZ, [:pointer, :int], :double
    attach_function :OGR_G_GetPoint, [:pointer, :int, :pointer, :pointer, :pointer], :void
    attach_function :OGR_G_SetPoint, [:pointer, :int, :double, :double, :double], :void
    attach_function :OGR_G_SetPoint_2D, [:pointer, :int, :double, :double], :void
    attach_function :OGR_G_AddPoint, [:pointer, :double, :double, :double], :void
    attach_function :OGR_G_AddPoint_2D, [:pointer, :double, :double], :void
    attach_function :OGR_G_GetGeometryCount, [:pointer], :int
    attach_function :OGR_G_GetGeometryRef, [:pointer, :int], :pointer
    attach_function :OGR_G_AddGeometry, [:pointer, :pointer], :pointer
    attach_function :OGR_G_AddGeometryDirectly, [:pointer, :pointer], :pointer
    attach_function :OGR_G_RemoveGeometry, [:pointer, :int, :int], :pointer
    attach_function :OGR_F_Destroy, [:pointer], :void
  end

  class << self;end
end










