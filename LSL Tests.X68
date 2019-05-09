    ORG     $9000

    LSL     (A0)
    LSL     (A1)+
    LSL     -(A2)
    LSL     $3000
    LSL     $F9000
    LSL     (A3)
    LSL     (A4)+
    LSL     -(A5)
    LSL     (A6)
    LSL     (A7)+
    LSL     $0001
    LSL     $FFFFFF

    LSL.B   #1,D7
    LSL.B   #2,D6
    LSL.B   #3,D5
    LSL.B   #4,D4
    LSL.B   #5,D3
    LSL.B   #6,D2
    LSL.B   #7,D1
    LSL.B   #8,D0

    LSL.W   #1,D7
    LSL.W   #2,D6
    LSL.W   #3,D5
    LSL.W   #4,D4
    LSL.W   #5,D3
    LSL.W   #6,D2
    LSL.W   #7,D1
    LSL.W   #8,D0

    LSL.L   #1,D7
    LSL.L   #2,D6
    LSL.L   #3,D5
    LSL.L   #4,D4
    LSL.L   #5,D3
    LSL.L   #6,D2
    LSL.L   #7,D1
    LSL.L   #8,D0

    LSL.B   D0,D7
    LSL.B   D1,D6
    LSL.B   D2,D5
    LSL.B   D3,D4
    LSL.B   D4,D3
    LSL.B   D5,D2
    LSL.B   D6,D1
    LSL.B   D7,D0

    LSL.W   D0,D7
    LSL.W   D1,D6
    LSL.W   D2,D5
    LSL.W   D3,D4
    LSL.W   D4,D3
    LSL.W   D5,D2
    LSL.W   D6,D1
    LSL.W   D7,D0

    LSL.L   D0,D7
    LSL.L   D1,D6
    LSL.L   D2,D5
    LSL.L   D3,D4
    LSL.L   D4,D3
    LSL.L   D5,D2
    LSL.L   D6,D1
    LSL.L   D7,D0

    END     $9000


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
