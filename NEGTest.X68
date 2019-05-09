*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $9000             ; first instruction of program

    NEG.B  (A1)
    NEG.W  (A1)
    NEG.L  (A1)
    NEG.B  (A1)+
    NEG.W  (A1)+
    NEG.L  (A1)+
    NEG.B  -(A1)
    NEG.W  -(A1)
    NEG.L  -(A1)
    
    NEG.B  D7
    NEG.W  D7
    NEG.L  D7
    
    
    NEG.B  $4002
    NEG.W  $4002
    NEG.L  $4002
    NEG.B  $9005
    NEG.W  $9005
    NEG.L  $9005
    NEG.B  $00004002
    NEG.W  $00004002
    NEG.L  $00004002
    NEG.B  $00009005
    NEG.W  $00009005
    NEG.L  $08009005


    END    $9000 









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
