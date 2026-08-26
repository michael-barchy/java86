SUB ReadConstantPool(FileHandle%, JarIdx%, ClassName$)
    CALL CalcCRC16(ClassName$)
    TargetCRC16% = CalculatedCRC16%
    FOR I% = 1 TO %MAX_CP_CACHE
        IF CP_CACHE%[I%] > 0 THEN
            IF CP_CRC%[I%] = TargetCRC16% THEN
                CP_IDX% = I%
                POS& = CP_POS&[CP_IDX%]
                FSEEK(FileHandle%, POS&)
                EXIT SUB
            ENDIF
        ENDIF
    NEXT

    CP_IDX% = 0

    FOR I% = 1 TO %MAX_CP_CACHE
        IF CP_CACHE%[I%] = 0 THEN
            CP_IDX% = I%
            EXIT FOR
        ENDIF
    NEXT

    IF CP_IDX% = 0 THEN
        FOR I% = 1 TO %MAX_CP_CACHE
            FOUND% = 0
            FOR P% = 1 TO %MAX_PROCESS
                IF PROCESS_CPOOL%[P%] = I% THEN
                    FOUND% = 1
                    EXIT FOR
                ENDIF
            NEXT
            IF FOUND% = 0 THEN
                CP_IDX% = I%
                PTR% = CP_CACHE%[CP_IDX%]
                IF PTR% > 0 THEN
                    MFREE(PTR%)
                ENDIF
                EXIT FOR
            ENDIF
        NEXT
    ENDIF

    IF CP_IDX% = 0 THEN
        CP_IDX% = 1
        PTR% = CP_CACHE%[CP_IDX%]
        IF PTR% > 0 THEN
            MFREE(PTR%)
        ENDIF
    ENDIF

    CALL ReadU(FileHandle%, 2)
    CP_COUNT% = U2% - 1
    CP_NB%[CP_IDX%] = CP_COUNT%

    CP_LEN% = CP_COUNT% * %CP_ENTRY_SIZE
    PTR%  = MALLOC(CP_LEN%)
    CP_CACHE%[CP_IDX%] = PTR%
    CP_CRC%[CP_IDX%] = TargetCRC16%
    CP_JAR%[CP_IDX%] = JarIdx%
    JarPos& = JAR_CACHE_POS&[JarIdx%]

    FOR I% = 1 TO CP_COUNT%
        TAG@ = FGET(FileHandle%)

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
    JarIdx% = CP_JAR%[CP_IDX%]
    CP_PTR% = CP_CACHE%[CP_IDX%]
    CP_OFFSET% = EntryIdx% - 1
    CP_OFFSET% = CP_OFFSET% * %CP_ENTRY_SIZE
    CP_PTR% = CP_PTR% + CP_OFFSET%
    B$ = CHR(0)
    B$ = MGET(CP_PTR%)
    CP_TAG% = ASC(B$)
    CP_ENTRY% = 0
    CP_ENTRY2% = 0
    CP_ENTRY$ = ""

    IF CP_TAG% = %CP_String THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        STRING_INDEX% = MGET(CP_PTR%)
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY% = STRING_INDEX%
        EXIT SUB
    ENDIF

    IF CP_TAG% = %CP_Class THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        STRING_INDEX% = MGET(CP_PTR%)
        FSEEK(FileHandle%, Offset&)
        CP_ENTRY% = STRING_INDEX%
        EXIT SUB
    ENDIF

    IF CP_TAG% = %CP_Utf8 THEN
        Offset& = FPOS(FileHandle%)
        CP_PTR% = CP_PTR% + 1
        CP_OFFSET% = MGET(CP_PTR%)
        CP_OFFSET& = JAR_CACHE_POS&[JarIdx%]
        CP_OFFSET& = CP_OFFSET& + CP_OFFSET%
        FSEEK(FileHandle%, CP_OFFSET&)
        CALL ReadU(FileHandle%, 2)
        CPLen% = U2%
        CPValue$ = ""
        IF CPLen% > 0 THEN
            CPValue$ = SPACE(CPLen%)
            CPValue$ = FGET(FileHandle%)
        ENDIF
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
