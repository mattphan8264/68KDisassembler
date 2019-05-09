    ORG    $9000

    MULS.W #$1234,D2
    MULS.W #$2919,D4
    MULS.W D3,D4
    MULS.W (A1),D4
    MULS.W (A1)+,D4
    MULS.W -(A1),D4
    MULS.W $4002,D4
    MULS.W $9000,D4
    MULS.W $00004002,D4
    MULS.W $000F9000,D4

    END    $9000



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
