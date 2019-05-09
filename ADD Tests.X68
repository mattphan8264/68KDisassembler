    ORG     $4000

    ADD.B   D0,D6
    ADD.B   (A1),D5
    ADD.B   -(A2),D4
    ADD.B   (A3)+,D3
    ADD.B   $4002,D2
    ADD.B   $9000,D1

    ADD.W   D0,D6
    ADD.W   (A1),D5
    ADD.W   -(A2),D4
    ADD.W   (A3)+,D3
    ADD.W   $4002,D2
    ADD.W   $9000,D1

    ADD.L   D0,D6
    ADD.L   (A1),D5
    ADD.L   -(A2),D4
    ADD.L   (A3)+,D3
    ADD.L   $4002,D2
    ADD.L   $9000,D1

    ADD.B   D5,(A1)
    ADD.B   D4,-(A2)
    ADD.B   D3,(A3)+
    ADD.B   D2,$4002
    ADD.B   D1,$9000

    ADD.W   D5,(A1)
    ADD.W   D4,-(A2)
    ADD.W   D3,(A3)+
    ADD.W   D2,$4002
    ADD.W   D1,$9000

    ADD.L   D5,(A1)
    ADD.L   D4,-(A2)
    ADD.L   D3,(A3)+
    ADD.L   D2,$4002
    ADD.L   D1,$9000

    END     $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
