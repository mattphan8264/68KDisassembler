*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000             ; first instruction of program
    
    

    ADDA.W  (A1),A3
    ADDA.L  (A1),A3

    ADDA.W  (A1)+,A3
    ADDA.L  (A1)+,A3

    ADDA.W  -(A1),A3
    ADDA.L  -(A1),A3
    

    ADDA.W  $4002,A3
    ADDA.L  $4002,A3

    ADDA.W  $9005,A3
    ADDA.L  $9005,A3

    ADDA.W  $00004002,A3
    ADDA.L  $00004002,A3

    ADDA.W  $00009005,A3
    ADDA.L  $08009005,A3
    

    ADDA.W  #$4002,A3
    ADDA.L  #$4002,A3

    ADDA.W  #$9005,A3
    ADDA.L  #$9005,A3
    

    ADDA.W  A2,A3
    ADDA.L  A2,A3

    ADDA.W  D3,A3
    ADDA.L  D3,A3

    END    $7000 








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
