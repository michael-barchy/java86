SUB ReadConstantPool(FileHandle%, CP_IDX%)
    CALL ReadU(FileHandle%, 2)
    CP_COUNT% = U2% - 1

    PTR% = CP_CACHE%[CP_IDX%]
    IF PTR% > 0 THEN
        POS& = CP_POS&[CP_IDX%]
        FSEEK(FileHandle%, POS&)
        EXIT SUB
    ENDIF

    CP_LEN% = CP_COUNT% * %CP_ENTRY_SIZE
    PTR%  = MALLOC(CP_LEN%)
    CP_CACHE%[CP_IDX%] = PTR%
    JarPos& = JAR_CACHE_POS&[CP_IDX%]

    FOR I% = 1 TO CP_COUNT%
        TAG@ = FGET(FileHandle%)
        'PRINT "Tag: " + TAG@ + ", PTR: " + PTR% + "\r\n"

        MEMSETB(TAG@, PTR%, 1)
        PTR% = PTR% + 1

        IF TAG@ = %CP_Utf8 THEN
            POS& = FPOS(FileHandle%)
            POS% = POS& - JarPos&
            MEMSETW(POS%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            SLEN% = U2%
            POS& = FPOS(FileHandle%)
            POS& = POS& + SLEN%
            FSEEK(FileHandle%, POS&)
            PTR% = PTR% + 6
        ENDIF

        IF TAG@ = %CP_Integer THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_Float THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_Long THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL3% = FGET(FileHandle%)
            MEMSETW(TMP_VAL3%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL4% = FGET(FileHandle%)
            MEMSETW(TMP_VAL4%, PTR%, 1)
            PTR% = PTR% + 2
        ENDIF

        IF TAG@ = %CP_Double THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL3% = FGET(FileHandle%)
            MEMSETW(TMP_VAL3%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL4% = FGET(FileHandle%)
            MEMSETW(TMP_VAL4%, PTR%, 1)
            PTR% = PTR% + 2
        ENDIF

        IF TAG@ = %CP_Class THEN
            TMP_VAL% = FGET(FileHandle%)
            MEMSETW(TMP_VAL%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 6
        ENDIF

        IF TAG@ = %CP_String THEN
            TMP_VAL% = FGET(FileHandle%)
            MEMSETW(TMP_VAL%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 6
        ENDIF

        IF TAG@ = %CP_Fieldref THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_Methodref THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_InterfaceMethodref THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_NameAndType THEN
            TMP_VAL1% = FGET(FileHandle%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FileHandle%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF
    NEXT

    POS& = FPOS(FileHandle%)
    CP_POS&[CP_IDX%] = POS&
END SUB

SUB GetConstantPoolEntry(CP_IDX%, EntryIdx%, FileHandle%)
    CP_PTR% = CP_CACHE%[CP_IDX%]
    CP_OFFSET% = EntryIdx% - 1
    CP_OFFSET% = CP_OFFSET% * %CP_ENTRY_SIZE
    CP_PTR% = CP_PTR% + CP_OFFSET%
    CP_TAG$ = SPACE(1)
    CP_TAG$ = MGET(CP_PTR%)
    CP_TAG% = ASC(CP_TAG$)
    CP_ENTRY$ = ""

    'PRINT "CP TAG: " + CP_TAG% + "\r\n"
    If CP_TAG% = %CP_Utf8 THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        CP_OFFSET% = MGET(CP_PTR%)
        CP_OFFSET& = JAR_CACHE_POS&[CP_IDX%]
        CP_OFFSET& = CP_OFFSET& + CP_OFFSET%
        'PRINT "CP OFFSET: " + CP_OFFSET& + "\r\n"
        FSEEK(FileHandle%, CP_OFFSET&)
        CALL ReadU(FileHandle%, 2)
        CPLen% = U2%
        'PRINT "CP LEN: " + CPLen% + "\r\n"
        CPValue$ = SPACE(CPLen%)
        CPValue$ = FGET(FileHandle%)
        'PRINT "CP VALUE: " + CPValue$ + "\r\n"
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY$ = CPValue$
    ENDIF
END SUB
