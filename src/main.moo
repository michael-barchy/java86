SUB Java ()
    CALL ParseCmd
    IF JAR_COUNT% > 0 THEN
        FOR I% = 1 TO JAR_COUNT%
            CALL GetJarFile(I%)
            'PRINT "Jar file: " + JAR_FILE$ + "\r\n"
        NEXT
    ENDIF
    'PRINT "Target class: " + TARGET_CLASS$ + "\r\n"
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
            'PRINT "RunCode: " + F% + ", " + I% + ", " + MethodIdx% + ", " + Offset% + ", " + CodeEnd% + "\r\n"
            CALL RunCode(F%, MethodIdx%, Offset%)
            PROCESS_CODE_OFFSET%[I%] = CODE_OFFSET%
        ENDIF
        IF CODE_OFFSET% <= CodeEnd% THEN
            Total% = Total% + 1
        ENDIF
    NEXT
    IF Total% = 0 THEN
        END
    ENDIF
    GOTO ProcessLoop
END SUB
