    ORG    $4000

    SUBI.B #$40,D0
    SUBI.W #$4000,D1
    SUBI.L #$40000000,D2
    SUBI.B #$40,(A1)
    SUBI.W #$4000,(A2)
    SUBI.L #$40000000,(A3)
    SUBI.B #$40,(A4)+
    SUBI.W #$4000,(A5)+
    SUBI.L #$40000000,(A6)+
    SUBI.B #$40,-(A7)
    SUBI.W #$4000,-(A1)
    SUBI.L #$40000000,-(A1)

    SUBI.B #$40,$4002
    SUBI.W #$4000,$4002
    SUBI.L #$40000000,$4002
    SUBI.B #$40,$9005
    SUBI.W #$4000,$9005
    SUBI.L #$40000000,$9005
    SUBI.B #$40,$00004002
    SUBI.W #$4000,$00004002
    SUBI.L #$40000000,$00004002
    SUBI.B #$40,$00009005
    SUBI.W #$4000,$00009005
    SUBI.L #$40000000,$00009005
    MOVE.B #20,D0

    END    $4000


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
