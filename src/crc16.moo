SUB CalcCRC16 (StringData$)
    CalculatedCRC16% = -1
    StringLength% = LEN(StringData$)

    FOR I% = 1 TO StringLength%
        C$ = MID(StringData$, I%, 1)
        ByteVal% = ASC(C$)
        CalculatedCRC16% = CalculatedCRC16% XOR ByteVal%

        FOR J% = 1 TO 8
            LowestBit% = CalculatedCRC16% AND 1

            Div2% = CalculatedCRC16% \ 2
            CalculatedCRC16% = (Div2%) AND 32767

            IF LowestBit% = 1 THEN
                CalculatedCRC16% = CalculatedCRC16% XOR %LowBitsXor
            ENDIF
        NEXT
    NEXT
END SUB
