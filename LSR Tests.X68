    ORG     $9000

    LSR     (A0)
    LSR     (A1)+
    LSR     -(A2)
    LSR     $3000
    LSR     $F9000
    LSR     (A3)
    LSR     (A4)+
    LSR     -(A5)
    LSR     (A6)
    LSR     (A7)+
    LSR     $0001
    LSR     $FFFFFF

    LSR.B   #1,D7
    LSR.B   #2,D6
    LSR.B   #3,D5
    LSR.B   #4,D4
    LSR.B   #5,D3
    LSR.B   #6,D2
    LSR.B   #7,D1
    LSR.B   #8,D0

    LSR.W   #1,D7
    LSR.W   #2,D6
    LSR.W   #3,D5
    LSR.W   #4,D4
    LSR.W   #5,D3
    LSR.W   #6,D2
    LSR.W   #7,D1
    LSR.W   #8,D0

    LSR.L   #1,D7
    LSR.L   #2,D6
    LSR.L   #3,D5
    LSR.L   #4,D4
    LSR.L   #5,D3
    LSR.L   #6,D2
    LSR.L   #7,D1
    LSR.L   #8,D0

    LSR.B   D0,D7
    LSR.B   D1,D6
    LSR.B   D2,D5
    LSR.B   D3,D4
    LSR.B   D4,D3
    LSR.B   D5,D2
    LSR.B   D6,D1
    LSR.B   D7,D0

    LSR.W   D0,D7
    LSR.W   D1,D6
    LSR.W   D2,D5
    LSR.W   D3,D4
    LSR.W   D4,D3
    LSR.W   D5,D2
    LSR.W   D6,D1
    LSR.W   D7,D0

    LSR.L   D0,D7
    LSR.L   D1,D6
    LSR.L   D2,D5
    LSR.L   D3,D4
    LSR.L   D4,D3
    LSR.L   D5,D2
    LSR.L   D6,D1
    LSR.L   D7,D0

    END     $9000



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
