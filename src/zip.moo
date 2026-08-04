SUB ZipFind (JarIndex%, ClassName$)
    CALL CalcCRC16 (ClassName$)
    TargetCRC16% = CalculatedCRC16%
    JAR_RESULT% = 0

    FOR i% = 1 TO 10
        ValidIdx% = JAR_CACHE_IDX%[i%] > 0
        MatchCRC% = JAR_CACHE_CRC%[i%] = TargetCRC16%
        IF ValidIdx% THEN
            IF MatchCRC% THEN
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
                FoundPosition& = FPOS(F%)

                JAR_RESULT% = JAR_RESULT% + 1
                IF JAR_RESULT% > 10 THEN
                    JAR_RESULT% = 1
                ENDIF

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
