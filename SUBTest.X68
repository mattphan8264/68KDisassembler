*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000             ; first instruction of program

    OR.B    D2, $00004002
    OR.B    $00004002,D2
    SUB.B  D2,(A1)
    SUB.W  D2,(A1)
    SUB.L  D2,(A1)
    SUB.B  D2,(A1)+
    SUB.W  D2,(A1)+
    SUB.L  D2,(A1)+
    SUB.B  D2,-(A1)
    SUB.W  D2,-(A1)
    SUB.L  D2,-(A1)
    
    SUB.B  D2,$4002
    SUB.W  D2,$4002
    SUB.L  D2,$4002
    SUB.B  D2,$9005
    SUB.W  D2,$9005
    SUB.L  D2,$9005
    SUB.B  D2,$00004002
    SUB.W  D2,$00004002
    SUB.L  D2,$00004002
    SUB.B  D2,$00009005
    SUB.W  D2,$00009005
    SUB.L  D2,$08009005
    
    
    SUB.B  (A1),D2
    SUB.W  (A1),D2
    SUB.L  (A1),D2
    SUB.B  (A1)+,D2
    SUB.W  (A1)+,D2
    SUB.L  (A1)+,D2
    SUB.B  -(A1),D2
    SUB.W  -(A1),D2
    SUB.L  -(A1),D2
    
    SUB.B  $4002,D2
    SUB.W  $4002,D2
    SUB.L  $4002,D2
    SUB.B  $9005,D2
    SUB.W  $9005,D2
    SUB.L  $9005,D2
    SUB.B  $00004002,D2
    SUB.W  $00004002,D2
    SUB.L  $00004002,D2
    SUB.B  $00009005,D2
    SUB.W  $00009005,D2
    SUB.L  $08009005,D2
    

    SUB.W  A3,D2
    SUB.L  A3,D2
    SUB.B  D3,D2
    SUB.W  D3,D2
    SUB.L  D3,D2

    END    $7000 







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
