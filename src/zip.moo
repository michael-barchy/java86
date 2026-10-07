SUB ZipFind (JarIndex%, ClassName$)
    JAR_RESULT% = 0

    TargetCRC16% = HASH2(ClassName$)

    FOR i% = 1 TO %MAX_JAR_CACHE
        ValidIdx% = 0
        IF JAR_CACHE_IDX%[i%] > 0 THEN
            ValidIdx% = 1
        ENDIF
        MatchCRC% = 0
        IF JAR_CACHE_CRC%[i%] = TargetCRC16% THEN
            MatchCRC% = 1
        ENDIF
        IF ValidIdx% = 1 THEN
            IF MatchCRC% = 1 THEN
                JAR_RESULT% = i%
                EXIT SUB
            ENDIF
        ENDIF
    NEXT

    CALL GetJarFile(JarIndex%)
    CurrentJar$ = JAR_FILE$
    F% = FOPEN(CurrentJar$)

    LocalHeader^ = FGET(F%)
    StreamingBit% = LocalHeader.Flags% AND 8

    IF StreamingBit% = 8 THEN
        FileSize& = FLEN(F%)
        EocdOffset& = FileSize& - 22
        FSEEK(F%, EocdOffset&)
        Eocd^ = FGET(F%)

        IF Eocd.Signature& = 06054B50h THEN
            FSEEK(F%, Eocd.CdOffset&)

            FOR EntryIdx% = 1 TO Eocd.TotalEntries%
                CentralHeader^ = FGET(F%)

                IF CentralHeader.Signature& = 02014B50h THEN
                    IF CentralHeader.FileNameLength% <= 0 THEN
                        PRINT "Invalid zip entry...\r\n"
                        END
                    ENDIF
                    CurrentName$ = SPACE(CentralHeader.FileNameLength%)
                    CurrentName$ = FGET(F%)

                    Offset& = FPOS(F%)

                    SkipLen& = CentralHeader.ExtraFieldLength% + CentralHeader.CommentLength%
                    Offset& = Offset& + SkipLen&
                    FSEEK(F%, Offset&)

                    IF CurrentName$ = ClassName$ THEN
                        FSEEK(F%, CentralHeader.LocalHeaderOffset&)
                        LocalHeader^ = FGET(F%)

                        FoundPosition& = CentralHeader.LocalHeaderOffset& + 30
                        FoundPosition& = FoundPosition& + LocalHeader.FileNameLength%
                        FoundPosition& = FoundPosition& + LocalHeader.ExtraFieldLength%

                        JAR_CACHE_COUNT% = JAR_CACHE_COUNT% + 1
                        JAR_RESULT% = JAR_CACHE_COUNT%
                        IF JAR_CACHE_COUNT% > %MAX_JAR_CACHE THEN
                            CALL JarCacheFree()
                        ENDIF

                        PTR% = CP_CACHE%[JAR_RESULT%]
                        IF PTR% > 0 THEN
                            'PRINT "Freeing old cache for jar index " + PTR% + "\r\n"
                            CALL SafeMFree(PTR%)
                            CP_CACHE%[JAR_RESULT%] = 0
                            CP_POS&[JAR_RESULT%] = 0
                        ENDIF
                        FOR I% = 1 TO %MAX_METHOD_CACHE
                            IF METHOD_CACHE_FILE_IDX%[I%] = JAR_RESULT% THEN
                                METHOD_CACHE_CRC%[I%] = 0
                                METHOD_CACHE_FILE_IDX%[I%] = 0
                            ENDIF
                        NEXT

                        JAR_CACHE_IDX%[JAR_RESULT%] = JarIndex%
                        JAR_CACHE_POS&[JAR_RESULT%] = FoundPosition&
                        JAR_CACHE_CRC%[JAR_RESULT%] = TargetCRC16%
                        JAR_H%[JAR_RESULT%] = 0

                        FCLOSE(F%)
                        EXIT SUB
                    ENDIF
                ELSE
                    EXIT FOR
                ENDIF
            NEXT
        ENDIF
    ELSE
        FSEEK(F%, 0)

        WHILE FEOF(F%) = FALSE
            LocalHeader^ = FGET(F%)
            IF LocalHeader.Signature& = 04034B50h THEN
                IF LocalHeader.FileNameLength% <= 0 THEN
                    PRINT "Invalid zip entry...\r\n"
                    END
                ENDIF
                CurrentName$ = SPACE(LocalHeader.FileNameLength%)
                CurrentName$ = FGET(F%)

                Offset& = FPOS(F%)
                Offset& = Offset& + LocalHeader.ExtraFieldLength%
                FSEEK(F%, Offset&)

                IF CurrentName$ = ClassName$ THEN
                    FoundPosition& = FPOS(F%)

                    JAR_CACHE_COUNT% = JAR_CACHE_COUNT% + 1
                    JAR_RESULT% = JAR_CACHE_COUNT%
                    IF JAR_CACHE_COUNT% > %MAX_JAR_CACHE THEN
                        CALL JarCacheFree()
                    ENDIF

                    PTR% = CP_CACHE%[JAR_RESULT%]
                    IF PTR% > 0 THEN
                        'PRINT "Freeing old cache for jar index " + PTR% + "\r\n"
                        CALL SafeMFree(PTR%)
                        CP_CACHE%[JAR_RESULT%] = 0
                        CP_POS&[JAR_RESULT%] = 0
                    ENDIF
                    FOR I% = 1 TO %MAX_METHOD_CACHE
                        IF METHOD_CACHE_FILE_IDX%[I%] = JAR_RESULT% THEN
                            METHOD_CACHE_CRC%[I%] = 0
                            METHOD_CACHE_FILE_IDX%[I%] = 0
                        ENDIF
                    NEXT

                    JAR_CACHE_IDX%[JAR_RESULT%] = JarIndex%
                    JAR_CACHE_POS&[JAR_RESULT%] = FoundPosition&
                    JAR_CACHE_CRC%[JAR_RESULT%] = TargetCRC16%
                    JAR_H%[JAR_RESULT%] = 0

                    FCLOSE(F%)
                    EXIT SUB
                ENDIF

                Offset& = FPOS(F%)
                Offset& = Offset& + LocalHeader.CompressedSize&
                FSEEK(F%, Offset&)
            ELSE
                EXIT WHILE
            ENDIF
        WEND
    ENDIF

    FCLOSE(F%)
END SUB

SUB JarCacheFree()
    FOR I% = 1 TO %MAX_JAR_CACHE
        FOUND% = 0
        FOR P% = 1 TO %MAX_PROCESS
            IF PROCESS_FILE%[P%] > 0 THEN
                CP% = PROCESS_CPOOL%[P%]
                IF CP_JAR%[CP%] = I% THEN
                    FOUND% = 1
                    EXIT FOR
                ENDIF
            ENDIF
        NEXT
        IF FOUND% = 0 THEN
            JAR_CACHE_IDX%[I%] = 0
            JAR_CACHE_CRC%[I%] = 0
            JAR_CACHE_POS&[I%] = 0
            JAR_H%[I%] = 0
            JAR_RESULT% = I%
            EXIT SUB
        ENDIF
    NEXT

    JAR_RESULT% = 0
    PRINT "Out of jar cache space\r\n"
    END
END SUB
