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

DIM JAR_CACHE_IDX%[10]
DIM JAR_CACHE_CRC%[10]
DIM JAR_CACHE_POS&[10]
DIM JAR_RESULT%

SUB ZipFind (JarIndex%, ClassName$)

BUNDLE Entry ZipLocalHeader
