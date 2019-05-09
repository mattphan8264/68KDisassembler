    ORG    $4000

    ADDA.W D4,A0
    ADDA.W A2,A1
    ADDA.W (A2),A2
    ADDA.W -(A2),A3
    ADDA.W (A2)+,A4
    ADDA.W $4002,A5
    ADDA.W $9000,A6
    ADDA.W #$23,A7

    ADDA.L #$34,A7
    ADDA.L D4,A6
    ADDA.L A2,A5
    ADDA.L (A2),A4
    ADDA.L -(A2),A3
    ADDA.L (A2)+,A2
    ADDA.L $4002,A1
    ADDA.L $9000,A0

    END    $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
