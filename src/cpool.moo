SUB ReadConstantPool(FileHandle%, CP_IDX%)
    CALL ReadU(FileHandle%, 2)
    CP_COUNT% = U2% - 1

    PTR% = CP_CACHE%[CP_IDX%]
    IF PTR% > 0 THEN
        'PRINT "ConstantPool from cache: " + PTR% + "\r\n"
        POS& = CP_POS&[CP_IDX%]
        FSEEK(FileHandle%, POS&)
        EXIT SUB
    ENDIF

    CP_LEN% = CP_COUNT% * %CP_ENTRY_SIZE
    'PRINT "CP_LEN: " + CP_LEN% + "\r\n"
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
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_Float THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_Long THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
        ENDIF

        IF TAG@ = %CP_Double THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
        ENDIF

        IF TAG@ = %CP_Class THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 6
        ENDIF

        IF TAG@ = %CP_String THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 6
        ENDIF

        IF TAG@ = %CP_Fieldref THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_Methodref THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_InterfaceMethodref THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            PTR% = PTR% + 4
        ENDIF

        IF TAG@ = %CP_NameAndType THEN
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
            PTR% = PTR% + 2
            CALL ReadU(FileHandle%, 2)
            MEMSETW(U2%, PTR%, 1)
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
    CP_ENTRY% = 0
    CP_ENTRY2% = 0
    CP_ENTRY$ = ""

    'PRINT "CP TAG: " + CP_TAG% + "\r\n"
    IF CP_TAG% = %CP_String THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        STRING_INDEX% = MGET(CP_PTR%)
        'PRINT "STRING_INDEX: " + STRING_INDEX% + "\r\n"
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY% = STRING_INDEX%
        EXIT SUB
    ENDIF

    IF CP_TAG% = %CP_Class THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        STRING_INDEX% = MGET(CP_PTR%)
        'PRINT "STRING_INDEX: " + STRING_INDEX% + "\r\n"
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY% = STRING_INDEX%
        EXIT SUB
    ENDIF

    IF CP_TAG% = %CP_Utf8 THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        CP_OFFSET% = MGET(CP_PTR%)
        CP_OFFSET& = JAR_CACHE_POS&[CP_IDX%]
        CP_OFFSET& = CP_OFFSET& + CP_OFFSET%
        'PRINT "CP OFFSET: " + CP_OFFSET% + ", " + CP_OFFSET& + "\r\n"
        FSEEK(FileHandle%, CP_OFFSET&)
        CALL ReadU(FileHandle%, 2)
        CPLen% = U2%
        CPValue$ = ""
        IF CPLen% > 0 THEN
            'PRINT "CP LEN: " + CPLen% + "\r\n"
            CPValue$ = SPACE(CPLen%)
            CPValue$ = FGET(FileHandle%)
        ENDIF
        'PRINT "CP VALUE: " + CPValue$ + "\r\n"
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY$ = CPValue$
        EXIT SUB
    ENDIF

    IF CP_TAG% = %CP_Methodref THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        CLASS_INDEX% = MGET(CP_PTR%)
        CP_PTR% = CP_PTR% + 2
        METHOD_INDEX% = MGET(CP_PTR%)
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY% = CLASS_INDEX%
        CP_ENTRY2% = METHOD_INDEX%
        EXIT SUB
    ENDIF

    IF CP_TAG% = %CP_NameAndType THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        NAME_INDEX% = MGET(CP_PTR%)
        CP_PTR% = CP_PTR% + 2
        TYPE_INDEX% = MGET(CP_PTR%)
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY% = NAME_INDEX%
        CP_ENTRY2% = TYPE_INDEX%
        EXIT SUB
    ENDIF
END SUB
