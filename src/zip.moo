SUB ZipFind (JarIndex%, ClassName$)
    JAR_RESULT% = 0

    CALL CalcCRC16 (ClassName$)
    TargetCRC16% = CalculatedCRC16%
   'PRINT "CRC: " + ClassName$ + ", " + TargetCRC16% + "\r\n"

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

    CurrentJar$ = JAR_FILES$[JarIndex%]
    F% = FOPEN(CurrentJar$)

    WHILE FEOF(F%) = FALSE
        Entry^ = FGET(F%)
        IF Entry.Signature& = 04034B50h THEN
            CurrentName$ = SPACE(Entry.FileNameLength%)
            CurrentName$ = FGET(F%)

            Offset& = FPOS(F%)
            Offset& = Offset& + Entry.ExtraFieldLength%
            FSEEK(F%, Offset&)

            IF CurrentName$ = ClassName$ THEN
               'PRINT "Found: " + CurrentName$ + ", " + ClassName$ + "\r\n"
                FoundPosition& = FPOS(F%)

                JAR_CACHE_COUNT% = JAR_CACHE_COUNT% + 1
               'PRINT "JAR_CACHE_COUNT: " + JAR_CACHE_COUNT% + "\r\n"
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
            Offset& = Offset& + Entry.CompressedSize&
            FSEEK(F%, Offset&)
        ELSE
            EXIT WHILE
        ENDIF
    WEND
    FCLOSE(F%)
END SUB
