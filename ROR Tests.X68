    ORG    $9000
    ROR.W   #$02,D4
    ROR.W   #$0002,D4
    ROR     $3112
    ROR     $5612
    ROR     $7812
    ROR     $83112
    ROR.B   #$02,D4

    ROR     (A1)
    ROR     -(A1)
    ROR     (A1)+
    ROR      $4002
    ROR     $00004002
    ROR     $9000
    ROR     $00009000
    ROR.W   #$02,D4
    ROR.W   #$0002,D4

    ROR.L   #$02,D4
    ROR.L   #$0002,D4
    ROR.L   #$00000002,D4

    ROR.B   D3,D4
    ROR.W   D3,D4
    ROR.L   D3,D4

    ROR     $3112

    END    $9000




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
