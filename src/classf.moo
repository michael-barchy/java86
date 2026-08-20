SUB ReadU(FileHandle%, Bytes%)
    Buff% = MALLOC(Bytes%)

    U% = 0
    FOR I% = 1 TO Bytes%
        B$ = SPACE(1)
        B$ = FGET(FileHandle%)
        U% = ASC(B$)
        U@ = U%
        PTR% = Bytes% - I%
        PTR% = PTR% + Buff%
        MEMSETB(U@, PTR%, 1)
    NEXT

    U4& = MGET(Buff%)
    U2% = MGET(Buff%)
    U1% = U%

    MFREE(Buff%)
END SUB

SUB ParseClass(F%)
    CALL ReadU(F%, 4)

    Magic$ = HEX32(U4&)
    IF Magic$ <> "cafebabe" THEN
        FCLOSE(F%)
        PRINT "Invalid magic: " + Magic$ + "\r\n"
        END
    ENDIF

    CALL ReadU(F%, 4) 'Ignore versions
END SUB
