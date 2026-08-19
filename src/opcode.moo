SUB RunCode(F%, MethodIdx%, Offset%)
    'PRINT "METHOD_CACHE_IDX: " + MethodIdx% + "\r\n"
    JarIdx% = METHOD_CACHE_FILE_IDX%[MethodIdx%]
    'PRINT "METHOD_CACHE_FILE_IDX: " + JarIdx% + "\r\n"
    OLD_POS& = FPOS(F%)
    CODE_OFFSET% = -1
    POS& = METHOD_CACHE_POS&[MethodIdx%]
    'PRINT "METHOD_CACHE_POS: " + POS& + "\r\n"
    POS& = POS& + Offset%
    'PRINT "POS: " + POS& + "\r\n"
    FSEEK(F%, POS&)
    CALL ReadU(F%, 1)
    OPCODE% = U1%
    'PRINT "OPCODE: " + PROCESS_ID% + ", " + Offset% + ", " + OPCODE% + "\r\n"
    IF OPCODE% >= %OPCODE_ICONST_0 THEN
        IF OPCODE% <= %OPCODE_ICONST_5 THEN
            VALUE% = OPCODE% - %OPCODE_ICONST_0
            CALL StackPush(VALUE%, %TYPE_INT)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_LDC THEN
        CALL ReadU(F%, 1)
        INDEX% = U1%
        CALL GetConstantPoolEntry(JarIdx%, INDEX%, F%)
        CALL GetConstantPoolEntry(JarIdx%, CP_ENTRY%, F%)
        'PRINT "LDC: " + INDEX% + ", " + CP_ENTRY% + ", " + CP_ENTRY$ + "\r\n"
        CALL StackPushString(CP_ENTRY$)
        POS& = FPOS(F%)
        CODE_OFFSET% = POS& - OLD_POS&
    ENDIF
    IF OPCODE% = %OPCODE_ILOAD THEN
        CALL ReadU(F%, 1)
        INDEX% = U1%
        CALL LocalGet(INDEX%)
        CALL StackPush(LocalValue%, %TYPE_INT)
        'PRINT "ILOAD: " + INDEX% + ", " + LocalValue% + "\r\n"
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% >= %OPCODE_ALOAD_0 THEN
        IF OPCODE% <= %OPCODE_ALOAD_3 THEN
            Index% = OPCODE% - %OPCODE_ALOAD_0
            CALL LocalGetString(Index%)
            CALL StackPushString(LocalValue$)
            'PRINT "ALOAD: " + Index% + ", " + LocalValue$ + "\r\n"
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_BALOAD THEN
        CALL StackPop()
        Index% = StackValue% + 1
        CALL StackPopString()
        C$ = MID(StackValue$, Index%, 1)
        C% = ASC(C$)
        CALL StackPush(C%, %TYPE_INT)
        'PRINT "BALOAD: " + Index% + ", " + StackValue$ + ", " + C$ + ", " + C% + "\r\n"
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_ISTORE THEN
        CALL ReadU(F%, 1)
        Index% = U1%
        CALL StackPop()
        CALL LocalSet(Index%, StackValue%, %TYPE_INT)
        'PRINT "ISTORE: " + Index% + ", " + StackValue% + "\r\n"
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% >= %OPCODE_ASTORE_0 THEN
        IF OPCODE% <= %OPCODE_ASTORE_3 THEN
            Index% = OPCODE% - %OPCODE_ASTORE_0
            CALL StackPopString()
            CALL LocalSetString(Index%, StackValue$)
            'PRINT "ASTORE: " + Index% + ", " + StackValue$ + "\r\n"
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IINC THEN
        CALL ReadU(F%, 1)
        Index% = U1%
        CALL ReadU(F%, 1)
        Inc% = U1%
        CALL LocalGet(Index%)
        'PRINT "IINC: " + Index% + ", " + LocalValue% + ", " + Inc% + "\r\n"
        LocalValue% = LocalValue% + Inc%
        CALL LocalSet(Index%, LocalValue%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF OPCODE% = %OPCODE_IFEQ THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        'PRINT "OPCODE_IFEQ: " + StackValue% + " = 0 ?\r\n"
        IF StackValue% = 0 THEN
            'PRINT "IFEQ OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = POS& - OLD_POS&
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IFNE THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        'PRINT "OPCODE_IFNE: " + StackValue% + " = 0 ?\r\n"
        IF StackValue% <> 0 THEN
            'PRINT "IFNE OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = POS& - OLD_POS&
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ICMPEQ THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        'PRINT "OPCODE_IF_ICMPEQ: " + STACK_POP1% + " = " + STACK_POP2% + " ?\r\n"
        IF STACK_POP1% = STACK_POP2% THEN
            'PRINT "IF_ICMPEQ OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 2
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ICMPLT THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        'PRINT "OPCODE_IF_ICMPLT: " + STACK_POP1% + " < " + STACK_POP2% + " ?\r\n"
        IF STACK_POP1% < STACK_POP2% THEN
            'PRINT "IF_ICMPLT OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ACMPEQ THEN
        CALL ReadU(F%, 2)
        CALL StackPopString()
        STACK_POP1% = StackValue%
        STACK_POP1$ = StackValue$
        CALL StackPopString()
        STACK_POP2% = StackValue%
        STACK_POP2$ = StackValue$
        IF_ACMPEQ% = 0
        IF STACK_POP1% = STACK_POP2% THEN
            IF_ACMPEQ% = 1
        ELSE
            IF STACK_POP1$ = STACK_POP2$ THEN
                IF_ACMPEQ% = 1
            ENDIF
        ENDIF
        'PRINT "OPCODE_IF_ACMPEQ: " + STACK_POP1$ + " = " + STACK_POP2$ + " ?\r\n"
        IF IF_ACMPEQ% = 1 THEN
            'PRINT "IF_ACMPEQ OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ACMPNE THEN
        CALL ReadU(F%, 2)
        CALL StackPopString()
        STACK_POP1% = StackValue%
        STACK_POP1$ = StackValue$
        CALL StackPopString()
        STACK_POP2% = StackValue%
        STACK_POP2$ = StackValue$
        IF_ACMPNE% = 0
        IF STACK_POP1% <> STACK_POP2% THEN
            IF STACK_POP1$ <> STACK_POP2$ THEN
                IF_ACMPNE% = 1
            ENDIF
        ENDIF
        'PRINT "OPCODE_IF_ACMPNE: " + STACK_POP1$ + " <> " + STACK_POP2$ + " ?\r\n"
        IF IF_ACMPNE% = 1 THEN
            'PRINT "IF_ACMPNE OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_GOTO THEN
        CALL ReadU(F%, 2)
        'PRINT "GOTO OFFSET: " + U2% + "\r\n"
        CODE_OFFSET% = Offset% + U2%
    ENDIF
    IF OPCODE% = %OPCODE_IRETURN THEN
        CALL StackPop()
        'PRINT "IRETURN: " + StackValue% + "\r\n"
        ParentId% = PROCESS_PARENT%[PROCESS_ID%]
        FCLOSE(F%)
        CALL KillProcess()
        CODE_OFFSET% = Offset% + 1
        PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
        IF ParentId% > 0 THEN
            PROCESS_ID% = ParentId%
            CALL StackPush(StackValue%, %TYPE_INT)
            PROCESS_IDLE%[PROCESS_ID%] = 0
        ENDIF
        EXIT SUB
    ENDIF
    IF OPCODE% = %OPCODE_RETURN THEN
        ParentId% = PROCESS_PARENT%[PROCESS_ID%]
        FCLOSE(F%)
        CALL KillProcess()
        CODE_OFFSET% = Offset% + 1
        PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
        'PRINT "RETURN: " + PROCESS_ID% + ", " + ParentId% + "\r\n"
        IF ParentId% > 0 THEN
            PROCESS_ID% = ParentId%
            PROCESS_IDLE%[PROCESS_ID%] = 0
        ENDIF
        EXIT SUB
    ENDIF
    IF OPCODE% = %OPCODE_INVOKE_STATIC THEN
        CALL ReadU(F%, 2)
        METHOD_REF% = U2%
        CALL GetConstantPoolEntry(JarIdx%, METHOD_REF%, F%) 'MethodRef
        NAME_TYPE% = CP_ENTRY2%
        CALL GetConstantPoolEntry(JarIdx%, CP_ENTRY%, F%) 'Class
        CALL GetConstantPoolEntry(JarIdx%, CP_ENTRY%, F%) 'String
        ClassName$ = CP_ENTRY$
        'PRINT "NAME_TYPE: " + NAME_TYPE% + "\r\n"
        CALL GetConstantPoolEntry(JarIdx%, NAME_TYPE%, F%) 'NameAndType
        DESCRIPTOR% = CP_ENTRY2%
        CALL GetConstantPoolEntry(JarIdx%, CP_ENTRY%, F%) 'MethodName
        MethodName$ = CP_ENTRY$
        CALL GetConstantPoolEntry(JarIdx%, DESCRIPTOR%, F%)
        MethodRef$ = MethodName$ + CP_ENTRY$
        IF ClassName$ <> "Native" THEN
            '@todo - invoke other class method (non-native)
            Call StackPopString()
            STACK_POP2$ = StackValue$
            STACK_POP2% = StackValue%
            Call StackPopString()
            STACK_POP1$ = StackValue$
            STACK_POP1% = StackValue%
            PROCESS_IDLE%[PROCESS_ID%] = 1
            CODE_OFFSET% = Offset% + 3
            PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
            ParentId% = PROCESS_ID%
            'PRINT "InvokeStatic: " + PROCESS_ID% + ", " + ClassName$ + "." + MethodRef$ + "(" + STACK_POP1$ + ", " + STACK_POP2$ + ")\r\n"
            CALL NewProcess(ClassName$, MethodRef$, ParentId%)
            CALL LocalSetString(0, STACK_POP1$)
            CALL LocalSetString(1, STACK_POP2$)
            PROCESS_ID% = ParentId%
            CODE_OFFSET% = PROCESS_CODE_OFFSET%[PROCESS_ID%]
        ELSE
            MethodRef$ = ClassName$ + "." + MethodRef$
            'PRINT MethodRef$ + "\r\n"
        ENDIF
        IF MethodRef$ = "Native.print(Ljava/lang/String;)V" THEN
            CALL StackPopString()
            PRINT StackValue$
            POS% = INSTR(StackValue$, "\r\n")
            LEN% = LEN(StackValue$) - 2
            IF POS% = LEN% THEN
                'PRINT "Free memory: " + FREEMEM(0) + "\r\n"
            ENDIF
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF MethodRef$ = "Native.input()Ljava/lang/String;" THEN
            INPUT STACK_PUSH$
            CALL StackPushString(STACK_PUSH$)
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF MethodRef$ = "Native.getBytes(Ljava/lang/String;)[B" THEN
            CALL StackPopString()
            BYTES$ = StackValue$
            'PRINT "getBytes: ***" + BYTES$ + "***\r\n"
            CALL StackPushString(BYTES$)
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF CODE_OFFSET% = -1 THEN
           'PRINT "INVOKE_STATIC: " + METHOD_REF% + ", " + MethodRef$ + "\r\n"
            END
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_ARRAYLENGTH THEN
        CALL StackPopString()
        ArrayLen% = LEN(StackValue%)
        'PRINT "ArrayLength: " + ArrayLen% + "\r\n"
        CALL StackPush(ArrayLen%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF CODE_OFFSET% = -1 THEN
        PRINT "UNSUPPORTED OPCODE: " + OPCODE% + "\r\n"
        END
    ENDIF
    FSEEK(F%, OLD_POS&)
END SUB

SUB StackPush(Value%, Type@)
    STACK_PTR% = PROCESS_STACK_PTR%[PROCESS_ID%]
    STACK_SIZE% = MGET(STACK_PTR%)
    STACK_OFFSET% = STACK_SIZE% * %STACK_ENTRY_SIZE
    STACK_OFFSET% = STACK_OFFSET% + STACK_PTR%
    STACK_OFFSET% = STACK_OFFSET% + 2 'First word = Stack size
    MEMSETB(Type@, STACK_OFFSET%, 1)
    STACK_OFFSET% = STACK_OFFSET% + 1
    MEMSETW(Value%, STACK_OFFSET%, 1)
    STACK_SIZE% = STACK_SIZE% + 1
    MEMSETW(STACK_SIZE%, STACK_PTR%, 1)
    'PRINT "StackPush: " + Value% + ", " + STACK_PTR% + ", " + STACK_SIZE% + ", " + STACK_OFFSET% + "\r\n"
END SUB

SUB StackPushString(Value$)
    STR_LEN% = LEN(Value$)
    STR_LEN% = STR_LEN% + 2
    STR_PTR% = MALLOC(STR_LEN%)
    MEMCOPY(STRPTR(Value$), STR_PTR%, STR_LEN%)
    'PRINT "StackPushString: ***" + Value$ + "***, " + STR_PTR% + ", " + STR_LEN% + "\r\n"
    CALL StackPush(STR_PTR%, %TYPE_REF)
END SUB

SUB StackPop()
    STACK_PTR% = PROCESS_STACK_PTR%[PROCESS_ID%]
    STACK_SIZE% = MGET(STACK_PTR%)
    STACK_SIZE% = STACK_SIZE% - 1
    STACK_OFFSET% = STACK_SIZE% * %STACK_ENTRY_SIZE
    STACK_OFFSET% = STACK_OFFSET% + STACK_PTR%
    STACK_OFFSET% = STACK_OFFSET% + 2 'First word = Stack size
    STACK_OFFSET% = STACK_OFFSET% + 1 'Ignore type
    StackValue% = MGET(STACK_OFFSET%)
    StackValue$ = STR(StackValue%)
    MEMSETW(STACK_SIZE%, STACK_PTR%, 1)
    'PRINT "StackPop: " + STACK_PTR% + ", " + STACK_SIZE% + ", " + STACK_OFFSET% + ", " + StackValue% + "\r\n"
END SUB

SUB StackPopString()
    CALL StackPop()
    STR_PTR% = StackValue%
    STR_LEN% = MGET(STR_PTR%)
    StackValue$ = SPACE(STR_LEN%)
    STR_LEN% = STR_LEN% + 2
    MEMCOPY(STR_PTR%, STRPTR(StackValue$), STR_LEN%)
    MFREE(STR_PTR%)
    'PRINT "StackPopString: ***" + STR_PTR% + "***, " + STR_LEN% + ", " + StackValue% + "\r\n"
END SUB

SUB LocalSet(Index%, Value%, Type@)
    LOCALS_PTR% = PROCESS_LOCALS_PTR%[PROCESS_ID%]
    LOCALS_OFFSET% = Index% * %LOCALS_ENTRY_SIZE
    LOCALS_OFFSET% = LOCALS_OFFSET% + LOCALS_PTR%
    LOCALS_TYPE$ = SPACE(1)
    LOCALS_TYPE$ = MGET(LOCALS_OFFSET%)
    LOCALS_TYPE% = ASC(LOCALS_TYPE$)
    IF LOCALS_TYPE% = %TYPE_REF THEN
        LOCALS_OFFSET% = LOCALS_OFFSET% + 1
        STR_PTR% = MGET(LOCALS_OFFSET%)
        IF STR_PTR% > 0 THEN
            'PRINT "Free locals: " + LOCALS_TYPE% + ", " + STR_PTR% + "\r\n"
            MFREE(STR_PTR%)
        ENDIF
        LOCALS_OFFSET% = LOCALS_OFFSET% - 1
    ENDIF
    MEMSETB(Type@, LOCALS_OFFSET%, 1)
    LOCALS_OFFSET% = LOCALS_OFFSET% + 1
    MEMSETW(Value%, LOCALS_OFFSET%, 1)
    'PRINT "LocalSet: " + Index% + ", " + Value% + ", " + LOCALS_PTR% + ", " + LOCALS_OFFSET% + "\r\n"
END SUB

SUB LocalSetString(Index%, Value$)
    STR_LEN% = LEN(Value$)
    STR_LEN% = STR_LEN% + 2
    STR_PTR% = MALLOC(STR_LEN%)
    MEMCOPY(STRPTR(Value$), STR_PTR%, STR_LEN%)
    'PRINT "LocalSetString: " + Index% + ", ***" + Value$ + "***, " + STR_LEN% + ", " + STR_PTR% + "\r\n"
    CALL LocalSet(Index%, STR_PTR%, %TYPE_REF)
END SUB

SUB LocalGet(Index%)
    LOCALS_PTR% = PROCESS_LOCALS_PTR%[PROCESS_ID%]
    LOCALS_OFFSET% = Index% * %LOCALS_ENTRY_SIZE
    LOCALS_OFFSET% = LOCALS_OFFSET% + LOCALS_PTR%
    LOCALS_OFFSET% = LOCALS_OFFSET% + 1 'Ignore type
    LocalValue% = MGET(LOCALS_OFFSET%)
    'PRINT "LocalGet: " + Index% + ", " + LOCALS_PTR% + ", " + LOCALS_OFFSET% + ", " + LocalValue% + "\r\n"
END SUB

SUB LocalGetString(Index%)
    CALL LocalGet(Index%)
    STR_PTR% = LocalValue%
    STR_LEN% = MGET(STR_PTR%)
    LocalValue$ = SPACE(STR_LEN%)
    STR_LEN% = STR_LEN% + 2
    MEMCOPY(STR_PTR%, STRPTR(LocalValue$), STR_LEN%)
    'PRINT "LocalGetString: " + Index% + ", " + STR_PTR% + ", " + STR_LEN% + ", ***" + LocalValue$ + "***\r\n"
END SUB
