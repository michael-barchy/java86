SUB ZipFind (JarIndex%, ClassName$)
    CALL CalcCRC16 (ClassName$)
    TargetCRC16% = CalculatedCRC16%
    SearchResult% = 0

    FOR j% = 1 TO 10
        ValidIdx% = (CacheJarIdx%[j%] > 0)
        MatchCRC% = (CacheCRC16%[j%] = TargetCRC16%)
        IF ValidIdx% THEN
            IF MatchCRC% THEN
                FoundPosition& = CachePos&[j%]
                SearchResult% = 1
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

                CachePtr% = CachePtr% + 1
                IF CachePtr% > 10 THEN
                    CachePtr% = 1
                ENDIF

                SearchResult% = CachePtr%

                CacheJarIdx%[CachePtr%] = JarIndex%
                CachePos&[CachePtr%] = FoundPosition&
                CacheCRC16%[CachePtr%] = TargetCRC16%

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
