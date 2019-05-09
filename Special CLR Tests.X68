    ORG    $4000

    CLR     D1
    CLR     (A1)+
    CLR     -(A1)
    CLR     (A1)

    CLR     D2
    CLR     (A3)+
    CLR     -(A4)
    CLR     (A5)

    CLR.B   $9000
    CLR.W   $9000
    CLR.L   $9000

    CLR.B   $00007000
    CLR.W   $00007000
    CLR.L   $00007000

    END $4000

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
