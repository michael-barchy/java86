SUB ZipFind (JarIndex%, ClassName$)
    JAR_RESULT% = 0

    CALL CalcCRC16(ClassName$)
    TargetCRC16% = CalculatedCRC16%

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
                        IF JAR_CACHE_COUNT% > %MAX_JAR_CACHE THEN
                            JAR_CACHE_COUNT% = 1
                        ENDIF

                        JAR_RESULT% = JAR_CACHE_COUNT%

                        PTR% = CP_CACHE%[JAR_RESULT%]
                        IF PTR% > 0 THEN
                            MFREE(PTR%)
                            CP_CACHE%[JAR_RESULT%] = 0
                            CP_POS&[JAR_RESULT%] = 0
                        ENDIF

                        JAR_CACHE_IDX%[JAR_RESULT%] = JarIndex%
                        JAR_CACHE_POS&[JAR_RESULT%] = FoundPosition&
                        JAR_CACHE_CRC%[JAR_RESULT%] = TargetCRC16%

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
                CurrentName$ = SPACE(LocalHeader.FileNameLength%)
                CurrentName$ = FGET(F%)

                Offset& = FPOS(F%)
                Offset& = Offset& + LocalHeader.ExtraFieldLength%
                FSEEK(F%, Offset&)

                IF CurrentName$ = ClassName$ THEN
                    FoundPosition& = FPOS(F%)

                    JAR_CACHE_COUNT% = JAR_CACHE_COUNT% + 1
                    IF JAR_CACHE_COUNT% > %MAX_JAR_CACHE THEN
                        JAR_CACHE_COUNT% = 1
                    ENDIF

                    JAR_RESULT% = JAR_CACHE_COUNT%

                    PTR% = CP_CACHE%[JAR_RESULT%]
                    IF PTR% > 0 THEN
                        MFREE(PTR%)
                        CP_CACHE%[JAR_RESULT%] = 0
                        CP_POS&[JAR_RESULT%] = 0
                    ENDIF

                    JAR_CACHE_IDX%[JAR_RESULT%] = JarIndex%
                    JAR_CACHE_POS&[JAR_RESULT%] = FoundPosition&
                    JAR_CACHE_CRC%[JAR_RESULT%] = TargetCRC16%

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
