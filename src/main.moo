SUB Java ()
    CALL ParseCmd
    IF JAR_COUNT% > 0 THEN
        FOR I% = 1 TO JAR_COUNT%
            CALL GetJarFile(I%)
        NEXT
    ENDIF
    FOR I% = 1 TO %MAX_CP_CACHE
        CP_CACHE%[I%] = 0
    NEXT
    CALL NewProcess(TARGET_CLASS$, "main([Ljava/lang/String;)V", 0)
    ProcessLoop:
    Total% = 0
    FOR I% = 1 TO %MAX_PROCESS
        F% = PROCESS_FILE%[I%]
        Idle% = PROCESS_IDLE%[I%]
        MethodIdx% = PROCESS_METHOD%[I%]
        Offset% = PROCESS_CODE_OFFSET%[I%]
        CodeEnd% = PROCESS_CODE_END%[I%]
        Running% = 0
        IF F% > 0 THEN
            IF Idle% = 0 THEN
                IF Offset% <= CodeEnd% THEN
                    Running% = 1
                ENDIF
            ENDIF
        ENDIF
        IF Running% = 1 THEN
            PROCESS_ID% = I%
            CP_IDX% = PROCESS_CPOOL%[I%]
            CALL RunCode(F%, MethodIdx%, Offset%)
            PROCESS_CODE_OFFSET%[I%] = CODE_OFFSET%
        ENDIF
        IF F% > 0 THEN
            IF CODE_OFFSET% <= CodeEnd% THEN
                Total% = Total% + 1
            ENDIF
        ENDIF
    NEXT
    IF Total% = 0 THEN
        END
    ENDIF
    GOTO ProcessLoop
END SUB
