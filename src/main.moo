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
        IF JAR_RESULT% > 0 THEN
            PRINT "Jar found: " + JAR_RESULT% + "\r\n"
            CALL ZipFind(i%, TargetFile$)
            PRINT "Jar found (cache): " + JAR_RESULT% + "\r\n"
            JarIdx% = JAR_CACHE_IDX%[JAR_RESULT%]
            PRINT "Jar ID: " + JarIdx% + "\r\n"
            JarFile$ = JAR_FILES$[JarIdx%]
            PRINT "Jar FILE: " + JarFile$ + "\r\n"
            Pos& = JAR_CACHE_POS&[JAR_RESULT%]
            PRINT "Jar POS: " + Pos& + "\r\n"
            F% = FOPEN(JarFile$)
            FSEEK(F%, Pos&)
            CALL ParseClass(F%)
            CALL ReadConstantPool(F%, JAR_RESULT%)
            PRINT "CP_PTR: " + CP_CACHE%[JAR_RESULT%] + "\r\n"
            PRINT "CP_COUNT: " + CP_COUNT% + "\r\n"
            Pos& = JAR_CACHE_POS&[JAR_RESULT%]
            FSEEK(F%, Pos&)
            CALL ParseClass(F%)
            CALL ReadConstantPool(F%, JAR_RESULT%)
            PRINT "CP_PTR (cache): " + CP_CACHE%[JAR_RESULT%] + "\r\n"
            PRINT "CP_COUNT (cache): " + CP_COUNT% + "\r\n"
            CALL ReadU(F%, 2) 'Ignore access flags
            CALL ReadU(F%, 2) 'Ignore this class index
            CALL ReadU(F%, 2) 'Ignore super class index
            CALL ReadU(F%, 2) 'Ignore interfaces count (@todo : fail if not 0)
            PRINT "Interfaces count: " + U2% + "\r\n"
            CALL ReadU(F%, 2) 'Ignore fields count (@todo : fail if not 0)
            PRINT "Fields count: " + U2% + "\r\n"
            Call SearchMethodCode(F%, JAR_RESULT%, "main([Ljava/lang/String;)V")
            PRINT "METHOD_CACHE_IDX: " + METHOD_CACHE_IDX% + "\r\n"
            Call SearchMethodCode(F%, JAR_RESULT%, "main([Ljava/lang/String;)V")
            PRINT "METHOD_CACHE_IDX (cache): " + METHOD_CACHE_IDX% + "\r\n"
            EXIT SUB
        ENDIF
    NEXT
END SUB
