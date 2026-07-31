SUB READ_CONSTANT_POOL(FILE_HANDLE%, CP_IDX%)
    CALL ReadU(FILE_HANDLE%, 2)
    CP_COUNT% = U2%

    CP_LEN% = CP_COUNT% * %CP_ENTRY_SIZE
    CP_CACHE%[CP_IDX%] = MALLOC(CP_LEN%)
    PTR% = CP_CACHE%[CP_IDX%]

    I% = 1
    OFFSET% = 0
    CURRENT_POS% = 1

    WHILE I% < CP_COUNT%
        TAG@ = FGET(FILE_HANDLE%)
        PRINT "Tag: " + TAG@ + "\r\n"
        CURRENT_POS% = CURRENT_POS% + 1

        MEMSETB(TAG@, PTR%, 1)
        PTR% = PTR% + 1

        IF TAG@ = %CP_Utf8 THEN
            MEMSETW(CURRENT_POS%, PTR%, 1)
            CALL ReadU(FILE_HANDLE%, 2)
            SLEN% = U2%
            CURRENT_POS% = CURRENT_POS% + 2
            CURRENT_POS% = CURRENT_POS% + SLEN%
            POS& = FPOS(FILE_HANDLE%)
            POS& = POS& + SLEN%
            FSEEK(FILE_HANDLE%, POS&)
        ENDIF

        IF TAG@ = %CP_Integer THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 4
        ENDIF

        IF TAG@ = %CP_Float THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 4
        ENDIF

        IF TAG@ = %CP_Long THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL3% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL3%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL4% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL4%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 8
        ENDIF

        IF TAG@ = %CP_Double THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL3% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL3%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL4% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL4%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 8
        ENDIF

        IF TAG@ = %CP_Class THEN
            TMP_VAL% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 2
        ENDIF

        IF TAG@ = %CP_String THEN
            TMP_VAL% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 2
        ENDIF

        IF TAG@ = %CP_Fieldref THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 4
        ENDIF

        IF TAG@ = %CP_Methodref THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 4
        ENDIF

        IF TAG@ = %CP_InterfaceMethodref THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 4
        ENDIF

        IF TAG@ = %CP_NameAndType THEN
            TMP_VAL1% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL1%, PTR%, 1)
            PTR% = PTR% + 2
            TMP_VAL2% = FGET(FILE_HANDLE%)
            MEMSETW(TMP_VAL2%, PTR%, 1)
            CURRENT_POS% = CURRENT_POS% + 4
        ENDIF

        OFFSET% = OFFSET% + %CP_ENTRY_SIZE
        I% = I% + 1
    WEND
END SUB
