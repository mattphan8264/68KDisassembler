*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $9000             ; first instruction of program

    BCLR.L  #$40000000,D3
    BCLR.L  D5,D4
    BCLR.L  D5,D3
    BCLR.L  D5,D2
    BCLR.B  D5,(A1)
    BCLR.B  D5,(A1)+
    BCLR.B  D2,-(A1)

    
    BCLR.B  D5,$4002
    BCLR.B  D5,$9005
    BCLR.B  D5,$00004002
    BCLR.B  D5,$00009005



    BCLR.L  #$40000000,D1
    BCLR.B  #$00,(A1)

    BCLR.B  #$40,(A1)
    BCLR.B  #$40,(A1)+
    BCLR.B  #$40,-(A1)
    BCLR.B  #$40,$4002
    BCLR.B  #$40,$9005
    BCLR.B  #$40,$00004002
    BCLR.B  #$40,$00009005

    END    $9000 







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
