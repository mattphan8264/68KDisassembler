    ORG    $4000

    MOVE.B  D0,D1
    MOVE.W  A1,D1
    MOVE.L  (A2),D1
    MOVE.W  (A3)+,D2
    MOVE.W  -(A4),D2
    MOVE.L  $1234,D3
    MOVE.L  $000A1234,D3
    MOVE.B  #$1A,D4
    MOVE.W  #$1A1A,D4
    MOVE.L  #$1F1A1F1A,D4

    MOVE.B  D0,(A1)
    MOVE.W  A1,(A1)
    MOVE.L  (A2),(A1)
    MOVE.W  (A3)+,(A2)
    MOVE.W  -(A4),(A2)
    MOVE.L  $1234,(A3)
    MOVE.L  $000A1234,(A3)
    MOVE.B  #$1A,(A4)
    MOVE.W  #$1A1A,(A4)
    MOVE.L  #$1F1A1F1A,(A4)

    MOVE.B  D0,(A1)+
    MOVE.W  A1,(A1)+
    MOVE.L  (A2),(A1)+
    MOVE.W  (A3)+,(A2)+
    MOVE.W  -(A4),(A2)+
    MOVE.L  $1234,(A3)+
    MOVE.L  $000A1234,(A3)+
    MOVE.B  #$1A,(A4)+
    MOVE.W  #$1A1A,(A4)+
    MOVE.L  #$1F1A1F1A,(A4)+

    MOVE.B  D0,-(A1)
    MOVE.W  A1,-(A1)
    MOVE.L  (A2),-(A1)
    MOVE.W  (A3)+,-(A2)
    MOVE.W  -(A4),-(A2)
    MOVE.L  $1234,-(A3)
    MOVE.L  $000A1234,-(A3)
    MOVE.B  #$1A,-(A4)
    MOVE.W  #$1A1A,-(A4)
    MOVE.L  #$1F1A1F1A,-(A4)

    MOVE.B  D0,$23BC
    MOVE.W  A1,$23BC
    MOVE.L  (A2),$23BC
    MOVE.W  (A3)+,$23BC
    MOVE.W  -(A4),$23BC
    MOVE.L  $1234,$23BC
    MOVE.L  $000A1234,$23BC
    MOVE.B  #$1A,$23BC
    MOVE.W  #$1A1A,$23BC
    MOVE.L  #$1F1A1F1A,$23BC

    MOVE.B  D0,$23BC45EF
    MOVE.W  A1,$23BC45EF
    MOVE.L  (A2),$23BC45EF
    MOVE.W  (A3)+,$23BC45EF
    MOVE.W  -(A4),$23BC45EF
    MOVE.L  $1234,$23BC45EF
    MOVE.L  $000A1234,$23BC45EF
    MOVE.B  #$1A,$23BC45EF
    MOVE.W  #$1A1A,$23BC45EF
    MOVE.L  #$1F1A1F1A,$23BC45EF

    END    $4000

*~Font name~Courier~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
