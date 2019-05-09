    ORG     $9000

    BCC     $9000    *BFEE
    BCC     $3FF8 *F6
    BCC     $4008 *04
    BCC     $2000 *DFFA
    BCC     $6000 *1FF6
    BCC     $C00D *7FFF
    BCC     $9000    *BFEE
    
    BGE     $3FF8 *F6
    BGE     $4008 *04
    BGE     $2000 *DFFA
    BGE     $6000 *1FF6
    BGE     $C00D *7FFF
    BGE     $9000    *BFEE
    
    BCS     $3FF8 *F6
    BCS     $4008 *04
    BCS     $2000 *DFFA
    BCS     $6000 *1FF6
    BCS     $C00D *7FFF
    BCS     $9000    *BFEE
    
    BLT     $3FF8 *F6
    BLT     $4008 *04
    BLT     $2000 *DFFA
    BLT     $6000 *1FF6
    BLT     $C00D *7FFF
    BLT     $9000    *BFEE
    
    BVC     $3FF8 *F6
    BVC     $4008 *04
    BVC     $2000 *DFFA
    BVC     $6000 *1FF6
    BVC     $C00D *7FFF
    BVC     $9000    *BFEE

    END     $9000



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
