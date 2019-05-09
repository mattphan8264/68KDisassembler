    ORG    $9000

    DIVS.W #$1234,D2
    DIVS.W #$2919,D4
    DIVS.W D3,D4
    DIVS.W (A1),D4
    DIVS.W (A1)+,D4
    DIVS.W -(A1),D4
    DIVS.W $4002,D4
    DIVS.W $9000,D4
    DIVS.W $00004002,D4
    DIVS.W $000F9000,D4

    END    $9000




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
