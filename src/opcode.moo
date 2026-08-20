SUB RunCode(F%, MethodIdx%, Offset%)
    JarIdx% = METHOD_CACHE_FILE_IDX%[MethodIdx%]
    OLD_POS& = FPOS(F%)
    CODE_OFFSET% = -1
    POS& = METHOD_CACHE_POS&[MethodIdx%]
    POS& = POS& + Offset%
    FSEEK(F%, POS&)
    CALL ReadU(F%, 1)
    OPCODE% = U1%
    IF OPCODE% >= %OPCODE_ICONST_0 THEN
        IF OPCODE% <= %OPCODE_ICONST_5 THEN
            VALUE% = OPCODE% - %OPCODE_ICONST_0
            CALL StackPush(VALUE%, %TYPE_INT)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_BIPUSH THEN
        CALL ReadU(F%, 1)
        CALL StackPush(U1%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% = %OPCODE_SIPUSH THEN
        CALL ReadU(F%, 2)
        CALL StackPush(U2%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF OPCODE% = %OPCODE_LDC THEN
        CALL ReadU(F%, 1)
        INDEX% = U1%
        CALL GetConstantPoolEntry(CP_IDX%, INDEX%, F%)
        CALL GetConstantPoolEntry(CP_IDX%, CP_ENTRY%, F%)
        CALL StackPushString(CP_ENTRY$)
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% = %OPCODE_ILOAD THEN
        CALL ReadU(F%, 1)
        INDEX% = U1%
        CALL LocalGet(INDEX%)
        CALL StackPush(LocalValue%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% >= %OPCODE_ILOAD_0 THEN
        IF OPCODE% <= %OPCODE_ILOAD_3 THEN
            Index% = OPCODE% - %OPCODE_ILOAD_0
            CALL LocalGet(Index%)
            CALL StackPush(LocalValue%, %TYPE_INT)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% >= %OPCODE_ALOAD_0 THEN
        IF OPCODE% <= %OPCODE_ALOAD_3 THEN
            Index% = OPCODE% - %OPCODE_ALOAD_0
            CALL LocalGetString(Index%)
            CALL StackPushString(LocalValue$)
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
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_ISTORE THEN
        CALL ReadU(F%, 1)
        Index% = U1%
        CALL StackPop()
        CALL LocalSet(Index%, StackValue%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% >= %OPCODE_ISTORE_0 THEN
        IF OPCODE% <= %OPCODE_ISTORE_3 THEN
            Index% = OPCODE% - %OPCODE_ISTORE_0
            CALL StackPop()
            CALL LocalSet(Index%, StackValue%, %TYPE_INT)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% >= %OPCODE_ASTORE_0 THEN
        IF OPCODE% <= %OPCODE_ASTORE_3 THEN
            Index% = OPCODE% - %OPCODE_ASTORE_0
            CALL StackPopString()
            CALL LocalSetString(Index%, StackValue$)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_POP THEN
        CALL StackPop()
        IF STACK_TYPE% = %TYPE_REF THEN
            IF StackValue% > 0 THEN
                MFREE(StackValue%)
            ENDIF
        ENDIF
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_IINC THEN
        CALL ReadU(F%, 1)
        Index% = U1%
        CALL ReadU(F%, 1)
        Inc% = U1%
        CALL LocalGet(Index%)
        LocalValue% = LocalValue% + Inc%
        CALL LocalSet(Index%, LocalValue%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF OPCODE% = %OPCODE_IFEQ THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        IF StackValue% = 0 THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IFNE THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        IF StackValue% <> 0 THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ICMPEQ THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        IF STACK_POP1% = STACK_POP2% THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ICMPNE THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        IF STACK_POP1% <> STACK_POP2% THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ICMPLT THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        IF STACK_POP1% < STACK_POP2% THEN
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
        IF IF_ACMPEQ% = 1 THEN
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
        IF IF_ACMPNE% = 1 THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_GOTO THEN
        CALL ReadU(F%, 2)
        CODE_OFFSET% = Offset% + U2%
    ENDIF
    IF OPCODE% = %OPCODE_IRETURN THEN
        CALL StackPop()
        ParentId% = PROCESS_PARENT%[PROCESS_ID%]
        CALL KillProcess(PROCESS_ID%)
        CODE_OFFSET% = Offset% + 1
        PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
        IF ParentId% > 0 THEN
            PROCESS_ID% = ParentId%
            CALL StackPush(StackValue%, %TYPE_INT)
            PROCESS_IDLE%[PROCESS_ID%] = 0
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_RETURN THEN
        ParentId% = PROCESS_PARENT%[PROCESS_ID%]
        CALL KillProcess(PROCESS_ID%)
        CODE_OFFSET% = Offset% + 1
        PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
        IF ParentId% > 0 THEN
            PROCESS_ID% = ParentId%
            PROCESS_IDLE%[PROCESS_ID%] = 0
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_INVOKE_STATIC THEN
        CALL ReadU(F%, 2)
        METHOD_REF% = U2%
        CALL GetConstantPoolEntry(CP_IDX%, METHOD_REF%, F%) 'MethodRef
        NAME_TYPE% = CP_ENTRY2%
        CALL GetConstantPoolEntry(CP_IDX%, CP_ENTRY%, F%) 'Class
        CALL GetConstantPoolEntry(CP_IDX%, CP_ENTRY%, F%) 'String
        ClassName$ = CP_ENTRY$
        CALL GetConstantPoolEntry(CP_IDX%, NAME_TYPE%, F%) 'NameAndType
        DESCRIPTOR% = CP_ENTRY2%
        CALL GetConstantPoolEntry(CP_IDX%, CP_ENTRY%, F%) 'MethodName
        MethodName$ = CP_ENTRY$
        CALL GetConstantPoolEntry(CP_IDX%, DESCRIPTOR%, F%)
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
            CALL NewProcess(ClassName$, MethodRef$, ParentId%)
            CALL LocalSetString(0, STACK_POP1$)
            CALL LocalSetString(1, STACK_POP2$)
            PROCESS_ID% = ParentId%
            CODE_OFFSET% = PROCESS_CODE_OFFSET%[PROCESS_ID%]
        ELSE
            MethodRef$ = ClassName$ + "." + MethodRef$
        ENDIF
        IF MethodRef$ = "Native.print(Ljava/lang/String;)V" THEN
            CALL StackPopString()
            PRINT StackValue$
            POS% = INSTR(StackValue$, "\r\n")
            SLEN% = LEN(StackValue$) - 2
            IF POS% = SLEN% THEN
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
            CALL StackPushString(BYTES$)
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF MethodRef$ = "Native.newProcess(Ljava/lang/String;)I" THEN
            CALL StackPopString()
            ParentId% = PROCESS_ID%
            CALL NewProcess(StackValue$, "main([Ljava/lang/String;)V", 0)
            PROCESS_ID% = ParentId%
            CALL StackPush(PROCESS_ID%, %TYPE_INT)
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF MethodRef$ = "Native.killProcess(I)V" THEN
            CALL StackPop()
            CALL KillProcess(StackValue%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF CODE_OFFSET% = -1 THEN
            END
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_ARRAYLENGTH THEN
        CALL StackPopString()
        ArrayLen% = LEN(StackValue$)
        CALL StackPush(ArrayLen%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF CODE_OFFSET% = -1 THEN
        PRINT "UNSUPPORTED OPCODE: " + OPCODE% + "\r\n"
        END
    ENDIF
    FSEEK(F%, OLD_POS&)
END SUB

SUB StackPush(Value%, StackType@)
    STACK_PTR% = PROCESS_STACK_PTR%[PROCESS_ID%]
    STACK_SIZE% = MGET(STACK_PTR%)
    STACK_OFFSET% = STACK_SIZE% * %STACK_ENTRY_SIZE
    STACK_OFFSET% = STACK_OFFSET% + STACK_PTR%
    STACK_OFFSET% = STACK_OFFSET% + 2 'First word = Stack size
    MEMSETB(StackType@, STACK_OFFSET%, 1)
    STACK_OFFSET% = STACK_OFFSET% + 1
    MEMSETW(Value%, STACK_OFFSET%, 1)
    STACK_SIZE% = STACK_SIZE% + 1
    MEMSETW(STACK_SIZE%, STACK_PTR%, 1)
END SUB

SUB StackPushString(Value$)
    STR_LEN% = LEN(Value$)
    STR_LEN% = STR_LEN% + 2
    STR_PTR% = MALLOC(STR_LEN%)
    MEMCOPY(STRPTR(Value$), STR_PTR%, STR_LEN%)
    CALL StackPush(STR_PTR%, %TYPE_REF)
END SUB

SUB StackPop()
    STACK_PTR% = PROCESS_STACK_PTR%[PROCESS_ID%]
    STACK_SIZE% = MGET(STACK_PTR%)
    STACK_SIZE% = STACK_SIZE% - 1
    STACK_OFFSET% = STACK_SIZE% * %STACK_ENTRY_SIZE
    STACK_OFFSET% = STACK_OFFSET% + STACK_PTR%
    STACK_OFFSET% = STACK_OFFSET% + 2 'First word = Stack size
    STACK_TYPE$ = SPACE(1)
    STACK_TYPE$ = MGET(STACK_OFFSET%)
    STACK_TYPE% = ASC(STACK_TYPE$)
    STACK_OFFSET% = STACK_OFFSET% + 1
    StackValue% = MGET(STACK_OFFSET%)
    StackValue$ = STR(StackValue%)
    MEMSETW(STACK_SIZE%, STACK_PTR%, 1)
END SUB

SUB StackPopString()
    CALL StackPop()
    STR_PTR% = StackValue%
    IF STACK_TYPE% = %TYPE_REF THEN
        IF STR_PTR% > 0 THEN
            STR_LEN% = MGET(STR_PTR%)
            StackValue$ = SPACE(STR_LEN%)
            STR_LEN% = STR_LEN% + 2
            MEMCOPY(STR_PTR%, STRPTR(StackValue$), STR_LEN%)
            MFREE(STR_PTR%)
        Else
            StackValue$ = ""
        ENDIF
    ELSE
        StackValue$ = ""
    ENDIF
END SUB

SUB LocalSet(Index%, Value%, LocalsType@)
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
            MFREE(STR_PTR%)
        ENDIF
        LOCALS_OFFSET% = LOCALS_OFFSET% - 1
    ENDIF
    MEMSETB(LocalsType@, LOCALS_OFFSET%, 1)
    LOCALS_OFFSET% = LOCALS_OFFSET% + 1
    MEMSETW(Value%, LOCALS_OFFSET%, 1)
END SUB

SUB LocalSetString(Index%, Value$)
    STR_LEN% = LEN(Value$)
    STR_LEN% = STR_LEN% + 2
    STR_PTR% = MALLOC(STR_LEN%)
    MEMCOPY(STRPTR(Value$), STR_PTR%, STR_LEN%)
    CALL LocalSet(Index%, STR_PTR%, %TYPE_REF)
END SUB

SUB LocalGet(Index%)
    LOCALS_PTR% = PROCESS_LOCALS_PTR%[PROCESS_ID%]
    LOCALS_OFFSET% = Index% * %LOCALS_ENTRY_SIZE
    LOCALS_OFFSET% = LOCALS_OFFSET% + LOCALS_PTR%
    LOCALS_OFFSET% = LOCALS_OFFSET% + 1 'Ignore type
    LocalValue% = MGET(LOCALS_OFFSET%)
END SUB

SUB LocalGetString(Index%)
    CALL LocalGet(Index%)
    STR_PTR% = LocalValue%
    IF STR_PTR% > 0 THEN
        STR_LEN% = MGET(STR_PTR%)
        LocalValue$ = SPACE(STR_LEN%)
        STR_LEN% = STR_LEN% + 2
        MEMCOPY(STR_PTR%, STRPTR(LocalValue$), STR_LEN%)
    ELSE
        LocalValue$ = ""
    ENDIF
END SUB
