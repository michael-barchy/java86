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

%MAX_JAR_CACHE = 10

DIM JAR_CACHE_IDX%[%MAX_JAR_CACHE]
DIM JAR_CACHE_CRC%[%MAX_JAR_CACHE]
DIM JAR_CACHE_POS&[%MAX_JAR_CACHE]
DIM JAR_CACHE_COUNT%
DIM JAR_RESULT%

SUB ZipFind (JarIndex%, ClassName$)

BUNDLE Entry ZipLocalHeader
