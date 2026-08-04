SUB SearchMethodCode(FileHandle%, JarIdx%, MethodSignature$)
    PRINT "Current Jar File Index: " + JarIdx% + "\r\n"

    CALL CalcCRC16 (MethodSignature$)
    TargetCRC16% = CalculatedCRC16%

    FOR i% = 1 TO 100
        ValidIdx% = (METHOD_CACHE_FILE_IDX%[i%] > 0)
        MatchCRC% = (METHOD_CACHE_CRC%[i%] = TargetCRC16%)
        IF ValidIdx% THEN
            IF MatchCRC% THEN
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

    PRINT "Method count: " + METHOD_COUNT% + "\r\n"

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
        PRINT "Name: " + Method$ + "\r\n"

        CALL GetConstantPoolEntry(JarIdx%, DescriptorIndex%, FileHandle%)
        Method$ = Method$ + CP_ENTRY$
        PRINT "Descriptor: " + CP_ENTRY$ + "\r\n"

        IF Method$ = MethodSignature$ THEN
            POS& = FPOS(FileHandle%)
            METHOD_CACHE_IDX% = METHOD_CACHE_IDX% + 1
            IF METHOD_CACHE_IDX% > 100 THEN
                METHOD_CACHE_IDX% = 1
            ENDIF
            METHOD_CACHE_FILE_IDX%[METHOD_CACHE_IDX%] = JarIdx%
            METHOD_CACHE_CRC%[METHOD_CACHE_IDX%] = TargetCRC16%
            METHOD_CACHE_POS&[METHOD_CACHE_IDX%] = POS&
            PRINT "Method found at position: " + POS& + "\r\n"
            EXIT SUB
        ELSE
            IF AttributesCount% > 0 THEN
                FOR a% = 1 TO AttributesCount%
                    CALL ReadU(FileHandle%, 2)
                    AttributeNameIndex% = U2%
                    CALL ReadU(FileHandle%, 4)
                    AttributeLength& = U4&
                    Pos& = FPOS(FileHandle%)
                    Pos& = Pos& + AttributeLength&
                    FSEEK(FileHandle%, Pos&)
                NEXT
            ENDIF
        ENDIF
    NEXT
END SUB

