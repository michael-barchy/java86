SUB InvokeNative(MethodRef$, Offset%)
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
END SUB
