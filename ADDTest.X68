*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000             ; first instruction of program
    
    ADD.B  D2,(A1)
    ADD.W  D2,(A1)
    ADD.L  D2,(A1)
    ADD.B  D2,(A1)+
    ADD.W  D2,(A1)+
    ADD.L  D2,(A1)+
    ADD.B  D2,-(A1)
    ADD.W  D2,-(A1)
    ADD.L  D2,-(A1)
    
    ADD.B  D2,$4002
    ADD.W  D2,$4002
    ADD.L  D2,$4002
    ADD.B  D2,$9005
    ADD.W  D2,$9005
    ADD.L  D2,$9005
    ADD.B  D2,$00004002
    ADD.W  D2,$00004002
    ADD.L  D2,$00004002
    ADD.B  D2,$00009005
    ADD.W  D2,$00009005
    ADD.L  D2,$08009005
    
    
    ADD.B  (A1),D2
    ADD.W  (A1),D2
    ADD.L  (A1),D2
    ADD.B  (A1)+,D2
    ADD.W  (A1)+,D2
    ADD.L  (A1)+,D2
    ADD.B  -(A1),D2
    ADD.W  -(A1),D2
    ADD.L  -(A1),D2
    
    ADD.B  $4002,D2
    ADD.W  $4002,D2
    ADD.L  $4002,D2
    ADD.B  $9005,D2
    ADD.W  $9005,D2
    ADD.L  $9005,D2
    ADD.B  $00004002,D2
    ADD.W  $00004002,D2
    ADD.L  $00004002,D2
    ADD.B  $00009005,D2
    ADD.W  $00009005,D2
    ADD.L  $08009005,D2
    

    ADD.W  A3,D2
    ADD.L  A3,D2
    ADD.B  D3,D2
    ADD.W  D3,D2
    ADD.L  D3,D2

    END    $7000 








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
