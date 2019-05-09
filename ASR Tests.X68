    ORG    $9000

    ASR.B   #$02,D4
    ASR     (A1)
    ASR     -(A1)
    ASR     (A1)+
    ASR     $4002
    ASR     $00004002
    ASR     $9000
    ASR     $00009000
    ASR.W #$02,D4
    ASR.W #$0002,D4

    ASR.L #$02,D4
    ASR.L #$0002,D4
    ASR.L #$00000002,D4

    ASR.B D3,D4
    ASR.W D3,D4
    ASR.L D3,D4

    END    $9000



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
