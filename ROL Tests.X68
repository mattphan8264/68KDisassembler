    ORG    $9000

    ROL     $3112
    ROL     $5612
    ROL   $7812
    ROL   $83112
    ROL.B #$02,D4

    ROL   (A1)
    ROL   -(A1)
    ROL   (A1)+
    ROL   $4002
    ROL   $00004002
    ROL   $9000
    ROL   $00009000
    ROL.W #$02,D4
    ROL.W #$0002,D4

    ROL.L #$02,D4
    ROL.L #$0002,D4
    ROL.L #$00000002,D4

    ROL.B D3,D4
    ROL.W D3,D4
    ROL.L D3,D4
    ROL   $3112

    END    $9000




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
