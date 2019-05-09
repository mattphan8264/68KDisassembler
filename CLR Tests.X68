    ORG    $4000

    CLR.W   D1
    CLR.W   (A1)+
    CLR.W   -(A1)
    CLR.W   (A1)

    CLR.W   D2
    CLR.W   (A3)+
    CLR.W   -(A4)
    CLR.W   (A5)

    CLR.B   $19000
    CLR.W   $9000
    CLR.L   $9000

    CLR.B   $00007391
    CLR.W   $00007000
    CLR.L   $00007000

    END $4000



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
