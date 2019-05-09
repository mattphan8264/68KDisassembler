    ORG    $9000

    CMP.B   #$1A,D4
    CMP.W   #$1A1A,D4
    CMP.L   #$1F1A1F1A,D4
    CMP.B   D0,D1
    CMP.W   A1,D1
    CMP.L   (A2),D1
    CMP.W   (A3)+,D2
    CMP.W   -(A4),D2
    CMP.L   $1234,D3
    CMP.L   $000A1234,D3
    CMP.B   #$1A,D4
    CMP.W   #$1A1A,D4
    CMP.L   #$1F1A1F1A,D4

    END    $9000



*~Font name~Courier~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
