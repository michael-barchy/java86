SUB Java ()
    CALL ParseCmd
    IF JAR_COUNT% > 0 THEN
        FOR I% = 1 TO JAR_COUNT%
            'PRINT "Jar file: " + JAR_FILES$[I%] + "\r\n"
        NEXT
    ENDIF
    'PRINT "Target class: " + TARGET_CLASS$ + "\r\n"
    CALL InvokeStatic(TARGET_CLASS$, "main([Ljava/lang/String;)V")
END SUB
