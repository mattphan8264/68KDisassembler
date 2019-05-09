*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $9000             ; first instruction of program

    EOR.B  D5,D4
    EOR.W  D5,D4
    EOR.L  D5,D4
    EOR.B  D5,(A1)
    EOR.W  D5,(A1)
    EOR.L  D5,(A1)
    EOR.B  D5,(A1)+
    EOR.W  D5,(A1)+
    EOR.L  D5,(A1)+
    EOR.B  D5,-(A1)
    EOR.W  D5,-(A1)
    EOR.L  D5,-(A1)
    
    EOR.B  D5,$4002
    EOR.W  D5,$4002
    EOR.L  D5,$4002
    EOR.B  D5,$9005
    EOR.W  D5,$9005
    EOR.L  D5,$9005
    EOR.B  D5,$00004002
    EOR.W  D5,$00004002
    EOR.L  D5,$00004002
    EOR.B  D5,$00009005
    EOR.W  D5,$00009005
    EOR.L  D5,$00009005


    END    $9000 




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
