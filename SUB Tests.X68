    ORG     $4000

    SUB.B   D0,D6
    SUB.B   (A1),D5
    SUB.B   -(A2),D4
    SUB.B   (A3)+,D3
    SUB.B   $4002,D2
    SUB.B   $9000,D1

    SUB.W   D0,D6
    SUB.W   (A1),D5
    SUB.W   -(A2),D4
    SUB.W   (A3)+,D3
    SUB.W   $4002,D2
    SUB.W   $9000,D1

    SUB.L   D0,D6
    SUB.L   (A1),D5
    SUB.L   -(A2),D4
    SUB.L   (A3)+,D3
    SUB.L   $4002,D2
    SUB.L   $9000,D1

    SUB.B   D5,(A1)
    SUB.B   D4,-(A2)
    SUB.B   D3,(A3)+
    SUB.B   D2,$4002
    SUB.B   D1,$9000

    SUB.W   D5,(A1)
    SUB.W   D4,-(A2)
    SUB.W   D3,(A3)+
    SUB.W   D2,$4002
    SUB.W   D1,$9000

    SUB.L   D5,(A1)
    SUB.L   D4,-(A2)
    SUB.L   D3,(A3)+
    SUB.L   D2,$4002
    SUB.L   D1,$9000

    END     $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
