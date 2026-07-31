SUB ParseCmd ()
    cmd$ = CMDLINE
    cpPos% = INSTR(cmd$, "-classpath ")
    cpPos% = cpPos% + 11
    cmdLen% = LEN(cmd$)
    temp$ = MID(cmd$, cpPos%, cmdLen%)
    JAR_COUNT% = 0

    WHILE JAR_COUNT% < %MAX_JARS
        JAR_COUNT% = JAR_COUNT% + 1
        i% = SINSTR(temp$, "; ")
        c$ = MID(temp$, i%, 1)
        IF i% > 0 THEN
            i% = i% - 1
            JAR_FILES$[JAR_COUNT%] = LEFT(temp$, i%)
            i% = i% + 2
            temp$ = MID(temp$, i%)
        ELSE
            EXIT WHILE
        ENDIF
        IF c$ = " " THEN
            TARGET_CLASS$ = temp$
            EXIT WHILE
        ENDIF
    WEND
END SUB
