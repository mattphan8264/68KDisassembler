    ORG    $4000

    MULU.W #$1234,D2
    MULU.W #$2919,D4
    MULU.W D3,D4
    MULU.W (A1),D4
    MULU.W (A1)+,D4
    MULU.W -(A1),D4
    MULU.W $4002,D4
    MULU.W $9000,D4
    MULU.W $00004002,D4
    MULU.W $000F9000,D4

    END    $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
