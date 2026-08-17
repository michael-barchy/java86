SUB SearchMethodCode(FileHandle%, JarIdx%, MethodSignature$)
    'PRINT "Current Jar File Index: " + FileHandle% + ", " + JarIdx% + ", " + MethodSignature$ + "\r\n"

    METHOD_CACHE_IDX%  = 0

    CALL CalcCRC16 (MethodSignature$)
    TargetCRC16% = CalculatedCRC16%

    FOR i% = 1 TO 100
        ValidIdx% = 0
        IF METHOD_CACHE_FILE_IDX%[i%] > 0 THEN
            ValidIdx% = 1
        ENDIF
        MatchCRC% = 0
        IF METHOD_CACHE_CRC%[i%] = TargetCRC16% THEN
            MatchCRC% = 1
        ENDIF
        IF ValidIdx% = 1 THEN
            IF MatchCRC% = 1 THEN
                METHOD_CACHE_IDX% = i%
                EXIT SUB
            ENDIF
        ENDIF
    NEXT

    CALL ReadU(FileHandle%, 2)
    METHOD_COUNT% = U2%

    IF METHOD_COUNT% = 0 THEN
        EXIT SUB
    ENDIF

    'PRINT "Method count: " + METHOD_COUNT% + "\r\n"

    FOR i% = 1 TO METHOD_COUNT%
        CALL ReadU(FileHandle%, 2)
        AccessFlags% = U2%
        CALL ReadU(FileHandle%, 2)
        NameIndex% = U2%
        CALL ReadU(FileHandle%, 2)
        DescriptorIndex% = U2%
        CALL ReadU(FileHandle%, 2)
        AttributesCount% = U2%

        CALL GetConstantPoolEntry(JarIdx%, NameIndex%, FileHandle%)
        Method$ = CP_ENTRY$
        'PRINT "Name: " + Method$ + "\r\n"

        CALL GetConstantPoolEntry(JarIdx%, DescriptorIndex%, FileHandle%)
        Method$ = Method$ + CP_ENTRY$
        'PRINT "Descriptor: " + CP_ENTRY$ + "\r\n"

        IF AttributesCount% > 0 THEN
            FOR a% = 1 TO AttributesCount%
                CALL ReadU(FileHandle%, 2)
                AttributeNameIndex% = U2%
                CALL GetConstantPoolEntry(JarIdx%, AttributeNameIndex%, FileHandle%)
                Attribute$ = CP_ENTRY$
                'PRINT "Attribute: " + Attribute$ + "\r\n"
                CALL ReadU(FileHandle%, 4)
                AttributeLength& = U4&
                IsCodeAttribute% = FALSE
                IF Method$ = MethodSignature$ Then
                    IF Attribute$ = "Code" THEN
                        IsCodeAttribute% = TRUE
                    ENDIF
                ENDIF
                IF IsCodeAttribute% = TRUE THEN
                    CALL ReadU(FileHandle%, 2) 'Ignore max_stack
                    CALL ReadU(FileHandle%, 2) 'Ignore max_locals
                    CALL ReadU(FileHandle%, 4)
                    CODE_LEN% = U2%
                    POS& = FPOS(FileHandle%)
                    METHOD_CACHE_COUNT% = METHOD_CACHE_COUNT% + 1
                    IF METHOD_CACHE_COUNT% > %MAX_METHOD_CACHE THEN
                        METHOD_CACHE_COUNT% = 1
                    ENDIF
                    METHOD_CACHE_IDX% = METHOD_CACHE_COUNT%
                    METHOD_CACHE_FILE_IDX%[METHOD_CACHE_IDX%] = JarIdx%
                    METHOD_CACHE_CRC%[METHOD_CACHE_IDX%] = TargetCRC16%
                    METHOD_CACHE_POS&[METHOD_CACHE_IDX%] = POS&
                    METHOD_CACHE_LEN%[METHOD_CACHE_IDX%] = CODE_LEN%
                    'PRINT "Method code found at position: " + POS& + "\r\n"
                    EXIT SUB
                ELSE
                    Pos& = FPOS(FileHandle%)
                    Pos& = Pos& + AttributeLength&
                    FSEEK(FileHandle%, Pos&)
                ENDIF
            NEXT
        ENDIF
    NEXT
END SUB

