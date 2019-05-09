    ORG     $9000

    OR.B   D0,D6
    OR.B   (A1),D5
    OR.B   -(A2),D4
    OR.B   (A3)+,D3
    OR.B   $4002,D2
    OR.B   $9000,D1

    OR.W   D0,D6
    OR.W   (A1),D5
    OR.W   -(A2),D4
    OR.W   (A3)+,D3
    OR.W   $4002,D2
    OR.W   $9000,D1

    OR.L   D0,D6
    OR.L   (A1),D5
    OR.L   -(A2),D4
    OR.L   (A3)+,D3
    OR.L   $4002,D2
    OR.L   $9000,D1

    OR.B   D5,(A1)
    OR.B   D4,-(A2)
    OR.B   D3,(A3)+
    OR.B   D2,$4002
    OR.B   D1,$9000

    OR.W   D5,(A1)
    OR.W   D4,-(A2)
    OR.W   D3,(A3)+
    OR.W   D2,$4002
    OR.W   D1,$9000

    OR.L   D5,(A1)
    OR.L   D4,-(A2)
    OR.L   D3,(A3)+
    OR.L   D2,$4002
    OR.L   D1,$9000

    END     $9000


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
