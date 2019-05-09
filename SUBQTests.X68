    ORG    $9000

    SUBQ.B #1,D0
    SUBQ.B #2,(A1)
    SUBQ.B #3,-(A3)
    SUBQ.B #4,(A4)+
    SUBQ.B #5,$4002
    SUBQ.B #6,$9000
    SUBQ.B #7,$000F9000

    SUBQ.W #8,D2
    SUBQ.W #1,A7
    SUBQ.W #2,(A6)
    SUBQ.W #2,-(A5)
    SUBQ.W #2,(A4)+
    SUBQ.W #3,$4002
    SUBQ.W #2,$9000
    SUBQ.W #2,$000F9000

    SUBQ.L #2,D4
    SUBQ.L #5,A3
    SUBQ.L #2,(A5)
    SUBQ.L #4,-(A4)
    SUBQ.L #2,(A2)+
    SUBQ.L #2,$4002
    SUBQ.L #1,$9000
    SUBQ.L #2,$000F9000

    END    $9000




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
