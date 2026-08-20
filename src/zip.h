TYPE ZipLocalHeader _
    Signature&, _
    Version%, _
    Flags%, _
    Method%, _
    ModTime%, _
    ModDate%, _
    Checksum&, _
    CompressedSize&, _
    UncompressedSize&, _
    FileNameLength%, _
    ExtraFieldLength%

TYPE ZipCentralHeader _
    Signature&, _
    VersionMadeBy%, _
    VersionNeeded%, _
    Flags%, _
    Method%, _
    ModTime%, _
    ModDate%, _
    Checksum&, _
    CompressedSize&, _
    UncompressedSize&, _
    FileNameLength%, _
    ExtraFieldLength%, _
    CommentLength%, _
    DiskStart%, _
    InternalAttr%, _
    ExternalAttr&, _
    LocalHeaderOffset&

TYPE ZipEocdHeader _
    Signature&, _
    DiskNum%, _
    StartDisk%, _
    DiskEntries%, _
    TotalEntries%, _
    CdSize&, _
    CdOffset&, _
    CommentLen%

%MAX_JAR_CACHE = 10

DIM JAR_CACHE_IDX%[%MAX_JAR_CACHE]
DIM JAR_CACHE_CRC%[%MAX_JAR_CACHE]
DIM JAR_CACHE_POS&[%MAX_JAR_CACHE]
DIM JAR_CACHE_COUNT%
DIM JAR_RESULT%

SUB ZipFind (JarIndex%, ClassName$)

BUNDLE LocalHeader ZipLocalHeader
BUNDLE CentralHeader ZipCentralHeader
BUNDLE Eocd ZipEocdHeader
