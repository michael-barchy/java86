SUB NewProcess(ClassName$, MethodDescription$, ParentId%)
    PID% = 0
    FOR I% = 1 TO %MAX_PROCESS
        IF PROCESS_FILE%[I%] = 0 THEN
            PID% = I%
            EXIT FOR
        ENDIF
    NEXT
    IF PID% = 0 THEN
        'PRINT "Out of process space\r\n"
        END
    ENDIF
    TargetFile$ = ClassName$ + ".class" '@todo - replace '.' with '/'
    'PRINT "Target file: " + TargetFile$ + "\r\n"
    FOR JarIdx% = 1 TO JAR_COUNT%
        CALL GetJarFile(JarIdx%)
        'PRINT "Looking into " + JAR_FILE$ + "\r\n"
        CALL ZipFind(JarIdx%, TargetFile$)
        IF JAR_RESULT% > 0 THEN
            'PRINT "Jar found: " + JAR_RESULT% + "\r\n"
            'CALL ZipFind(JarIdx%, TargetFile$)
            'JarIdx% = JAR_CACHE_IDX%[JAR_RESULT%]
            'JarIdx% = i%
            'PRINT "Jar ID: " + JarIdx% + "\r\n"
            'PRINT "Jar found (cache): " + JAR_RESULT% + "\r\n"
            JarIdx% = JAR_CACHE_IDX%[JAR_RESULT%]
            'JarIdx% = i%
            'PRINT "Jar ID (cache): " + JarIdx% + "\r\n"
            CALL GetJarFile(JarIdx%)
            'PRINT "Jar FILE: " + JAR_FILE$ + "\r\n"
            Pos& = JAR_CACHE_POS&[JAR_RESULT%]
            'PRINT "Jar POS: " + Pos& + "\r\n"
            'PRINT "Free memory: " + freemem(0) + "\r\n"
            F% = FOPEN(JAR_FILE$)
            FSEEK(F%, Pos&)
            CALL ParseClass(F%)
            CALL ReadConstantPool(F%, JAR_RESULT%)
            'PRINT "CP_PTR: " + CP_CACHE%[JAR_RESULT%] + "\r\n"
            'PRINT "CP_COUNT: " + CP_COUNT% + "\r\n"
            'Pos& = JAR_CACHE_POS&[JAR_RESULT%]
            'FSEEK(F%, Pos&)
            'CALL ParseClass(F%)
            'CALL ReadConstantPool(F%, JAR_RESULT%)
            'PRINT "CP_PTR (cache): " + CP_CACHE%[JAR_RESULT%] + "\r\n"
            'PRINT "CP_COUNT (cache): " + CP_COUNT% + "\r\n"
            CALL ReadU(F%, 2) 'Ignore access flags
            CALL ReadU(F%, 2) 'Ignore this class index
            CALL ReadU(F%, 2) 'Ignore super class index
            CALL ReadU(F%, 2) 'Ignore interfaces count (@todo : fail if not 0)
            'PRINT "Interfaces count: " + U2% + "\r\n"
            CALL ReadU(F%, 2) 'Ignore fields count (@todo : fail if not 0)
            'PRINT "Fields count: " + U2% + "\r\n"
            Call SearchMethodCode(F%, JAR_RESULT%, MethodDescription$)
            'PRINT "METHOD_CACHE_IDX: " + METHOD_CACHE_IDX% + "\r\n"
            Call SearchMethodCode(F%, JAR_RESULT%, MethodDescription$)
            'PRINT "METHOD_CACHE_IDX (cache): " + METHOD_CACHE_IDX% + "\r\n"
            POS& = METHOD_CACHE_POS&[METHOD_CACHE_IDX%]
            'PRINT "Method code found at position: " + POS& + "\r\n"
            CODE_END% = METHOD_CACHE_LEN%[METHOD_CACHE_IDX%]
            CODE_END% = CODE_END% - 1
            CODE_OFFSET% = 0
            PROCESS_FILE%[PID%] = F%
            PROCESS_METHOD%[PID%] = METHOD_CACHE_IDX%
            PROCESS_CODE_OFFSET%[PID%] = 0
            PROCESS_CODE_END%[PID%] = CODE_END%
            PROCESS_PARENT%[PID%] = ParentId%
            STACK_PTR_SIZE% = %MAX_STACK * 2
            STACK_PTR_SIZE% = STACK_PTR_SIZE% + 2
            PROCESS_STACK_PTR%[PID%] = MALLOC(STACK_PTR_SIZE%)
            MEMSETW(0, PROCESS_STACK_PTR%[PID%], 1)
            LOCALS_PTR_SIZE% = %MAX_LOCALS * 2
            PROCESS_LOCALS_PTR%[PID%] = MALLOC(LOCALS_PTR_SIZE%)
            MEMSETW(0, PROCESS_LOCALS_PTR%[PID%], 1)
            PROCESS_ID% = PID%
            EXIT SUB
        ENDIF
    NEXT
END SUB
