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
    IF OPCODE% = %OPCODE_LDC THEN
        CALL ReadU(F%, 1)
        INDEX% = U1%
        CALL GetConstantPoolEntry(JarIdx%, INDEX%, F%)
        CALL GetConstantPoolEntry(JarIdx%, CP_ENTRY%, F%)
        'PRINT "LDC: " + INDEX% + ", " + CP_ENTRY% + ", " + CP_ENTRY$ + "\r\n"
        STACK_SIZE% = STACK_SIZE% + 1
        STACK$[STACK_SIZE%] = CP_ENTRY$
        POS& = FPOS(F%)
        CODE_OFFSET% = POS& - OLD_POS&
    ENDIF
    IF OPCODE% = %OPCODE_ALOAD_1 THEN
        STACK_PUSH$ = LOCALS$[1]
        STACK_SIZE% = STACK_SIZE% + 1
        STACK$[STACK_SIZE%] = STACK_PUSH$
        POS& = FPOS(F%)
        CODE_OFFSET% = POS& - OLD_POS&
    ENDIF
    IF OPCODE% = %OPCODE_ASTORE_1 THEN
        STACK_POP$ = STACK$[STACK_SIZE%]
        STACK_SIZE% = STACK_SIZE% - 1
        LOCALS$[1] = STACK_POP$
        POS& = FPOS(F%)
        CODE_OFFSET% = POS& - OLD_POS&
    ENDIF
    IF OPCODE% = %OPCODE_IF_ACMPEQ THEN
        CALL ReadU(F%, 2)
        STACK_POP1$ = STACK$[STACK_SIZE%]
        STACK_SIZE% = STACK_SIZE% - 1
        STACK_POP2$ = STACK$[STACK_SIZE%]
        STACK_SIZE% = STACK_SIZE% - 1
        'PRINT "OPCODE_IF_ACMPEQ: " + STACK_POP1$ + " = " + STACK_POP2$ + " ?\r\n"
        IF STACK_POP1$ = STACK_POP2$ THEN
            'PRINT "IF_ACMPEQ OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = POS& - OLD_POS&
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_IF_ACMPNE THEN
        CALL ReadU(F%, 2)
        STACK_POP1$ = STACK$[STACK_SIZE%]
        STACK_SIZE% = STACK_SIZE% - 1
        STACK_POP2$ = STACK$[STACK_SIZE%]
        STACK_SIZE% = STACK_SIZE% - 1
        'PRINT "OPCODE_IF_ACMPNE: " + STACK_POP1$ + " <> " + STACK_POP2$ + " ?\r\n"
        IF STACK_POP1$ <> STACK_POP2$ THEN
            'PRINT "IF_ACMPNE OFFSET: " + U2% + "\r\n"
            CODE_OFFSET% = Offset% + U2%
        ELSE
            POS& = FPOS(F%)
            CODE_OFFSET% = POS& - OLD_POS&
        ENDIF
    ENDIF
    IF OPCODE% = %OPCODE_GOTO THEN
        CALL ReadU(F%, 2)
        'PRINT "GOTO OFFSET: " + U2% + "\r\n"
        CODE_OFFSET% = Offset% + U2%
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
        MethodRef$ = ClassName$ + "." + MethodName$ + CP_ENTRY$
        IF ClassName$ <> "Native" THEN
            '@todo - invoke other class method (non-native)
        ENDIF
        IF MethodRef$ = "Native.print(Ljava/lang/String;)V" THEN
            STACK_POP$ = STACK$[STACK_SIZE%]
            STACK_SIZE% = STACK_SIZE% - 1
            PRINT STACK_POP$
            POS& = FPOS(F%)
            CODE_OFFSET% = POS& - OLD_POS&
        ENDIF
        IF MethodRef$ = "Native.input()Ljava/lang/String;" THEN
            INPUT STACK_PUSH$
            STACK_SIZE% = STACK_SIZE% + 1
            STACK$[STACK_SIZE%] = STACK_PUSH$
            POS& = FPOS(F%)
            CODE_OFFSET% = POS& - OLD_POS&
        ENDIF
        IF CODE_OFFSET% = -1 THEN
            PRINT "INVOKE_STATIC: " + METHOD_REF% + ", " + MethodRef$ + "\r\n"
            END
        ENDIF
    ENDIF
    IF CODE_OFFSET% = -1 THEN
        PRINT "OPCODE: " + OPCODE% + "\r\n"
        END
    ENDIF
    FSEEK(F%, OLD_POS&)
END SUB
