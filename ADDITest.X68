*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000

    ADDI.B  #$40,D4
    ADDI.W  #$4000,D4
    ADDI.L  #$40000000,D4
    ADDI.B  #$40,(A1)
    ADDI.W  #$4000,(A1)
    ADDI.L  #$40000000,(A1)
    ADDI.B  #$40,(A1)+
    ADDI.W  #$4000,(A1)+
    ADDI.L  #$40000000,(A1)+
    ADDI.B  #$40,-(A1)
    ADDI.W  #$4000,-(A1)
    ADDI.L  #$40000000,-(A1)
    
    ADDI.B  #$40,$4002
    ADDI.W  #$4000,$4002
    ADDI.L  #$40000000,$4002
    ADDI.B  #$40,$9005
    ADDI.W  #$4000,$9005
    ADDI.L  #$40000000,$9005
    ADDI.B  #$40,$00004002
    ADDI.W  #$4000,$00004002
    ADDI.L  #$40000000,$00004002
    ADDI.B  #$40,$00009005
    ADDI.W  #$4000,$00009005
    ADDI.L  #$40000000,$00009005


    END    $7000        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
