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

DIM FoundPosition&
DIM SearchResult%
DIM CacheJarIdx%[10]
DIM CacheCRC16%[10]
DIM CachePos&[10]
DIM CachePtr%

SUB ZipFind (JarIndex%, ClassName$)

BUNDLE Entry ZipLocalHeader
