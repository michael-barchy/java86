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
            EXIT SUB
        ENDIF
    NEXT
END SUB
