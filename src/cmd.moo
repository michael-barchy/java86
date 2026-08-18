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
            JarFile$ = LEFT(temp$, i%)
            StrLen% = LEN(JarFile$)
            StrLen% = StrLen% + 2
            STR_PTR% = MALLOC(StrLen%)
            'PRINT JarFile$ + ", " + StrLen% + + ", " + STR_PTR% + "\r\n"
            JAR_FILES%[JAR_COUNT%] = STR_PTR%
            MEMCOPY(STRPTR(JarFile$), STR_PTR%, StrLen%)
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

SUB GetJarFile(JarIdx%)
    STR_PTR% = JAR_FILES%[JarIdx%]
    StrLen% = MGET(STR_PTR%)
    JAR_FILE$ = SPACE(StrLen%)
    StrLen% = StrLen% + 2
    MEMCOPY(STR_PTR%, STRPTR(JAR_FILE$), StrLen%)
    'PRINT JAR_FILE$ + ", " + STR_PTR% + ", " + StrLen% + "\r\n"
END SUB
