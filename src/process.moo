SUB NewProcess(ClassName$, MethodDescription$, ParentId%)
    PID% = 0
    FOR I% = 1 TO %MAX_PROCESS
        IF PROCESS_FILE%[I%] = 0 THEN
            PID% = I%
            EXIT FOR
        ENDIF
    NEXT
    IF PID% = 0 THEN
        PRINT "Out of process space\r\n"
        END
    ENDIF
    TargetFile$ = ClassName$ + ".class" '@todo - replace '.' with '/'
    FOR JarIdx% = 1 TO JAR_COUNT%
        CALL GetJarFile(JarIdx%)
        CALL ZipFind(JarIdx%, TargetFile$)
        IF JAR_RESULT% > 0 THEN
            JarIdx% = JAR_CACHE_IDX%[JAR_RESULT%]
            CALL GetJarFile(JarIdx%)
            Pos& = JAR_CACHE_POS&[JAR_RESULT%]
            H% = JAR_H%[JAR_RESULT%]
            IF H% > 0 THEN
                F% = H%
            ELSE
                F% = FOPEN(JAR_FILE$)
                JAR_H%[JAR_RESULT%] = F%
            ENDIF
            FSEEK(F%, Pos&)
            CALL ParseClass(F%)
            CALL ReadConstantPool(F%, JAR_RESULT%, ClassName$)
            CALL ReadU(F%, 2) 'Ignore access flags
            CALL ReadU(F%, 2) 'Ignore this class index
            CALL ReadU(F%, 2) 'Ignore super class index
            CALL ReadU(F%, 2) 'Ignore interfaces count (@todo : fail if not 0)
            CALL ReadU(F%, 2) 'Ignore fields count (@todo : fail if not 0)
            Call SearchMethodCode(F%, JAR_RESULT%, ClassName$, MethodDescription$)
            POS& = METHOD_CACHE_POS&[METHOD_CACHE_IDX%]
            CODE_END% = METHOD_CACHE_LEN%[METHOD_CACHE_IDX%]
            CODE_END% = CODE_END% - 1
            CODE_OFFSET% = 0
            PROCESS_FILE%[PID%] = F%
            PROCESS_CPOOL%[PID%] = CP_IDX%
            PROCESS_METHOD%[PID%] = METHOD_CACHE_IDX%
            PROCESS_CODE_OFFSET%[PID%] = 0
            PROCESS_CODE_END%[PID%] = CODE_END%
            PROCESS_PARENT%[PID%] = ParentId%
            STACK_PTR_SIZE% = %MAX_STACK * %STACK_ENTRY_SIZE
            STACK_PTR_SIZE% = STACK_PTR_SIZE% + 2 'First word = Stack size
            PROCESS_STACK_PTR%[PID%] = MALLOC(STACK_PTR_SIZE%)
            MEMSETB(0, PROCESS_STACK_PTR%[PID%], STACK_PTR_SIZE%)
            LOCALS_PTR_SIZE% = %MAX_LOCALS * %LOCALS_ENTRY_SIZE
            PROCESS_LOCALS_PTR%[PID%] = MALLOC(LOCALS_PTR_SIZE%)
            MEMSETB(0, PROCESS_LOCALS_PTR%[PID%], LOCALS_PTR_SIZE%)
            PROCESS_ID% = PID%
            EXIT SUB
        ENDIF
    NEXT
END SUB

SUB KillProcess(PID%, ReturnType@, ReturnValue%)
    ParentId% = PROCESS_PARENT%[PID%]

    PROCESS_FILE%[PID%] = 0
    PROCESS_CPOOL%[PID%] = 0

    'Free stack strings
    STACK_PTR% = PROCESS_STACK_PTR%[PID%]
    STACK_SIZE% = MGET(STACK_PTR%)
    IF STACK_SIZE% > 0 THEN
        FOR I% = 1 TO STACK_SIZE%
            STACK_OFFSET% = I% - 1
            STACK_OFFSET% = STACK_OFFSET% * %STACK_ENTRY_SIZE
            STACK_OFFSET% = STACK_OFFSET% + STACK_PTR%
            STACK_OFFSET% = STACK_OFFSET% + 2 'First word = Stack size
            B$ = CHR(0)
            B$ = MGET(STACK_OFFSET%)
            B% = ASC(B$)
            StackType@ = ASC(B$)
            IF StackType@ = %TYPE_REF THEN
                MEMSETB(%TYPE_INT, STACK_OFFSET%, 1)
                STACK_OFFSET% = STACK_OFFSET% + 1
                STACK_REF% = MGET(STACK_OFFSET%)
                KeepStack% = 0
                IF ReturnType@ = %TYPE_REF THEN
                    IF STACK_REF% = ReturnValue% THEN
                        KeepStack% = 1
                    ENDIF
                ENDIF
                IF KeepStack% = 0 THEN
                    CALL CheckRef(STACK_REF%)
                    KeepStack% = REF_USED%
                ENDIF
                IF KeepStack% = 0 THEN
                    IF STACK_REF% > 0 THEN
                        MEMSETW(0, STACK_OFFSET%, 1)
                        MFREE(STACK_REF%)
                    ENDIF
                ELSE
                    STACK_OFFSET% = STACK_OFFSET% - 1
                    MEMSETB(%TYPE_REF, STACK_OFFSET%, 1)
                ENDIF
            ENDIF
        NEXT
    ENDIF
    IF STACK_PTR% > 0 THEN
        MFREE(STACK_PTR%)
        PROCESS_STACK_PTR%[PID%] = 0
    ENDIF

    'Free locals strings
    LOCALS_PTR% = PROCESS_LOCALS_PTR%[PID%]
    FOR I% = 1 TO %MAX_LOCALS
        LOCALS_OFFSET% = I%  - 1
        LOCALS_OFFSET% = LOCALS_OFFSET% * %LOCALS_ENTRY_SIZE
        LOCALS_OFFSET% = LOCALS_OFFSET% + LOCALS_PTR%
        B$ = CHR(0)
        B$ = MGET(LOCALS_OFFSET%)
        B% = ASC(B$)
        LocalsType@ = B%
        IF LocalsType@ = %TYPE_REF THEN
            MEMSETB(%TYPE_INT, LOCALS_OFFSET%, 1)
            LOCALS_OFFSET% = LOCALS_OFFSET% + 1
            LOCALS_REF% = MGET(LOCALS_OFFSET%)
            KeepLocals% = 0
            IF ReturnType@ = %TYPE_REF THEN
                IF LOCALS_REF% = ReturnValue% THEN
                    KeepLocals% = 1
                ENDIF
            ENDIF
            IF KeepLocals% = 0 THEN
                CALL CheckRef(LOCALS_REF%)
                KeepLocals% = REF_USED%
            ENDIF
            IF KeepLocals% = 0 THEN
                IF LOCALS_REF% > 0 THEN
                    MEMSETW(0, LOCALS_OFFSET%, 1)
                    MFREE(LOCALS_REF%)
                ENDIF
            ELSE
                LOCALS_OFFSET% = LOCALS_OFFSET% - 1
                MEMSETB(%TYPE_REF, LOCALS_OFFSET%, 1)
            ENDIF
        ENDIF
    NEXT
    IF LOCALS_PTR% > 0 THEN
        MFREE(LOCALS_PTR%)
        PROCESS_LOCALS_PTR%[PID%] = 0
    ENDIF

    IF ParentId% > 0 THEN
        PROCESS_ID% = ParentId%
        IF ReturnType@ <> %TYPE_NONE THEN
            CALL StackPush(ReturnValue%, ReturnType@)
        ENDIF
        PROCESS_IDLE%[PROCESS_ID%] = 0
        CODE_OFFSET% = PROCESS_CODE_OFFSET%[PROCESS_ID%]
    ENDIF
END SUB

SUB CheckRef(Ref%)
    REF_USED% = 0
    IF Ref% > 0 THEN
        FOR P% = 1 TO %MAX_PROCESS
            IF PROCESS_FILE%[P%] > 0 THEN
                STACK_PTR% = PROCESS_STACK_PTR%[P%]
                STACK_SIZE% = MGET(STACK_PTR%)
                IF STACK_SIZE% > 0 THEN
                    FOR I% = 1 TO STACK_SIZE%
                        STACK_OFFSET% = I% - 1
                        STACK_OFFSET% = STACK_OFFSET% * %STACK_ENTRY_SIZE
                        STACK_OFFSET% = STACK_OFFSET% + STACK_PTR%
                        STACK_OFFSET% = STACK_OFFSET% + 2 'First word = Stack size
                        B$ = CHR(0)
                        B$ = MGET(STACK_OFFSET%)
                        B% = ASC(B$)
                        StackType@ = B%
                        IF StackType@ = %TYPE_REF THEN
                            STACK_OFFSET% = STACK_OFFSET% + 1
                            STACK_REF% = MGET(STACK_OFFSET%)
                            IF STACK_REF% = Ref% THEN
                                REF_USED% = 1
                                EXIT SUB
                            ENDIF
                        ENDIF
                    NEXT
                ENDIF
                LOCALS_PTR% = PROCESS_LOCALS_PTR%[P%]
                FOR I% = 1 TO %MAX_LOCALS
                    LOCALS_OFFSET% = I%  - 1
                    LOCALS_OFFSET% = LOCALS_OFFSET% * %LOCALS_ENTRY_SIZE
                    LOCALS_OFFSET% = LOCALS_OFFSET% + LOCALS_PTR%
                    LOCALS_OFFSET% = LOCALS_OFFSET%
                    B$ = CHR(0)
                    B$ = MGET(LOCALS_OFFSET%)
                    B% = ASC(B$)
                    LocalsType@ = B%
                    IF LocalsType@ = %TYPE_REF THEN
                        LOCALS_OFFSET% = LOCALS_OFFSET% + 1
                        LOCALS_REF% = MGET(LOCALS_OFFSET%)
                        IF LOCALS_REF% = Ref% THEN
                            REF_USED% = 1
                            EXIT SUB
                        ENDIF
                    ENDIF
                NEXT
            ENDIF
        NEXT
    ENDIF
END SUB