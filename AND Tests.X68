    ORG     $4000

    AND.B   D0,D6
    AND.B   (A1),D5
    AND.B   -(A2),D4
    AND.B   (A3)+,D3
    AND.B   $4002,D2
    AND.B   $9000,D1

    AND.W   D0,D6
    AND.W   (A1),D5
    AND.W   -(A2),D4
    AND.W   (A3)+,D3
    AND.W   $4002,D2
    AND.W   $9000,D1

    AND.L   D0,D6
    AND.L   (A1),D5
    AND.L   -(A2),D4
    AND.L   (A3)+,D3
    AND.L   $4002,D2
    AND.L   $9000,D1

    AND.B   D5,(A1)
    AND.B   D4,-(A2)
    AND.B   D3,(A3)+
    AND.B   D2,$4002
    AND.B   D1,$9000

    AND.W   D5,(A1)
    AND.W   D4,-(A2)
    AND.W   D3,(A3)+
    AND.W   D2,$4002
    AND.W   D1,$9000

    AND.L   D5,(A1)
    AND.L   D4,-(A2)
    AND.L   D3,(A3)+
    AND.L   D2,$4002
    AND.L   D1,$9000

    END     $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
