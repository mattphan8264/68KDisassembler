*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $9000
START:                  ; first instruction of program

    MOVEA.L     #$1000,SP
    MOVE.B      #$1,D0
    MOVE.W      #$15,D1
    MOVE.W      #$2,D2
    MOVE.L      #$123431,D3
    MOVE.B      #$4,D4
    MOVE.B      #$5,D5
    MOVE.B      #$6,D6
    MOVE.W      #$7,D7
    MOVEA.L     #$1234,A1
    MOVEA.W     #$21,A2
    MOVEA.W     #$32,A3
    MOVEA.W     #$43,A4
    MOVEA.L     #$54,A5
    MOVEA.L     #$65,A6
    
    MOVEM.W     D0/D2/D3,-(SP)
    MOVEM.W     (SP)+,D0/D2/D3
    MOVEM.L     A1-A6/D0-D3,-(SP)
    MOVEM.L     (SP)+,A1-A6/D0-D3
    MOVEM.L     D1/D3-D5/D6/A0-A3/A5-A7,-(SP)
    MOVEM.L     (SP)+,D1/D3-D5/D6/A0-A3/A5-A7
    MOVEM.W     D1/D3-D5/D6/A0-A3/A5-A7,-(SP)
    MOVEM.W     (SP)+,D1/D3-D5/D6/A0-A3/A5-A7
    
    
* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
