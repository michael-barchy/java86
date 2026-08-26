SUB RunCode(F%, MethodIdx%, Offset%)
    JarIdx% = METHOD_CACHE_FILE_IDX%[MethodIdx%]
    CODE_OFFSET% = -1
    POS& = METHOD_CACHE_POS&[MethodIdx%]
    POS& = POS& + Offset%
    FSEEK(F%, POS&)
    CALL ReadU(F%, 1)
    OPCODE% = U1%
    IF OPCODE% = %OPCODE_ACONST_NULL THEN
        CALL StackPush(0, %TYPE_NULL)
        CODE_OFFSET% = Offset% + 1
    ENDIF
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
    IF OPCODE% = %OPCODE_ALOAD THEN
        CALL ReadU(F%, 1)
        INDEX% = U1%
        CALL LocalGet(INDEX%)
        CALL StackPush(LocalValue%, %TYPE_REF)
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
            CALL LocalGet(Index%)
            CALL StackPush(LocalValue%, %TYPE_REF)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_BALOAD THEN
        CALL StackPop()
        Index% = StackValue%
        CALL StackPop()
        StackType@ = STACK_TYPE%
        STR_PTR% = StackValue%
        IF STR_PTR% = 0 THEN
            PRINT "Null pointer exception\r\n"
            END
        ENDIF
        L% = MGET(STR_PTR%)
        E% = L% - 1
        IF Index% > E% THEN
            PRINT "Array index out of bounds: " + Index% + "\r\n"
            END
        ENDIF
        STR_OFFSET% = STR_PTR% + 2
        STR_OFFSET% = STR_OFFSET% + Index%
        B$ = CHR(0)
        B$ = MGET(STR_OFFSET%)
        C% = ASC(B$)
        CALL StackPush(C%, %TYPE_INT)
        IF StackType@ = %TYPE_REF THEN
            CALL CheckRef(STR_PTR%)
            IF REF_USED% = 0 THEN
                MFREE(STR_PTR%)
            ENDIF
        ENDIF
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_ISTORE THEN
        CALL ReadU(F%, 1)
        Index% = U1%
        CALL StackPop()
        CALL LocalSet(Index%, StackValue%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% = %OPCODE_ASTORE THEN
        CALL ReadU(F%, 1)
        Index% = U1%
        CALL StackPop()
        CALL LocalSet(Index%, StackValue%, %TYPE_REF)
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% >= %OPCODE_ISTORE_0 THEN
        IF OPCODE% <= %OPCODE_ISTORE_4 THEN
            Index% = OPCODE% - %OPCODE_ISTORE_0
            CALL StackPop()
            CALL LocalSet(Index%, StackValue%, %TYPE_INT)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% >= %OPCODE_ASTORE_0 THEN
        IF OPCODE% <= %OPCODE_ASTORE_3 THEN
            Index% = OPCODE% - %OPCODE_ASTORE_0
            CALL StackPop()
            CALL LocalSet(Index%, StackValue%, %TYPE_REF)
            CODE_OFFSET% = Offset% + 1
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_BASTORE THEN
        CALL StackPop()
        VALUE@ = StackValue%
        CALL StackPop()
        Index% = StackValue%
        CALL StackPop()
        StackType@ = STACK_TYPE%
        L% = MGET(StackValue%)
        E% = L% - 1
        IF Index% > E% THEN
            PRINT "Array index out of bounds: " + Index% + "\r\n"
            END
        ENDIF
        StrSize% = L% + 2
        STR_PTR% = StackValue%
        IF STR_PTR% = 0 THEN
            PRINT "Null pointer exception\r\n"
            END
        ENDIF
        STR_OFFSET% = STR_PTR% + Index%
        STR_OFFSET% = STR_OFFSET% + 2
        MEMSETB(VALUE@, STR_OFFSET%, 1)
        IF StackType@ = %TYPE_REF THEN
            IF STR_PTR% > 0 THEN
                CALL CheckRef(STR_PTR%)
                IF REF_USED% = 0 THEN
                    MFREE(STR_PTR%)
                ENDIF
            ENDIF
        ENDIF
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_POP THEN
        CALL StackPop()
        StackType@ = STACK_TYPE%
        IF StackType@ = %TYPE_REF THEN
            STR_PTR% = StackValue%
            IF STR_PTR% > 0 THEN
                CALL CheckRef(STR_PTR%)
                IF REF_USED% = 0 THEN
                    MFREE(STR_PTR%)
                ENDIF
            ENDIF
        ENDIF
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_DUP THEN
        CALL StackPop()
        StackType@ = STACK_TYPE%
        CALL StackPush(StackValue%, StackType@)
        CALL StackPush(StackValue%, StackType@)
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_IADD THEN
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        STACK_ADD% = STACK_POP1% + STACK_POP2%
        CALL StackPush(STACK_ADD%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_ISUB THEN
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        STACK_SUB% = STACK_POP1% - STACK_POP2%
        CALL StackPush(STACK_SUB%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF OPCODE% = %OPCODE_IINC THEN
        CALL ReadU(F%, 1)
        Index% = U1%
        CALL ReadU(F%, 1)
        Inc% = U1%
        IF Inc% > 127 THEN
            Inc% = Inc% - 256
        ENDIF
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
    IF OPCODE% = %OPCODE_IF_ICMPGE THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        IF STACK_POP1% >= STACK_POP2% THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ICMPGT THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        IF STACK_POP1% > STACK_POP2% THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ICMPLE THEN
        CALL ReadU(F%, 2)
        CALL StackPop()
        STACK_POP2% = StackValue%
        CALL StackPop()
        STACK_POP1% = StackValue%
        IF STACK_POP1% <= STACK_POP2% THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = Offset% + 3
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ACMPEQ THEN
        CALL ReadU(F%, 2)
        CALL StackPopString()
        STACK_TYPE1@ = STACK_TYPE%
        STACK_POP1% = StackValue%
        STACK_POP1$ = StackValue$
        CALL StackPopString()
        STACK_TYPE2@ = STACK_TYPE%
        STACK_POP2% = StackValue%
        STACK_POP2$ = StackValue$
        IF STACK_POP1$ = STACK_POP2$ THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF STACK_TYPE1@ = %TYPE_REF THEN
            IF STACK_POP1% > 0 THEN
                CALL CheckRef(STACK_POP1%)
                IF REF_USED% = 0 THEN
                    MFREE(STACK_POP1%)
                ENDIF
            ENDIF
        ENDIF
        IF STACK_TYPE2@ = %TYPE_REF THEN
            IF STACK_POP2% > 0 THEN
                IF STACK_POP2% <> STACK_POP1% THEN
                    CALL CheckRef(STACK_POP2%)
                    IF REF_USED% = 0 THEN
                        MFREE(STACK_POP2%)
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ACMPNE THEN
        CALL ReadU(F%, 2)
        CALL StackPopString()
        STACK_TYPE1@ = STACK_TYPE%
        STACK_POP1% = StackValue%
        STACK_POP1$ = StackValue$
        CALL StackPopString()
        STACK_TYPE2@ = STACK_TYPE%
        STACK_POP2% = StackValue%
        STACK_POP2$ = StackValue$
        IF STACK_POP1$ <> STACK_POP2$ THEN
            CODE_OFFSET% = Offset% + U2%
        ELSE
            CODE_OFFSET% = Offset% + 3
        ENDIF
        IF STACK_TYPE1@ = %TYPE_REF THEN
            IF STACK_POP1% > 0 THEN
                CALL CheckRef(STACK_POP1%)
                IF REF_USED% = 0 THEN
                    MFREE(STACK_POP1%)
                ENDIF
            ENDIF
        ENDIF
        IF STACK_TYPE2@ = %TYPE_REF THEN
            IF STACK_POP2% > 0 THEN
                IF STACK_POP2% <> STACK_POP1% THEN
                    CALL CheckRef(STACK_POP2%)
                    IF REF_USED% = 0 THEN
                        MFREE(STACK_POP2%)
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_GOTO THEN
        CALL ReadU(F%, 2)
        CODE_OFFSET% = Offset% + U2%
    ENDIF
    IF OPCODE% = %OPCODE_IRETURN THEN
        CODE_OFFSET% = Offset% + 1
        PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
        CALL StackPop()
        CALL KillProcess(PROCESS_ID%, %TYPE_INT, StackValue%)
    ENDIF
    IF OPCODE% = %OPCODE_ARETURN THEN
        CODE_OFFSET% = Offset% + 1
        PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
        CALL StackPop()
        CALL KillProcess(PROCESS_ID%, %TYPE_REF, StackValue%)
    ENDIF
    IF OPCODE% = %OPCODE_RETURN THEN
        CODE_OFFSET% = Offset% + 1
        PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
        CALL KillProcess(PROCESS_ID%, %TYPE_NONE, 0)
    ENDIF
    IF OPCODE% = %OPCODE_INVOKE_VIRTUAL THEN
        OPCODE% = %OPCODE_INVOKE_STATIC
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
            S% = SINSTR(MethodRef$, "(")
            ParamCount% = 0
            IF S% > 0 THEN
                S% = S% + 1
                Params$ = MID(MethodRef$, S%)
                L% = LEN(Params$)
                IsArray% = 0
                FOR P% = 1 TO L%
                    C$ = MID(Params$, P%, 1)
                    IF C$ = "L" THEN
                        SP% = SINSTR(Params$, ";")
                        IF SP% > 0 THEN
                            ParamCount% = ParamCount% + 1
                            ParamTypes@[ParamCount%] = %TYPE_REF
                            P% = SP%
                        ENDIF
                    ELSE
                        IF C$ = ")" THEN
                            EXIT FOR
                        ENDIF
                        IF C$ <> "[" THEN
                            ParamCount% = ParamCount% + 1
                            IF IsArray% = 1 THEN
                                ParamTypes@[ParamCount%] = %TYPE_REF
                            ELSE
                                ParamTypes@[ParamCount%] = %TYPE_INT
                            ENDIF
                            IsArray% = 0
                        ELSE
                            IsArray% = 1
                        ENDIF
                    ENDIF
                NEXT
            ENDIF
            FOR I% = 1 TO ParamCount%
                J% = ParamCount% - I% + 1
                CALL StackPop()
                Params%[J%] = StackValue%
                ParamTypes@[J%] = STACK_TYPE%
            NEXT
            PROCESS_IDLE%[PROCESS_ID%] = 1
            CODE_OFFSET% = Offset% + 3
            PROCESS_CODE_OFFSET%[PROCESS_ID%] = CODE_OFFSET%
            ParentId% = PROCESS_ID%
            CALL NewProcess(ClassName$, MethodRef$, ParentId%)
            FOR I% = 1 TO ParamCount%
                LocalsIndex% = I% - 1
                Param% = Params%[I%]
                ParamType@ = ParamTypes@[I%]
                CALL LocalSet(LocalsIndex%, Param%, ParamType@)
            NEXT
            PROCESS_ID% = ParentId%
            CODE_OFFSET% = PROCESS_CODE_OFFSET%[PROCESS_ID%]
        ELSE
            MethodRef$ = ClassName$ + "." + MethodRef$
            CALL InvokeNative(MethodRef$, Offset%)
        ENDIF
        IF CODE_OFFSET% = -1 THEN
            END
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_NEWARRAY THEN
        CALL ReadU(F%, 1)
        ArrayType% = U1%
        CALL StackPop()
        StackType@ = STACK_TYPE%
        ArrayLen% = StackValue%
        IF StackType@ = %TYPE_REF THEN
            IF ArrayLen% > 0 THEN
                CALL CheckRef(ArrayLen%)
                IF REF_USED% = 0 THEN
                    MFREE(ArrayLen%)
                ENDIF
            ENDIF
        ENDIF
        IF ArrayLen% < 0 THEN
            PRINT "Negative array size: " + ArrayLen% + "\r\n"
            END
        ENDIF
        IF ArrayType% <> %ARRAY_TYPE_BYTE THEN
            PRINT "Unsupported array type: " + ArrayType% + "\r\n"
            END
        ENDIF
        Array$ = ""
        IF ArrayLen% > 0 THEN
            Array$ = SPACE(ArrayLen%)
        ENDIF
        CALL StackPushString(Array$)
        CODE_OFFSET% = Offset% + 2
    ENDIF
    IF OPCODE% = %OPCODE_ARRAYLENGTH THEN
        CALL StackPopString()
        StackType@ = STACK_TYPE%
        STR_PTR% = StackValue%
        ArrayLen% = LEN(StackValue$)
        IF STR_PTR% > 0 THEN
            IF StackType@ = %TYPE_REF THEN
                CALL CheckRef(STR_PTR%)
                IF REF_USED% = 0 THEN
                    MFREE(STR_PTR%)
                ENDIF
            ENDIF
        ENDIF
        CALL StackPush(ArrayLen%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 1
    ENDIF
    IF CODE_OFFSET% = -1 THEN
        PRINT "UNSUPPORTED OPCODE: " + OPCODE% + "\r\n"
        END
    ENDIF
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
    STACK_PTR% = PROCESS_STACK_PTR%[PROCESS_ID%]
    STACK_SIZE% = MGET(STACK_PTR%)
    STACK_SIZE% = STACK_SIZE% + 1
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
    B$ = CHR(0)
    B$ = MGET(STACK_OFFSET%)
    STACK_TYPE% = ASC(B$)
    STACK_OFFSET% = STACK_OFFSET% + 1
    StackValue% = MGET(STACK_OFFSET%)
    MEMSETW(STACK_SIZE%, STACK_PTR%, 1)
END SUB

SUB StackPopString()
    CALL StackPop()
    STR_PTR% = StackValue%
    StackType@ = STACK_TYPE%
    IF StackType@ = %TYPE_REF THEN
        IF STR_PTR% > 0 THEN
            STR_LEN% = MGET(STR_PTR%)
            StackValue$ = ""
            IF STR_LEN% > 0 THEN
                StackValue$ = SPACE(STR_LEN%)
            ENDIF
            STR_LEN% = STR_LEN% + 2
            MEMCOPY(STR_PTR%, STRPTR(StackValue$), STR_LEN%)
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
    B$ = CHR(0)
    B$ = MGET(LOCALS_OFFSET%)
    B% = ASC(B$)
    LocalType@ = B%
    IF LocalType@ = %TYPE_REF THEN
        VAL_OFFSET% = LOCALS_OFFSET% + 1
        STR_PTR% = MGET(VAL_OFFSET%)
        IF STR_PTR% > 0 THEN
            IF STR_PTR% <> Value% THEN
                MEMSETB(%TYPE_INT, LOCALS_OFFSET%, 1)
                MEMSETW(0, VAL_OFFSET%, 1)
                CALL CheckRef(STR_PTR%)
                IF REF_USED% = 0 THEN
                    MFREE(STR_PTR%)
                ENDIF
            ENDIF
        ENDIF
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
        LocalValue$ = ""
        IF STR_LEN% > 0 THEN
            LocalValue$ = SPACE(STR_LEN%)
        ENDIF
        STR_LEN% = STR_LEN% + 2
        MEMCOPY(STR_PTR%, STRPTR(LocalValue$), STR_LEN%)
        CALL CheckRef(STR_PTR%)
        IF REF_USED% = 0 THEN
            MFREE(STR_PTR%)
        ENDIF
    ELSE
        LocalValue$ = ""
    ENDIF
END SUB
