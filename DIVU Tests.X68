    ORG    $4000

    DIVU.W #$1234,D2
    DIVU.W D3,D2
    DIVU.W (A1),D4
    DIVU.W (A1)+,D1
    DIVU.W -(A1),D5
    DIVU.W $4002,D1
    DIVU.W $9000,D4
    DIVU.W $00004002,D3
    DIVU.W $000F9000,D1
    DIVU.W #29183,D3

    END    $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
