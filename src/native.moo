SUB InvokeNative(MethodRef$, Offset%)
    IF MethodRef$ = "print(Ljava/lang/String;)V" THEN
        CALL StackPopString()
        StackType@ = STACK_TYPE%
        STR_PTR% = StackValue%
        PRINT StackValue$
        POS% = INSTR(StackValue$, "\r\n")
        SLEN% = LEN(StackValue$) - 2
        IF POS% = SLEN% THEN
            'PRINT "Free memory: " + FREEMEM(0) + "\r\n"
        ENDIF
        IF StackType@ = %TYPE_REF THEN
            CALL CheckRef(STR_PTR%)
            IF REF_USED% = 0 THEN
                CALL SafeMFree(STR_PTR%)
            ENDIF
        ENDIF
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "input()Ljava/lang/String;" THEN
        INPUT STACK_PUSH$
        CALL StackPushString(STACK_PUSH$)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "getBytes(Ljava/lang/String;)[B" THEN
        'Nothing to do here, the string is already on the stack
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "toString([B)Ljava/lang/String;" THEN
        'Nothing to do here, the byte array is already on the stack
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "newProcess(Ljava/lang/String;)I" THEN
        CALL StackPopString()
        StackType@ = STACK_TYPE%
        STR_PTR% = StackValue%
        ParentId% = PROCESS_ID%
        IF StackType@ = %TYPE_REF THEN
            CALL CheckRef(STR_PTR%)
            IF REF_USED% = 0 THEN
                CALL SafeMFree(STR_PTR%)
            ENDIF
        ENDIF
        CALL NewProcess(StackValue$, "main([Ljava/lang/String;)V", 0)
        NewProcessId% = PROCESS_ID%
        PROCESS_ID% = ParentId%
        CALL StackPush(NewProcessId%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "killProcess(I)V" THEN
        CALL StackPop()
        CALL KillProcess(StackValue%, %TYPE_NONE, 0)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "int86(I[I)[I" THEN
        CALL StackPop()
        REGS_PTR% = StackValue%
        REGS_SIZE% = MGET(REGS_PTR%)
        IF REGS_SIZE% <> %REG_COUNT THEN
            PRINT "Invalid regs size\r\n"
            END
        ENDIF
        REGS_OFFSET% = REGS_PTR% + 2
        reg^ = MGET(REGS_OFFSET%)
        CALL StackPop()
        INTERRUPT% = StackValue%
        INT86(INTERRUPT%, reg^, reg^)
        REGS_OFFSET% = REGS_PTR% + 2
        MEMSETW(reg.AX%, REGS_OFFSET%, 1)
        REGS_OFFSET% = REGS_OFFSET% + 2
        MEMSETW(reg.BX%, REGS_OFFSET%, 1)
        REGS_OFFSET% = REGS_OFFSET% + 2
        MEMSETW(reg.CX%, REGS_OFFSET%, 1)
        REGS_OFFSET% = REGS_OFFSET% + 2
        MEMSETW(reg.DX%, REGS_OFFSET%, 1)
        REGS_OFFSET% = REGS_OFFSET% + 2
        MEMSETW(reg.BP%, REGS_OFFSET%, 1)
        REGS_OFFSET% = REGS_OFFSET% + 2
        MEMSETW(reg.SI%, REGS_OFFSET%, 1)
        REGS_OFFSET% = REGS_OFFSET% + 2
        MEMSETW(reg.DI%, REGS_OFFSET%, 1)
        REGS_OFFSET% = REGS_OFFSET% + 2
        MEMSETW(reg.FLAGS%, REGS_OFFSET%, 1)
        CALL StackPush(REGS_PTR%, %TYPE_REF)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "farmemsetb(IIIII)V" THEN
        CALL StackPop()
        COUNT% = StackValue%
        CALL StackPop()
        PTR_OFFSET% = StackValue%
        PTR_OFFSET& = 32768
        IF PTR_OFFSET% < 0 THEN
            PTR_OFFSET& = PTR_OFFSET& + PTR_OFFSET%
            PTR_OFFSET& = PTR_OFFSET& + 32768
        ELSE
            PTR_OFFSET& = PTR_OFFSET%
        ENDIF
        CALL StackPop()
        PTR_LOW% = StackValue%
        CALL StackPop()
        PTR_HIGH% = StackValue%
        PTR& = PTR_HIGH% * 256
        PTR& = PTR& + PTR_LOW%
        CALL StackPop()
        B@ = StackValue%
        FARMEMSETB(B@, PTR&, PTR_OFFSET&, COUNT%)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "farmemsetb([BIIIIIZ)V" THEN
        CALL StackPop()
        MERGE% = StackValue%
        CALL StackPop()
        WIDTH% = StackValue%
        CALL StackPop()
        COUNT% = StackValue%
        CALL StackPop()
        PTR_OFFSET% = StackValue%
        PTR_OFFSET& = 32768
        IF PTR_OFFSET% < 0 THEN
            PTR_OFFSET& = PTR_OFFSET& + PTR_OFFSET%
            PTR_OFFSET& = PTR_OFFSET& + 32768
        ELSE
            PTR_OFFSET& = PTR_OFFSET%
        ENDIF
        CALL StackPop()
        PTR_LOW% = StackValue%
        CALL StackPop()
        PTR_HIGH% = StackValue%
        PTR& = PTR_HIGH% * 256
        PTR& = PTR& + PTR_LOW%
        CALL StackPop()
        SRC_PTR% = StackValue%
        SRC_LEN% = MGET(SRC_PTR%)
        IF COUNT% = 0 THEN
            COUNT% = SRC_LEN%
        ENDIF
        IF WIDTH% > 0 THEN
            IF MERGE% <> 0 THEN
                MASK% = MALLOC(COUNT%)
            ENDIF
            SRC_HEIGHT% = SRC_LEN% / COUNT%
            FOR H% = 1 TO SRC_HEIGHT%
                SRC_OFFSET% = H% - 1
                SRC_OFFSET% = SRC_OFFSET% * COUNT%
                SRC_OFFSET% = SRC_OFFSET% + SRC_PTR%
                SRC_OFFSET% = SRC_OFFSET% + 2
                H_OFFSET& = H% - 1
                H_OFFSET& = H_OFFSET& * WIDTH%
                H_OFFSET& = H_OFFSET& + PTR_OFFSET&
                IF MERGE% <> 0 THEN
                    MEMFARTONEAR(PTR&, H_OFFSET&, MASK%, COUNT%)
                    FOR X% = 1 TO COUNT%
                        C% = X% - 1
                        C% = C% + SRC_OFFSET%
                        B$ = CHR(0)
                        B$ = MGET(C%)
                        B% = ASC(B$)
                        B@ = B%
                        IF B@ <> -1 THEN
                            C% = X% - 1
                            C% = C% + MASK%
                            MEMSETB(B@, C%, 1)
                        ENDIF
                    NEXT
                    MEMNEARTOFAR(MASK%, PTR&, H_OFFSET&, COUNT%)
                ELSE
                    MEMNEARTOFAR(SRC_OFFSET%, PTR&, H_OFFSET&, COUNT%)
                ENDIF
            NEXT
        ELSE
            SRC_PTR% = SRC_PTR% + 2
            SRC_PTR% = SRC_PTR% + SRC_OFFSET%
            MEMNEARTOFAR(SRC_PTR%, PTR&, PTR_OFFSET&, COUNT%)
        ENDIF
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "farmemgetb(III)I" THEN
        CALL StackPop()
        PTR_OFFSET% = StackValue%
        PTR_OFFSET& = 32768
        IF PTR_OFFSET% < 0 THEN
            PTR_OFFSET& = PTR_OFFSET& + PTR_OFFSET%
            PTR_OFFSET& = PTR_OFFSET& + 32768
        ELSE
            PTR_OFFSET& = PTR_OFFSET%
        ENDIF
        CALL StackPop()
        PTR_LOW% = StackValue%
        CALL StackPop()
        PTR_HIGH% = StackValue%
        PTR& = PTR_HIGH% * 256
        PTR& = PTR& + PTR_LOW%
        B$ = CHR(0)
        B$ = MGET(PTR_OFFSET&, PTR&)
        B% = ASC(B$)
        CALL StackPush(B%, %TYPE_INT)
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF MethodRef$ = "farmemgetb([BIIIII)V" THEN
        CALL StackPop()
        WIDTH% = StackValue%
        CALL StackPop()
        COUNT% = StackValue%
        CALL StackPop()
        PTR_OFFSET% = StackValue%
        PTR_OFFSET& = 32768
        IF PTR_OFFSET% < 0 THEN
            PTR_OFFSET& = PTR_OFFSET& + PTR_OFFSET%
            PTR_OFFSET& = PTR_OFFSET& + 32768
        ELSE
            PTR_OFFSET& = PTR_OFFSET%
        ENDIF
        CALL StackPop()
        PTR_LOW% = StackValue%
        CALL StackPop()
        PTR_HIGH% = StackValue%
        PTR& = PTR_HIGH% * 256
        PTR& = PTR& + PTR_LOW%
        CALL StackPop()
        SRC_PTR% = StackValue%
        SRC_LEN% = MGET(SRC_PTR%)
        IF COUNT% = 0 THEN
            COUNT% = SRC_LEN%
        ENDIF
        IF WIDTH% > 0 THEN
            SRC_HEIGHT% = SRC_LEN% / COUNT%
            FOR H% = 1 TO SRC_HEIGHT%
                SRC_OFFSET% = H% - 1
                SRC_OFFSET% = SRC_OFFSET% * COUNT%
                SRC_OFFSET% = SRC_OFFSET% + SRC_PTR%
                SRC_OFFSET% = SRC_OFFSET% + 2
                H_OFFSET& = H% - 1
                H_OFFSET& = H_OFFSET& * WIDTH%
                H_OFFSET& = H_OFFSET& + PTR_OFFSET&
                MEMFARTONEAR(PTR&, H_OFFSET&, SRC_OFFSET%, COUNT%)
            NEXT
        ELSE
            SRC_PTR% = SRC_PTR% + 2
            SRC_PTR% = SRC_PTR% + SRC_OFFSET%
            MEMFARTONEAR(PTR&, PTR_OFFSET&, SRC_PTR%, COUNT%)
        ENDIF
        CODE_OFFSET% = Offset% + 3
    ENDIF
    IF CODE_OFFSET% = -1 THEN
        PRINT "Unknown native method: " + MethodRef$ + "\r\n"
        END
    ENDIF
END SUB

SUB SafeMFree(PTR_TO_FREE%)
    IF PTR_TO_FREE% = 0 THEN
        EXIT SUB
    ENDIF
    IF PTR_TO_FREE% = LAST_FREE_PTR% THEN
        EXIT SUB
    ENDIF
    MFREE(PTR_TO_FREE%) '
    LAST_FREE_PTR% = PTR_TO_FREE%
END SUB
