SUB Java ()
    CALL ParseCmd
    IF JAR_COUNT% > 0 THEN
        FOR I% = 1 TO JAR_COUNT%
            PRINT "Jar file: " + JAR_FILES$[I%] + "\r\n"
        NEXT
    ENDIF
    PRINT "Target class: " + TARGET_CLASS$ + "\r\n"
    TargetFile$ = TARGET_CLASS$ + ".class"
    PRINT "Target file: " + TargetFile$ + "\r\n"
    FOR i% = 1 TO JAR_COUNT%
        CALL ZipFind(i%, TargetFile$)
        IF SearchResult% = 1 THEN
            PRINT SearchResult% + ", " + FoundPosition& + "\r\n"
            JarId% = CacheJarIdx%[SearchResult%]
            PRINT "Jar ID: " + JarId% + "\r\n"
            JarFile$ = JAR_FILES$[JarId%]
            PRINT "Jar FILE: " + JarFile$ + "\r\n"
            Pos& = CachePos&[JarId%]
            PRINT "Jar POS: " + Pos& + "\r\n"
            F% = FOPEN(JarFile$)
            FSEEK(F%, Pos&)
            CALL ParseClass(F%)
            CALL READ_CONSTANT_POOL(F%, 0)
            PRINT "CP_COUNT: " + CP_COUNT% + "\r\n"
            EXIT SUB
        ENDIF
    NEXT
END SUB
