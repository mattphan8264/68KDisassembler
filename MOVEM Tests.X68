    ORG    $4000

    MOVEM.W D2,-(A7)
    MOVEM.W A5,-(A7)
    MOVEM.W D2/A3,-(A7)
    MOVEM.W (A0)+,D2
    MOVEM.W (A2)+,A5
    MOVEM.W (A7)+,D2/A3
    MOVEM.W (A3),D2/A3-A5
    MOVEM.W $5000,D2/A3-A5
    MOVEM.W $F5000,D0-D2/D4/A1/A3-A5

    MOVEM.L D0-D7/A0-A7,$5000
    MOVEM.L D0/D7/A0/A7,$F9000
    MOVEM.L $5000,D0-D7/A0-A7

    END    $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
