SUB InvokeNative(MethodRef$, Offset%)
    IF MethodRef$ = "Native.print(Ljava/lang/String;)V" THEN
        CALL StackPopString()
        StackType@ = STACK_TYPE%
        STR_PTR% = StackValue%
        PRINT StackValue$
        POS% = INSTR(StackValue$, "\r\n")
        SLEN% = LEN(StackValue$) - 2
        IF POS% = SLEN% THEN
            'PRINT "Free memory: " + FREEMEM(0) + "\r\n"
        ENDIF
        IF STR_PTR% > 0 THEN
            IF StackType@ = %TYPE_REF THEN
                CALL CheckRef(STR_PTR%)
                IF REF_USED% = 0 THEN
                    MFREE(STR_PTR%)
                ENDIF
            ENDIF
        ENDIF
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "Native.input()Ljava/lang/String;" THEN
        INPUT STACK_PUSH$
        CALL StackPushString(STACK_PUSH$)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "Native.getBytes(Ljava/lang/String;)[B" THEN
        'Nothing to do here, the string is already on the stack
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "Native.toString([B)Ljava/lang/String;" THEN
        'Nothing to do here, the byte array is already on the stack
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "Native.newProcess(Ljava/lang/String;)I" THEN
        CALL StackPopString()
        StackType@ = STACK_TYPE%
        STR_PTR% = StackValue%
        ParentId% = PROCESS_ID%
        IF STR_PTR% > 0 THEN
            IF StackType@ = %TYPE_REF THEN
                CALL CheckRef(STR_PTR%)
                IF REF_USED% = 0 THEN
                    MFREE(STR_PTR%)
                ENDIF
            ENDIF
        ENDIF
        CALL NewProcess(StackValue$, "main([Ljava/lang/String;)V", 0)
        PROCESS_ID% = ParentId%
        CALL StackPush(PROCESS_ID%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "Native.killProcess(I)V" THEN
        CALL StackPop()
        CALL KillProcess(StackValue%, %TYPE_NONE, 0)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "Native.int86(I[I)[I" THEN
        CALL StackPop()
        REGS_PTR% = StackValue%
        REGS_SIZE% = MGET(REGS_PTR%)
        IF REGS_SIZE% <> 8 THEN
            PRINT "Invalid regs size\r\n"
            END
        ENDIF
        REGS_OFFSET% = REGS_PTR% + 2
        reg^ = MGET(REGS_OFFSET%)
        CALL StackPop()
        INTERRUPT% = StackValue%
        INT86(INTERRUPT%, reg^, reg^)
        CALL StackPush(REGS_PTR%, %TYPE_REF)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF CODE_OFFSET% = -1 THEN
        PRINT "Unknown native method: " + MethodRef$ + "\r\n"
        END
    ENDIF
END SUB
