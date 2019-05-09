* --------------------------------------------------------------------------
* Title      : Disassembler
* Written by : Matthew Phan, Jakob Delzer, Jarod Guerrero
* Date       : March 17, 2019

*---------------------------------------------------------------------------
    ORG    $1000    
*---------------------------------------------------------------------------

START:
    ***********************************************************
    
    JSR     loadIO
    BRA     assignStartAddress

    SIMHALT
  
* Opens up the config file, reads in the two addresses, and loads them into the
* variables startingAddress and endingAddress  
loadIO
    *open the cfg file
    MOVE.B  #51, D0
    LEA     config, A1
    TRAP    #15
    MOVE.L  D1, fileID      * save file ID
    
    *reading from the file
    LEA     startingAddress, A1
    MOVE.L  fileID, D1
    MOVE.W  #AddressLength, D2
    MOVE.B  #53, D0
    TRAP    #15
    
    MOVE.L  A1,A3
    
    LEA     inbetweenAddress, A1
    MOVE.L  fileID, D1
    MOVE.W  #2, D2
    MOVE.B  #53, D0
    TRAP    #15
    
    LEA     endingAddress, A1
    MOVE.L  fileID, D1
    MOVE.W  #AddressLength, D2
    MOVE.B  #53, D0
    TRAP    #15
    
    MOVE.L  A1,A4
    
    
    *close the file after reading
    MOVE.B  #56, D0
    TRAP    #15
    
    *converting the starting string to hex and storing the value at D3
    MOVEA.L     #startingAddress, A1
    JSR         AsciiToHex
    MOVE.L      D7, D3
    
    *converting the ending string to hex and storing the value at D4
    MOVEA.L     #endingAddress, A1
    JSR         AsciiToHex
    MOVE.L      D7, D4

    *No File Error
    CMPI.L    #$FFFFFFFF, D3
    BEQ     CfgErrorNotFound
    CMPI.L    #$FFFFFFFF, D4
    BEQ     CfgErrorNotFound
    
    *odd error
    BTST #0, D3
    BNE  CfgErrorOdd
    BTST #0, D4
    BNE  CfgErrorOdd
    
    *Out of range Error
    CMPI.L    #$FFFFFF, D3
    BGT    CfgErrorOutofRange
    CMPI.L    #$FFFFFF, D4
    BGT     CfgErrorOutofRange
    
    CMPI.L    #$00000000, D3
    BLT    CfgErrorOutofRange
    CMPI.L    #$00000000, D4
    BLT     CfgErrorOutofRange
    
    *Ending smaller than starting address error
    CMP.L D3, D4
    BLT CfgErrorNotBigger
     
    RTS 

* prints an error if the address is odd    
CfgErrorOdd
    LEA MESSAGE1  , A1
    MOVE.B  #14,D0
    TRAP    #15
    SIMHALT

* prints an error if the address is out of range 
CfgErrorOutofRange
    LEA MESSAGE2  , A1
    MOVE.B  #14,D0
    TRAP    #15
    SIMHALT

* prints an address if the ending address is not greater than
* the starting address   
CfgErrorNotBigger
    LEA MESSAGE3  , A1
    MOVE.B  #14,D0
    TRAP    #15
    SIMHALT

*prints an address if the file could not be found
CfgErrorNotFound
    LEA MESSAGE4  , A1
    MOVE.B  #14,D0
    TRAP    #15
    SIMHALT
      
    
    *----------------------------------------------------------------------------------
* Method Name: AsciiToHex
* Written by : Berger, Modified by Nash
* Date       : 3/1/2019
* Description: Converts chars '0'-'9' and 'a'-'f' to 0-9,a-F
*              Transforms/unpacks 8 chars (8b each) pointed to by A1 into 
*              its (4b each) equivalent hex value 
*  
*  Preconditions & Input
*       A1 (input) points to a memory buffer holding 8 ascii chars (not null-terminated) 
*       This function calls another function (strip_ascii)
*
*  Postconditions & Output
*       D7 (output) holds the converted value 
*       Caller-Saved : D0 is temp, D6 is a loop var
*----------------------------------------------------------------------------------
AsciiToHexRegList REG D0,D6
AsciiToHex     
    MOVEM.L asciiToHexRegList, -(SP)  *save context
    CLR.L D7 * clear our return value
    MOVE.L #8, D6 ; and set up our loop counter

chrLoop
    MOVE.B (A1)+,D0 * Get the first byte
    jsr strip_ascii * Get rid of the ascii code    
    OR.W D0,D7 * Load the bits into D7
    
    subI.B #1,D6  *decrement our loop variable
    BEQ chrDone   *skip shifting if we are done
    
    ASL.L #4,D7 * shift left 4 bits to prepare for next byte
    BRA chrLoop

chrDone
    MOVEM.L (SP)+,asciiToHexRegList 
    RTS


**********************************************************************
* SUBROUTINE: strip_ascii
* remove the ascii code from the digits 0-9,a-f, or A-F
* Input Parameters: <D0> = ascii code
*
* Return parameters: D0.B = number 0...F, returned as 00...0F
* Registers used internally: D0
* Assumptions: D0 contains $30-$39, $41-$46 or $61-66
*
***********************************************************************
strip_ascii
      CMP.B #$39,D0 * Is it in range of 0-9?
      BLE sub30 * Its a number
      CMP.B #$46,D0 * Is is A...F?
      BLE sub37 * Its A...F
      SUB.B #$57,D0 * Its a...f
      BRA ret_sa * Go back
sub37 SUB.B #$37,D0 * Strip 37
      BRA ret_sa * Go back
sub30 SUB.B #$30,D0 * Strip 30
ret_sa RTS * Go back


*********************************************************************************
* Method Name: assignStartAddress
* Description: Sets start address to A6, ending address to a location in memory
* Clears all data registers. Loads in our premade buffer into A4 and A5
* Preconditions:  starting address in D3, ending address in D4
* Postconditions: Starting address in A6
*********************************************************************************
assignStartAddress
    MOVE.L  D3,A6
    MOVE.L  D4,endingAddress

    CLR     D0
    CLR     D1
    CLR     D2
    CLR     D4
    CLR     D5
    CLR     D6
    CLR     D7
        
    LEA     DataArray,A0
    MOVE.L  A0, A4
    MOVE.L  A0, A5            
    CLR     D3
    
    BRA     startCode

*********************************************************************************
* Method Name: startCode
* Description: Runs all start methods to set up the dissassembler to start reading
* instructions and print them out. Loads our string buffer into A1
* Preconditions:  A4, A5 pointing at buffer, A6 pointing at memory address
*********************************************************************************   
startCode
    LEA     Buffer,A1
    MOVE.L  A4,D1
    JSR     clear
    
    JSR     convertAddressToString
    
    JSR     checkEndAddress

    JSR     extendData
    
    BRA     getOPCode

*********************************************************************************
* Method Name: askForNextCode
* Description: Runs all start methods to set up the dissassembler to start reading
* instructions and print them out. Loads our string buffer into A1. Also prints out
* whatever is in the string buffer
* Preconditions:  A1 contains a printable string
*********************************************************************************   
askForNextCode
    *******print from data here*****
    JSR     printBuffer
    
    LEA     Buffer,A1
    MOVE.L  A4,D1
    JSR     clear
    
    JSR     convertAddressToString

    JSR     checkEndAddress

    
    JSR     extendData
    
    BRA     getOPCode

*********************************************************************************
* Method Name: convertAddressToString
* Description: Takes each hex value from A6 and converts it into a printable
* character. Adds that character to buffer.
* Preconditions:  A6 pointing at correct address location
*********************************************************************************       
convertAddressToString
    MOVE.L  A6,D0
    LSR.L   #$8,D0
    LSR.L   #$8,D0
    LSR.L   #$8,D0
    LSR.L   #$4,D0
    JSR     doEachHex
    
    MOVE.L  A6,D0
    LSR.L   #$8,D0
    LSR.L   #$8,D0
    LSR.L   #$8,D0
    AND.L   #$0000000F,D0
    JSR     doEachHex
    
    MOVE.L  A6,D0
    LSR.L   #$8,D0
    LSR.L   #$8,D0
    LSR.L   #$4,D0
    AND.L   #$0000000F,D0
    JSR     doEachHex
    
    MOVE.L  A6,D0
    LSR.L   #$8,D0
    LSR.L   #$8,D0
    AND.L   #$0000000F,D0
    JSR     doEachHex
    
    MOVE.L  A6,D0
    LSR.L   #$8,D0
    LSR.L   #$4,D0
    AND.L   #$0000000F,D0
    JSR     doEachHex
    
    MOVE.L  A6,D0
    LSR.L   #$8,D0
    AND.L   #$0000000F,D0
    JSR     doEachHex
    
    MOVE.L  A6,D0
    LSR.L   #$4,D0
    AND.L   #$0000000F,D0
    JSR     doEachHex
    
    MOVE.L  A6,D0
    AND.L   #$0000000F,D0
    JSR     doEachHex
    
    LEA     space,A2
    JSR     addBuffer
    
    RTS

*********************************************************************************
* Method Name: doEachHex
* Description: Compares a byte in D0 to a value and adds the correct hex value
* to our string buffer
* Preconditions:  D0 contains the current hex value
*********************************************************************************       
doEachHex
    CMPI.B  #$00,D0
    BEQ     write0
    
    CMPI.B  #$01,D0
    BEQ     write1
    
    CMPI.B  #$02,D0
    BEQ     write2
    
    CMPI.B  #$03,D0
    BEQ     write3
    
    CMPI.B  #$04,D0
    BEQ     write4
    
    CMPI.B  #$05,D0
    BEQ     write5
    
    CMPI.B  #$06,D0
    BEQ     write6
    
    CMPI.B  #$07,D0
    BEQ     write7
    
    CMPI.B  #$08,D0
    BEQ     write8
    
    CMPI.B  #$09,D0
    BEQ     write9
    
    CMPI.B  #$0A,D0
    BEQ     writeA
    
    CMPI.B  #$0B,D0
    BEQ     writeB
    
    CMPI.B  #$0C,D0
    BEQ     writeC
    
    CMPI.B  #$0D,D0
    BEQ     writeD
    
    CMPI.B  #$0E,D0
    BEQ     writeE
    
    CMPI.B  #$0F,D0
    BEQ     writeF

*********************************************************************************
* Method Name: write0 - writeF
* Description: Adds a letter to our string buffer
*********************************************************************************       
write0
    LEA     Number0,A2
    JSR     addBuffer
    RTS
write1
    LEA     Number1,A2
    JSR     addBuffer
    RTS
write2
    LEA     Number2,A2
    JSR     addBuffer
    RTS
write3
    LEA     Number3,A2
    JSR     addBuffer
    RTS
write4
    LEA     Number4,A2
    JSR     addBuffer
    RTS
write5
    LEA     Number5,A2
    JSR     addBuffer
    RTS
write6
    LEA     Number6,A2
    JSR     addBuffer
    RTS
write7
    LEA     Number7,A2
    JSR     addBuffer
    RTS
write8
    LEA     Number8,A2
    JSR     addBuffer
    RTS
write9
    LEA     Number9,A2
    JSR     addBuffer
    RTS
writeA
    LEA     LetterA,A2
    JSR     addBuffer
    RTS
writeB
    LEA     LetterB,A2
    JSR     addBuffer
    RTS
writeC
    LEA     LetterC,A2
    JSR     addBuffer
    RTS
writeD
    LEA     LetterD,A2
    JSR     addBuffer
    RTS
writeE
    LEA     LetterE,A2
    JSR     addBuffer
    RTS
writeF
    LEA     LetterF,A2
    JSR     addBuffer
    RTS    

*********************************************************************************
* Method Name: extendData
* Description: Reads in 4 hex values from memory and converts them into their
* respective binary equivilant. Checks if we are exceeding ending address
* Postconditions:  A4 now points at next 2 bits. A5 points at end of the bits we converted
*********************************************************************************       
extendData
    MOVE.B  (A6),D6
    LSR.L   #04,D6
    MOVE.B  (A6)+,D7
    AND.L   #$0000000F,D7
    
    JSR     convertToBinary
    ADDQ.L  #2,A5
    MOVE.B  D7,D6
    JSR     convertToBinary
    ADDQ.L  #2,A5
    
    JSR     checkA5Exceed100
    
    RTS

*********************************************************************************
* Method Name: checkA4ExceedA5
* Description: checks if A4 has exceeded A5 in terms of the memory it is pointing
* at. If so, extend the data again
*********************************************************************************       
checkA4ExceedA5
    CMP     A4,A5
    BEQ     extendData
    RTS
 
*********************************************************************************
* Method Name: checkEndAddress
* Description: Checks if we have exceeded the end address. If so, drop everthing and
* exit
*********************************************************************************          
checkEndAddress
    CMP.L   endingAddress,A6
    BGE     stopProgram
    RTS

*********************************************************************************
* Method Name: stopProgram
* Description: stops the program
*********************************************************************************       
stopProgram
    NOP
        SIMHALT

*********************************************************************************
* Method Name: checkA5Exceed100, A4, D1
* Description: Checks if A5, A4, D1 has exceeded our buffer size. If so, reset A5
*********************************************************************************           
checkA5Exceed100
    LEA     DataArray,A0
    ADD.L   #100,A0
    CMP.L   A0,A5
    BEQ     resetA5
    RTS  

checkA4Exceed100
    LEA     DataArray,A0
    ADD.L   #100,A0 
    CMP.L   A0,A4
    BEQ     resetA4
    RTS  

checkD1Exceed100 
    LEA     DataArray,A0
    ADD.L   #100,A0
    CMP.L   A0,D1
    BEQ     resetD1
    RTS

*********************************************************************************
* Method Name: resetA5, A4, D1
* Description: Resets A5, A4, D1 back to our data array
* Preconditions:  A4, A5 pointing at buffer, A6 pointing at memory address
*********************************************************************************   
resetA5
    LEA     DataArray,A0
    MOVE.L  A0, A5
    RTS

resetA4
    LEA     DataArray,A0
    MOVE.L  A0, A4
    RTS
    
resetD1
    LEA     DataArray,A0
    MOVE.L  A0,D1
    RTS

*********************************************************************************
* Method Name: convertToBinary
* Description: Converts a hex value in D6 to binary and stores it
* Preconditions:  D6 contains a hex value
*********************************************************************************       
convertToBinary
    CMPI.B  #%0000,D6
    BEQ     store0000
    CMPI.B  #%0001,D6
    BEQ     store0001
    CMPI.B  #%0010,D6
    BEQ     store0010
    CMPI.B  #%0011,D6
    BEQ     store0011
    CMPI.B  #%0100,D6
    BEQ     store0100
    CMPI.B  #%0101,D6
    BEQ     store0101
    CMPI.B  #%0110,D6
    BEQ     store0110
    CMPI.B  #%0111,D6
    BEQ     store0111
    CMPI.B  #%1000,D6
    BEQ     store1000
    CMPI.B  #%1001,D6
    BEQ     store1001
    CMPI.B  #%1010,D6
    BEQ     store1010
    CMPI.B  #%1011,D6
    BEQ     store1011
    CMPI.B  #%1100,D6
    BEQ     store1100
    CMPI.B  #%1101,D6
    BEQ     store1101
    CMPI.B  #%1110,D6
    BEQ     store1110
    CMPI.B  #%1111,D6
    BEQ     store1111

*********************************************************************************
* Method Name: start0000 - 1111
* Description: Stores a word in the address of A5.
*********************************************************************************       
store0000
    MOVE.W  #$0000,(A5)
    RTS
store0001
    MOVE.W  #$0001,(A5)
    RTS
store0010
    MOVE.W  #$0010,(A5)
    RTS
store0011
    MOVE.W  #$0011,(A5)
    RTS
store0100
    MOVE.W  #$0100,(A5)
    RTS
store0101
    MOVE.W  #$0101,(A5)
    RTS
store0110
    MOVE.W  #$0110,(A5)
    RTS
store0111
    MOVE.W  #$0111,(A5)
    RTS
store1000
    MOVE.W  #$1000,(A5)
    RTS
store1001
    MOVE.W  #$1001,(A5)
    RTS
store1010
    MOVE.W  #$1010,(A5)
    RTS
store1011
    MOVE.W  #$1011,(A5)
    RTS
store1100
    MOVE.W  #$1100,(A5)
    RTS
store1101
    MOVE.W  #$1101,(A5)
    RTS
store1110
    MOVE.W  #$1110,(A5)
    RTS
store1111
    MOVE.W  #$1111,(A5)
    RTS

*********************************************************************************
* Method Name: clear
* Description: Clears all the data registers and A3. Resets A5, A4, D1 back to
* the data buffer.
*********************************************************************************      
clear
    MOVE.L  #$00000000,D0
    MOVE.L  #$00000000,D1
    MOVE.L  #$00000000,D2
    MOVE.L  #$00000000,D3
    MOVE.L  #$00000000,D4
    MOVE.L  #$00000000,D5
    MOVE.L  #$00000000,D6
    MOVE.L  #$00000000,D7
    MOVE.L  #$00000000,A3
    
    JSR     resetA5
    JSR     resetA4
    JSR     resetD1
    RTS

*********************************************************************************
* Method Name: getOPCode
* Description: Stores the next 2 bits into D2 and runs a method based on their
* value. Runs OPdata if there is no match.
*********************************************************************************       
getOPCode
    JSR     getNext2Bytes

    CMPI.B  #$00,D2
    BEQ     get12bit00
    
    CMPI.B  #$01,D2
    BEQ     get12bit01
    
    CMPI.B  #$10,D2
    BEQ     get12bit10
    
    CMPI.B  #$11,D2
    BEQ     get12bit11
    
    BRA     OPdata

*********************************************************************************
* Method Name: getNext2Bytes
* Description: Makes sure A4 is still pointing to valid data. Grabs the 2 hex values
* in memory and stores them into D2.
* PostCondition: D2 now contains 2 hex values (0 or 1 though)
*********************************************************************************       
getNext2Bytes
    JSR     checkA4ExceedA5
    JSR     checkA4Exceed100
    
    CLR     D2
    MOVE.B  (A4)+,D2
    
    RTS

*********************************************************************************
* Method Name: getNext2BytesPostCheck
* Description: Grabs the next two hex values and stores them into D2. Same as
* getNext2Bytes except the checks for exceeding data are done after data is grabbed
*********************************************************************************       
getNext2BytesPostCheck 
    CLR     D2
    MOVE.B  (A4)+,D2
    
    JSR     checkA4ExceedA5
    JSR     checkA4Exceed100
    
    RTS

*********************************************************************************
* Method Name: getData2Bytes
* Description: Grabs 2 hex values from the current address in D1 and stores it
* in D2.
*********************************************************************************       
getData2Bytes
    CLR     D2
    MOVE.L  D1,A0
    MOVE.B  (A0)+,D2
    MOVE.L  A0,D1
    
    JSR     checkD1Exceed100
    
    RTS

*********************************************************************************
* Method Name: getNextWord
* Description: Clears D5 and D6 and stores the next word of data and stores it
* in D5
* PostCondition: D5 now contains a word of data in hex
*********************************************************************************       
getNextWord
    CLR.L   D5
    MOVE.L  #$00000000,D5
    CLR.L   D6
    MOVE.L  #$00000000,D6

    MOVE.B  (A6)+,D5
    LSL.L   #08,D5
    JSR     checkEndAddress
    
    MOVE.B  (A6)+,D6
    ADD     D6,D5
    
    RTS
    
*********************************************************************************
* Method Name: getNextLong
* Description: Clears D5 and D6 and stores the next long of data and stores it
* in D5.
* PostCondition: D5 now contains a long of data in hex
*********************************************************************************   
getNextLong
    CLR.L   D5
    MOVE.L  #$00000000,D5
    CLR.L   D6
    MOVE.L  #$00000000,D6
    
    MOVE.B  (A6)+,D5
    LSL.L   #08,D5
    JSR     checkEndAddress
    
    MOVE.B  (A6)+,D6
    ADD     D6,D5
    LSL.L   #08,D5
    JSR     checkEndAddress
    
    MOVE.B  (A6)+,D6
    ADD     D6,D5
    LSL.L   #08,D5
    JSR     checkEndAddress
    
    MOVE.B  (A6)+,D6
    ADD     D6,D5
    
    RTS

*********************************************************************************
* Method Name: OPdata
* Description: Writes DATA to the string buffer and prints the hex word (or more)
* that the disassembler does not understand.
*********************************************************************************     
OPdata
    LEA     Buffer,A1
    MOVE.L  A1,D0
    ADDI    #8,D0
    MOVE.L  D0,A1
    
    LEA     space,A2
    JSR     addBuffer

    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterT,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     Space,A2
    JSR     addBuffer
    LEA     DollarSign,A2
    JSR     addBuffer

    MOVE.L  A4,D3
    AND.L   #$0000000F,D3
    JSR     checkHexPart
    MOVE.L  #$00000000,D5
    
    JSR     printDataHex

*********************************************************************************
* Method Name: checkData2Hex
* Description: If the D5 counter is greater or equal to 2, run the next method
*********************************************************************************   
checkData2Hex
    CMPI.B  #2,D5
    BGE     checkLessThan4Hex
    
    RTS

*********************************************************************************
* Method Name: checkLessThan4Hex
* Description: If there are less than 4 hex values currently stores for printing,
* grabs the next hex value. If we have reached the end of the address we did
* not understand, stop getting hex values.
*********************************************************************************   
checkLessThan4Hex
    CMPI.B  #4,D5
    BLT     getNextHex
    CMP.L   A4,D1
    BGE     breakDataLoop
    RTS
    
*********************************************************************************
* Method Name: breakDataLoop
* Description: Writes AA to D5
* PostCondition: D5 now holds AA
*********************************************************************************   
breakDataLoop
    MOVE.L  #$000000AA,D5
    RTS
    
*********************************************************************************
* Method Name: getNextHex
* Description: Moves the address A4 is pointing at forward by 2. (To get a word)
*********************************************************************************   
getNextHex
    JSR     getNext2BytesPostCheck
    JSR     getNext2BytesPostCheck
    RTS    
    
*********************************************************************************
* Method Name: printDataHex
* Description: Grabs 4 bits from where D1 is pointing to and stores it in D3.
* Writes the hex value in D3 to our buffer. If AA is in D5, leave the method.
*********************************************************************************   
printDataHex
    JSR     checkData2Hex
    
    CMPI.B  #$AA,D5
    BEQ     askForNextCode
    
    ADDI    #1,D5
    
    JSR     getData2Bytes
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getData2Bytes
    ADD     D2,D3
    
    CMPI.W  #$0000,D3
    BEQ     storeHex0
    
    CMPI.W  #$0001,D3
    BEQ     storeHex1
    
    CMPI.W  #$0010,D3
    BEQ     storeHex2
    
    CMPI.W  #$0011,D3
    BEQ     storeHex3
    
    CMPI.W  #$0100,D3
    BEQ     storeHex4
    
    CMPI.W  #$0101,D3
    BEQ     storeHex5
    
    CMPI.W  #$0110,D3
    BEQ     storeHex6
    
    CMPI.W  #$0111,D3
    BEQ     storeHex7
    
    CMPI.W  #$1000,D3
    BEQ     storeHex8
    
    CMPI.W  #$1001,D3
    BEQ     storeHex9
    
    CMPI.W  #$1010,D3
    BEQ     storeHexA
    
    CMPI.W  #$1011,D3
    BEQ     storeHexB
    
    CMPI.W  #$1100,D3
    BEQ     storeHexC
    
    CMPI.W  #$1101,D3
    BEQ     storeHexD
    
    CMPI.W  #$1110,D3
    BEQ     storeHexE
    
    CMPI.W  #$1111,D3
    BEQ     storeHexF

*********************************************************************************
* Method Name: storeHex0 - F
* Description: Stores a hex value in A2 and writes it to our string buffer. Runs
* printDataHex afterward.
*********************************************************************************       
storeHex0
    LEA     Number0,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex1
    LEA     Number1,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex2
    LEA     Number2,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex3
    LEA     Number3,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex4
    LEA     Number4,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex5
    LEA     Number5,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex6
    LEA     Number6,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex7
    LEA     Number7,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex8
    LEA     Number8,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHex9
    LEA     Number9,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHexA
    LEA     LetterA,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHexB
    LEA     LetterB,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHexC
    LEA     LetterC,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHexD
    LEA     LetterD,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHexE
    LEA     LetterE,A2 
    JSR     addBuffer
    BRA     printDataHex
storeHexF
    LEA     LetterF,A2 
    JSR     addBuffer
    BRA     printDataHex   

*********************************************************************************
* Method Name: addBuffer
* Description: Moves whatever A2 is pointing at into where A1 is and increases
* where A1 is pointing by 1
*********************************************************************************    
addBuffer
    MOVE.B  (A2),(A1)+
    RTS

*********************************************************************************
* Method Name: printBuffer
* Description: Adds a null character to A1 and then runs TrapTask13 on the string
* to print it out and to file
*********************************************************************************       
printBuffer
    ***print buffer*****
    LEA     null,A2
    JSR     addBuffer
    
    LEA     Buffer,A1
    
    JSR     TrapTask13
    RTS

*********************************************************************************
* Method Name: checkHexPart
* Description: Checks to see if we have grabbed the first 2 bits or 4. If we have
* only grabbed 4 bits, we need to get the next 2 for a complete hex value.
*********************************************************************************       
checkHexPart
    
    CMPI.B  #$01,D3
    BEQ     get2ndPartofHex
    
    *****************check if we need to grab the next 2 bits (because hex is 4 bits, so if we have only gotten 2
    *****************and determined its bad data, get the next 2 too
    CMPI.B  #$03,D3
    BEQ     get2ndPartofHex
    
    CMPI.B  #$05,D3
    BEQ     get2ndPartofHex
    
    CMPI.B  #$07,D3
    BEQ     get2ndPartofHex
    
    CMPI.B  #$09,D3
    BEQ     get2ndPartofHex
    
    CMPI.B  #$0B,D3
    BEQ     get2ndPartofHex
    
    CMPI.B  #$0D,D3
    BEQ     get2ndPartofHex
    
    CMPI.B  #$0F,D3
    BEQ     get2ndPartofHex
    
    RTS

*********************************************************************************
* Method Name: get2ndPartofHex
* Description: Gets the next 2 bits to complete hex value.
*********************************************************************************       
get2ndPartofHex
    JSR     getNext2Bytes
    RTS    

*********************************************************************************
* Method Name: get12bit00
* Description: checks the current 2 bits and runs a method based on their value
*********************************************************************************   
get12bit00
    JSR     getNext2Bytes
    MOVE.L  A4,A3   ***we have to check further for movea and move codes, so we save position before EA here*****
    
    CMPI.B  #$00,D2
    BEQ     get34bit00
    
    CMPI.B  #$01,D2
    BEQ     OPmoveb
    
    CMPI.B  #$10,D2
    BEQ     get34bit10
    
    CMPI.B  #$11,D2
    BEQ     get34bit11

*********************************************************************************
* Method Name: get34bit00
* Description: checks the current 2 bits and runs a method based on their value
* also checks for BCLR by looking ahead
*********************************************************************************      
get34bit00
    MOVE.L  A4,A2
    
    JSR     getNext2Bytes
    
    *********test for bclr******
    MOVE.L  D2,D4
    LSL.L   #$08,D4
    
    JSR     getNext2Bytes
    ADD.L   D2,D4
    LSR.L   #4,D4
    
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD.B   D2,D3
    AND.L   #$00000111,D3
    CMPI.W  #$0110,D3
    BEQ     OPbclrdynamic
    
    MOVE.L  A2,A4
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     get56bit00
    
    CMPI.B  #$10,D2
    BEQ     get56bit10
    
    CMPI.B  #$11,D2
    BEQ     get56bit11
    
    BRA     OPdata

*********************************************************************************
* Method Name: get34bit10
* Description: checks the current 2 bits and runs a method based on their value
* Runs movel if next 2 bits don't match any possible instruction
*********************************************************************************      
get34bit10
    JSR     getNext2Bytes
    
    JSR     getNext2Bytes
    
    MOVE.L  #$00000010,D3
    OR      D3,D2
    
    CMPI    #$10,D2
    BEQ     get78bitx0
    BRA     OPmovel
    
*********************************************************************************
* Method Name: get34bit11
* Description: checks the current 2 bits and runs a method based on their value
* Runs movew if next 2 bits don't match any possible instruction
*********************************************************************************      
get34bit11
    JSR     getNext2Bytes
    
    JSR     getNext2Bytes
    
    MOVE.L  #$00000010,D3
    OR      D3,D2
    
    CMPI    #$10,D2
    BEQ     get78bitx0part2
    BRA     OPmovew

*********************************************************************************
* Method Name: get56bit100
* Description: checks the current 2 bits and runs a method based on their value
*********************************************************************************      
get56bit00
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPori
    
    BRA     OPdata

*********************************************************************************
* Method Name: get56bit10
* Description: checks the current 2 bits and runs a method based on their value
*********************************************************************************      
get56bit10
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     get78bit00
    
    BRA     OPdata

*********************************************************************************
* Method Name: get56bit11
* Description: checks the current 2 bits and runs a method based on their value
*********************************************************************************      
get56bit11
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPcmpi
    
    BRA     OPdata

*********************************************************************************
* Method Name: get78bit00
* Description: checks the current 2 bits and runs a method based on their value
*********************************************************************************      
get78bit00
    JSR     getNext2Bytes
    
    CMPI.B  #$10,D2
    BEQ     OPbclrstatic
    
    BRA     OPdata

*********************************************************************************
* Method Name: get78bitx0
* Description: checks the current 2 bits and runs a method based on their value
*********************************************************************************      
get78bitx0
    JSR     getNext2Bytes
    
    CMPI.B  #$01,D2
    BEQ     OPmoveal
    BRA     OPmovel

*********************************************************************************
* Method Name: get78bitx0part
* Description: checks the current 2 bits and runs a method based on their value
*********************************************************************************      
get78bitx0part2
    JSR     getNext2Bytes
    
    CMPI.B  #$01,D2
    BEQ     OPmoveaw
    BRA     OPmovew

*********************************************************************************
* Method Name: OPbclrdynamic
* Description: OP code is bclrdynamic, runs the respective EA method
*********************************************************************************  
OPbclrdynamic
    MOVE.L  A4,D0
    
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    LSL.B   #04,D3
    
    MOVE.L  D4,D6   **getting first register here
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    JSR     checkPrintL
    LEA     space,A2
    JSR     addBuffer
    
    MOVE.L  D0,A4
    JSR     getNext2Bytes
    
    JSR     compareEAModeBCLRDynamic
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPbclrstatic
* Description: OP code is bclrstatic, runs the respective EA method
*********************************************************************************      
OPbclrstatic
    MOVE.L  A4,D0
    
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    LSL.B   #04,D3
    
    MOVE.L  D4,D6   **getting first register here
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    JSR     checkPrintL
    LEA     space,A2
    JSR     addBuffer
    
    MOVE.L  D0,A4
    JSR     getNext2Bytes
    
    JSR     compareEAModeBCLRStatic
    
    BRA     askForNextCode

*Check whether to print .L or .B for BCLR    
checkPrintL
    CMPI    #$00000000,D3
    BEQ     printL
    BRA     printB
printL
    LEA     LetterL,A2
    JSR     addBuffer
    RTS
printB
    LEA     LetterB,A2
    JSR     addBuffer
    RTS

*********************************************************************************
* Method Name: OPcmpi, b,w,l
* Description: OP code is cmpi so run respective method based on size and 
* runs the respective EA method
*********************************************************************************  
OPcmpi
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPcmpib
    
    CMPI.W  #$01,D2
    BEQ     OPcmpiw
    
    CMPI.L  #$10,D2
    BEQ     OPcmpil
OPcmpib
    MOVE.L  #$00000001,D0
    JSR     getNext2Bytes
    
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterP,A2
    JSR     addBuffer
    LEA     LetterI,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer

    MOVE.L  #$00000000,D0
    JSR     compareEAModeORI

    BRA     askForNextCode
OPcmpiw
    MOVE.L  #$00000001,D0
    JSR     getNext2Bytes
    
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterP,A2
    JSR     addBuffer
    LEA     LetterI,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer

    MOVE.L  #$00000000,D0
    JSR     compareEAModeORI

    BRA     askForNextCode
OPcmpil
    MOVE.L  #$00000001,D0
    JSR     getNext2Bytes
    
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterP,A2
    JSR     addBuffer
    LEA     LetterI,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer

    MOVE.L  #$00000001,D0
    JSR     compareEAModeORI

    BRA     askForNextCode 

*********************************************************************************
* Method Name: OPori, b,2,l
* Description: OP code is OPori, runs the respective EA method based on size
*********************************************************************************  
OPori
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPorib
    
    CMPI.W  #$01,D2
    BEQ     OPoriw
    
    CMPI.L  #$10,D2
    BEQ     OPoril
    
OPorib
    MOVE.L  #$00000001,D0
    JSR     getNext2Bytes
    
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterI,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer

    MOVE.L  #$00000000,D0
    JSR     compareEAModeORI

    BRA     askForNextCode
OPoriw
    MOVE.L  #$00000011,D0
    JSR     getNext2Bytes
    
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterI,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    MOVE.L  #$00000000,D0
    JSR     compareEAModeORI

    BRA     askForNextCode
OPoril
    MOVE.L  #$00000010,D0
    JSR     getNext2Bytes
    
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterI,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    MOVE.L  #$00000001,D0
    JSR     compareEAModeORI

    BRA     askForNextCode   

*********************************************************************************
* Method Name: OPmoveb,w,l OPmoveaw, l
* Description: OP code is move or movea, runs the respective EA method and size
*********************************************************************************  
OPmoveb
    MOVE.L  A3,A4
    **MOVE.L  D2,D5 ***for size later on
    JSR     getNext2Bytes

    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    MOVE.L  #$00000001,D0
    JSR     compareEAModeMOVE    

    BRA     askForNextCode
    
OPmoveal
    MOVE.L  A3,A4   *******putting the pointer back to the start of EA************
    JSR     getNext2Bytes

    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000010,D0
    JSR     compareEAModeMOVEA
    
    BRA     askForNextCode
    
OPmoveaw
    MOVE.L  A3,A4   *******putting the pointer back to the start of EA************
    JSR     getNext2Bytes
    
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000011,D0
    JSR     compareEAModeMOVEA
    
    BRA     askForNextCode
    
OPmovel
    MOVE.L  A3,A4
    JSR     getNext2Bytes

    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000010,D0
    JSR     compareEAModeMOVE  
    
    BRA     askForNextCode
    
OPmovew
    MOVE.L  A3,A4
    JSR     getNext2Bytes

    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000011,D0
    JSR     compareEAModeMOVE  
    
    BRA     askForNextCode


*********************************************************************************
* Method Name: get12bit01
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************  
get12bit01
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     get34bit00v2
    
    CMPI.B  #$01,D2
    BEQ     get34bit01v2
    
    CMPI.B  #$10,D2
    BEQ     get34bit10v2
    
    BRA     OPdata

*********************************************************************************
* Method Name: get34bit00v2
* Description: Grabs the next 2 bits and compares them to expected values
* also checks for bclr and LEA
*********************************************************************************     
get34bit00v2
    
    JSR     getNext2Bytes
    MOVE.L  D2,D5
    MOVE.L  A4,A2
    *********test for bclr******
    MOVE.L  D2,D4
    LSL.L   #$08,D4
    
    JSR     getNext2Bytes
    ADD.L   D2,D4
    LSR.L   #4,D4
    
    MOVE.L  A2,A4   LEA check
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.W   #$08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    AND.L   #$00000111,D3
    CMPI.W  #$0111,D3
    BEQ     OPlea
    
    MOVE.L  A2,A4
    MOVE.B  D5,D4   ******saving whether movem is reg to mem or mem to reg********
    MOVE.L  D5,D0
    
    CMPI.B  #$01,D5
    BEQ     get56bit01v2
    
    CMPI.B  #$11,D5
    BEQ     get56bit11v2
    
    BRA     get56bit1xv2

*********************************************************************************
* Method Name: get34bit01v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get34bit01v2
    MOVE.L  A4,A2
    
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    
    AND.L   #$00000001,D2
    CMPI.B  #$01,D2
    BEQ     OPsubq
    
    BRA     OPdata
    
*********************************************************************************
* Method Name: get34bit10v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get34bit10v2
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     get56bit00v2part2
    
    BRA     OPbcc
*********************************************************************************
* Method Name: get56bit00v2part2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get56bit00v2part2
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPbra
    
    BRA     OPdata
*********************************************************************************
* Method Name: get56bit01v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************  
get56bit01v2
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPneg

    BRA     OPdata   
*********************************************************************************
* Method Name: get56bit11v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get56bit11v2
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     get78bit00v2
    
    CMPI.B  #$10,D2
    BEQ     get78bit10v2
    
    BRA     OPdata
*********************************************************************************
* Method Name: get56bit1xv2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get56bit1xv2
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     get78bit00v2part2
    
    BRA     OPdata
*********************************************************************************
* Method Name: get78bit00v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get78bit00v2
    JSR     getNext2Bytes
    
    CMPI.B  #$10,D2
    BEQ     OPmovemw
    
    CMPI.B  #$11,D2
    BEQ     OPmoveml

    BRA     OPdata
*********************************************************************************
* Method Name: get78bit00v2part2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get78bit00v2part2
    JSR     getNext2Bytes
    
    CMPI.B  #$10,D2
    BEQ     OPmovemw
    
    CMPI.B  #$11,D2
    BEQ     OPmoveml
    
    BRA     OPdata
*********************************************************************************
* Method Name: get78bit10v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get78bit10v2
    JSR     getNext2Bytes
    
    CMPI.B  #$01,D2
    BEQ     get910bit01v2

    CMPI.B  #$10,D2
    BEQ     OPjsr
    
    BRA     OPdata
*********************************************************************************
* Method Name: get910bit01v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get910bit01v2
    JSR     getNext2Bytes
    CMPI.B  #$11,D2
    BEQ     get1112bit11v2
    
    BRA     OPdata
*********************************************************************************
* Method Name: get1112bit11v2
* Description: Grabs the next 2 bits and compares them to expected values
*********************************************************************************     
get1112bit11v2
    JSR     getNext2Bytes
    CMPI.B  #$00,D2
    BEQ     OPnop
    
    CMPI.B  #$01,D2
    BEQ     OPrts
    
    BRA     OPdata
*********************************************************************************
* Method Name: OPbra
* Description: OPcode is bra, runs respective EA method
*********************************************************************************     
OPbra
    JSR     getNext2Bytes
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareLabelBcc
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPsubq
* Description: OPcode is subq, runs respective EA method and size
*********************************************************************************   
OPsubq
    MOVE.L  A2,A4
    JSR     getNext2Bytes
    
    MOVE.L  D2,D3
    LSL.W   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    LSR.W   #04,D3
    
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPsubqb
    
    CMPI.B  #$01,D2
    BEQ     OPsubqw
    
    CMPI.B  #$10,D2
    BEQ     OPsubql

    BRA     OPdata
OPsubqb
    JSR     getNext2Bytes
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterQ,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000001,D0
    JSR     compareEAModeSUBQ
    
    BRA     askForNextCode
OPsubqw
    JSR     getNext2Bytes
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterQ,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000011,D0
    JSR     compareEAModeSUBQ
    
    BRA     askForNextCode
OPsubql
    JSR     getNext2Bytes
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterQ,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000010,D0
    JSR     compareEAModeSUBQ
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPneg
* Description: OPcode is neg, runs respective EA method and size
*********************************************************************************   
OPneg
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     OPnegb
    
    CMPI.B  #$01,D2
    BEQ     OPnegw
    
    CMPI.B  #$10,D2
    BEQ     OPnegl
    
    BRA     OPdata
OPnegb
    JSR     getNext2Bytes
    
    LEA     LetterN,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterG,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeNEG
    
    BRA     askForNextCode
OPnegw
    JSR     getNext2Bytes
    
    LEA     LetterN,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterG,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeNEG
    
    BRA     askForNextCode
OPnegl
    JSR     getNext2Bytes
    
    LEA     LetterN,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterG,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeNEG
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPmovem
* Description: OPcode is movem, runs respective EA method and size. Runs a different
* method based on whether it is from register to memory or memory to register
*********************************************************************************   
OPmovemw
    CMPI.B  #$10,D0
    BEQ     OPmovemwregtomem
    
    CMPI.B  #$11,D0
    BEQ     OPmovemwmemtoreg
OPmoveml
    CMPI.B  #$10,D0
    BEQ     OPmovemlregtomem
    
    CMPI.B  #$11,D0
    BEQ     OPmovemlmemtoreg
 
OPmovemwregtomem
    JSR     getNext2Bytes

    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer

    JSR     compareEAModeMOVEMreg
    
    BRA     askForNextCode
    
OPmovemlregtomem
    JSR     getNext2Bytes
    
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeMOVEMreg
    
    BRA     askForNextCode
  
OPmovemwmemtoreg
    JSR     getNext2Bytes
    
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeMOVEMmem
    
    BRA     askForNextCode
    
OPmovemlmemtoreg
    JSR     getNext2Bytes
    
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeMOVEMmem
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPjsr
* Description: OPcode is jsr, runs respective EA method and size
*********************************************************************************       
OPjsr
    JSR     getNext2Bytes
    LEA     LetterJ,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeJSR
    BRA     askForNextCode
*********************************************************************************
* Method Name: OPnop
* Description: OPcode is nop, runs respective EA method and size
*********************************************************************************       
OPnop
    LEA     LetterN,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterP,A2
    JSR     addBuffer
    BRA     askForNextCode
*********************************************************************************
* Method Name: OPrts
* Description: OPcode is rts, runs respective EA method and size
*********************************************************************************       
OPrts
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterT,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    BRA     askForNextCode
*********************************************************************************
* Method Name: OPlea
* Description: OPcode is lea, runs respective EA method and size
*********************************************************************************       
OPlea
    MOVE.L  A2,A4   *****restoring original LEA EA******
    MOVE.L  A4,D0
    SUBI    #2,D0
    MOVE.L  D0,A4
    JSR     getNext2Bytes
    
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeLea
    
    BRA     askForNextCode
*********************************************************************************
* Method Name: OPbcc and others
* Description: OPcode is bcc, runs respective EA method and size
*********************************************************************************       
OPbcc
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD     D2,D3
    
    CMPI.W  #$0100,D3
    BEQ     OPbccprint
    
    CMPI.W  #$0101,D3
    BEQ     OPbcs
    
    CMPI.W  #$1100,D3
    BEQ     OPbge
    
    CMPI.W  #$1101,D3
    BEQ     OPblt
    
    CMPI.W  #$1000,D3
    BEQ     OPbvc
    
    BRA     OPdata
    
OPbccprint
    JSR     getNext2Bytes
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareLabelBcc
    
    BRA     askForNextCode
    
OPbcs
    JSR     getNext2Bytes
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareLabelBcc
    
    BRA     askForNextCode
    
OPbge
    JSR     getNext2Bytes
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterG,A2
    JSR     addBuffer
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareLabelBcc
    
    BRA     askForNextCode
    
OPblt
    JSR     getNext2Bytes
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterT,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareLabelBcc
    
    BRA     askForNextCode
    
OPbvc
    JSR     getNext2Bytes
    
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareLabelBcc
    
    BRA     askForNextCode
    
*********************************************************************************
* Method Name: get12bit10
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to
*********************************************************************************   
get12bit10
    JSR     getNext2Bytes
    
    CMPI.B  #$00,D2
    BEQ     get34bit00v3 

    CMPI.B  #$01,D2
    BEQ     OPsub

    CMPI.B  #$11,D2
    BEQ     get34bit11v3  
    
    BRA     OPdata

*********************************************************************************
* Method Name: get34bit00v3
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to. Also checks for OR
*********************************************************************************      
get34bit00v3
    MOVE.L  A4,A3   ******saving location of register for DIVUW and OR*********

    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    AND.L     #$00000111,D3
    
    CMPI.W  #$0111,D3
    BEQ     OPdivsw
    
    **************saving opmode for OR**************
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    
    MOVE.L  D2,D3
    AND.L     #$00000001,D3
    LSL.L   #$04,D3
    
    JSR     getNext2Bytes
    
    ADD     D2,D3
    
    BRA     OPor 

*********************************************************************************
* Method Name: get34bit11v3
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to and checks for EOR and CMP
*********************************************************************************      
get34bit11v3
    MOVE.L  A4,A3   **saving EOR register location
    
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD     D2,D3
    AND.L   #$00000111,D3
    
    MOVE.L  A3,A4
    
    CMPI.W  #$0100,D3
    BEQ     OPeorb
    
    CMPI.W  #$0101,D3
    BEQ     OPeorw
    
    CMPI.W  #$0110,D3
    BEQ     OPeorl
    
    CMPI.W  #$0000,D3
    BEQ     OPcmpb
    
    CMPI.W  #$0001,D3
    BEQ     OPcmpw
    
    CMPI.W  #$0010,D3
    BEQ     OPcmpl
    
    BRA     OPdata
    
OPeorb
    JSR     getNext2Bytes
    MOVE.L  D2,D5
    LSL.L   #08,D5
    JSR     getNext2Bytes
    ADD.L   D2,D5
    LSR.L   #04,D5
    MOVE.L  D5,D6
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeEOR
    
    BRA     askForNextCode
OPeorw
    JSR     getNext2Bytes
    MOVE.L  D2,D5
    LSL.L   #08,D5
    JSR     getNext2Bytes
    ADD.L   D2,D5
    LSR.L   #04,D5
    MOVE.L  D5,D6
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeEOR
    
    BRA     askForNextCode
OPeorl
    JSR     getNext2Bytes
    MOVE.L  D2,D5
    LSL.L   #08,D5
    JSR     getNext2Bytes
    ADD.L   D2,D5
    LSR.L   #04,D5
    MOVE.L  D5,D6
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    LEA     LetterE,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeEOR
    
    BRA     askForNextCode 

*********************************************************************************
* Method Name: OPor
* Description: OP code is OR so run respective EA method based on size. Or ea code
* is the same as ADD, so we just use the same method
*********************************************************************************      
OPor
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    AND.L   #$00000001,D2
    CMPI.L  #$00000001,D2
    BEQ     OPdata

    MOVE.L  A3,A4   loading back the start of EA for OR
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.W   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    AND     #$00000111,D3
    
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    
    CMPI.W  #$0000,D3
    BEQ     OPorb
     
    CMPI.W  #$0100,D3
    BEQ     OPorbv2
    
    CMPI.W  #$0001,D3
    BEQ     OPorw
    
    CMPI.W  #$0101,D3
    BEQ     OPorwv2
    
    CMPI.W  #$0010,D3
    BEQ     OPorl
    
    CMPI.W  #$0110,D3
    BEQ     OPorlv2
    
    BRA     OPdata
OPorb
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPorbv2
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode
OPorw
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPorwv2
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode
OPorl
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPorlv2
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPdivsw
* Description: OPcode is divsw so run respective method based on EA
*********************************************************************************  
OPdivsw    
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterI,A2
    JSR     addBuffer
    LEA     LetterV,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
     MOVE.L  #$00000011,D0
    JSR     compareEAModeDIVS
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPsub
* Description: OPcode is sub so run respective EA method based on size. Same EA
* types as add so we use the add method.
*********************************************************************************      
OPsub
    MOVE.L  A4,A3
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.W   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    AND     #$00000111,D3
    
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    
    CMPI.W  #$0000,D3
    BEQ     OPsubb
     
    CMPI.W  #$0100,D3
    BEQ     OPsubbv2
    
    CMPI.W  #$0001,D3
    BEQ     OPsubw
    
    CMPI.W  #$0101,D3
    BEQ     OPsubwv2
    
    CMPI.W  #$0010,D3
    BEQ     OPsubl
    
    CMPI.W  #$0110,D3
    BEQ     OPsublv2
    
    BRA     OPdata
OPsubb
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPsubbv2
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode
OPsubw
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPsubwv2
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode
OPsubl
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPsublv2
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPcmpb
* Description: OPcode is cmp so run respective EA method based on size
*********************************************************************************      
OPcmpb
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    LSR.L   #04,D3
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterP,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    MOVE.L  #$00000001,D0
    JSR     compareEAModeCMP
  
    BRA     askForNextCode
    
OPcmpw
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    LSR.L   #04,D3
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterP,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000011,D0
    JSR     compareEAModeCMP
    
    BRA     askForNextCode
    
OPcmpl
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    LSR.L   #04,D3
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    
    LEA     LetterC,A2
    JSR     addBuffer
    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterP,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000010,D0
    JSR     compareEAModeCMP
    
    BRA     askForNextCode
    
*********************************************************************************
* Method Name: get12bit11
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to
*********************************************************************************  
get12bit11
    JSR     getNext2Bytes
    MOVE.L  A4,A3   ************saving EA location for certain op codes************
    
    CMPI.B  #$00,D2
    BEQ     get34bit00v4
    
    CMPI.B  #$01,D2
    BEQ     get34bit01v4
    
    CMPI.B  #$10,D2
    BEQ     get34bit10v4
    
    BRA     OPdata
*********************************************************************************
* Method Name: get34bit00v4
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to
*********************************************************************************      
get34bit00v4
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.L   #$08,D3
    JSR     getNext2Bytes
    ADD     D2,D3
    AND.L     #$00000111,D3
    CMPI.W  #$0111,D3
    BEQ     OPmuls
    
    BRA     OPdata

*********************************************************************************
* Method Name: get34bit01v4
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to also checks for addA
*********************************************************************************      
get34bit01v4
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    
    *********storing OP code for addA*********
    MOVE.L  D2,D3
    AND.L   #$00000001,D3
    LSL.L   #08,D3
    *****************************************
    
    OR      #$00000010,D2
    CMPI.B  #$10,D2
    BEQ     get78bitxxv4part2
    
    CMPI.B  #$11,D2
    BEQ     get78bitxxv4part2
    
    BRA     OPdata

*********************************************************************************
* Method Name: get34bit10v4
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to. Checks for any of the shifts (lsl, lsr, etc)
*********************************************************************************      
get34bit10v4
    ****saving location of count/reg****
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    
    
    MOVE.L  D2,D3
    LSL.L   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    LSL.L   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    
    CMPI.L  #$00000011,D3
    BEQ     OPasrmem
    CMPI.L  #$00000111,D3
    BEQ     OPaslmem
    CMPI.L  #$00001011,D3
    BEQ     OPlsrmem
    CMPI.L  #$00001111,D3
    BEQ     OPlslmem
    CMPI.L  #$00011011,D3
    BEQ     OPrormem
    CMPI.L  #$00011111,D3
    BEQ     OProlmem
    
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    JSR     getNext2Bytes

    AND.L    #$00000001,D2
    CMPI.B  #$00,D2
    BEQ     checkShiftRight
    CMPI.B  #$01,D2
    BEQ     checkShiftLeft
    
    BRA     OPdata
*********************************************************************************
* Method Name: checkShiftRight/Left
* Description: runs the EA method based on the method and direction. Load the count
* or register into D3, load the size into D4 and load i/r into D5. 
*********************************************************************************      
checkShiftRight
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D0
    LSL.W   #08,D0
    JSR     getNext2Bytes
    ADD.L   D2,D0
    MOVE.L  A3,A4

    
    *D3 == count? register + dr
    *D4 == size
    *D5 == i/r + 0
    
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.W   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    
    JSR     getNext2Bytes
    MOVE.L  D2,D4
    
    JSR     getNext2Bytes
    MOVE.L  D2,D5
    AND     #$00000010,D5
    
    LSR.W   #04,D0
    CMPI.B  #$00,D0
    BEQ     OPasrreg
    CMPI.B  #$01,D0
    BEQ     OPlsrreg
    CMPI.B  #$10,D0
    BEQ     OProrreg
    CMPI.B  #$11,D0
    BEQ     OProrreg

checkShiftLeft
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D0
    LSL.W   #08,D0
    JSR     getNext2Bytes
    ADD.L   D2,D0
    
    MOVE.L  A3,A4
    
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.W   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    
    JSR     getNext2Bytes
    MOVE.L  D2,D4
    
    JSR     getNext2Bytes
    MOVE.L  D2,D5
    AND     #$00000010,D5
    
    LSR.W   #04,D0
    CMPI.B  #$00,D0
    BEQ     OPaslreg
    CMPI.B  #$01,D0
    BEQ     OPlslreg
    CMPI.B  #$10,D0
    BEQ     OProlreg
    CMPI.B  #$11,D0
    BEQ     OProlreg

*********************************************************************************
* Method Name: get78bitxxv4part2
* Description: grabs the next 2 bits and runs a method based on what they
* are equal to
*********************************************************************************      
get78bitxxv4part2
    JSR     getNext2Bytes
    
    ********Adding final op code piece (for ADDA and ADD)***********
    ADD     D2,D3
    
    CMPI.B  #$11,D2
    BEQ     OPadda
    
    BRA     OPadd
    
*********************************************************************************
* Method Name: OPmuls
* Description: OP code is muls so run respective EA method based on size
*********************************************************************************      
OPmuls
    MOVE.L  A3,A4   
    JSR     getNext2Bytes

    LEA     LetterM,A2
    JSR     addBuffer
    LEA     LetterU,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    MOVE.L  #$00000011,D0
    JSR     compareEAModeMULS
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPadda
* Description: OPcode is adda so run respective EA method based on size
*********************************************************************************      
OPadda
    MOVE.L  A3,A4   loading back the start of EA for ADDA
    JSR     getNext2Bytes

    CMPI.W  #$0011,D3
    BEQ     OPaddaw
    
    CMPI.W  #$0111,D3
    BEQ     OPaddal
OPaddaw
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000011,D0
    
    JSR     compareEAModeADDA
    
    BRA     askForNextCode
OPaddal
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    MOVE.L  #$00000010,D0
    JSR     compareEAModeADDA
    
    BRA     askForNextCode 

*********************************************************************************
* Method Name: OPadd
* Description: OP code is add so run respective EA method based on size
*********************************************************************************      
OPadd
    MOVE.L  A3,A4   loading back the start of EA for ADD
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    MOVE.L  D2,D3
    LSL.W   #08,D3
    JSR     getNext2Bytes
    ADD.L   D2,D3
    AND     #$00000111,D3
    
    MOVE.L  A3,A4
    JSR     getNext2Bytes
    
    CMPI.W  #$0000,D3
    BEQ     OPaddb
     
    CMPI.W  #$0100,D3
    BEQ     OPaddbv2
    
    CMPI.W  #$0001,D3
    BEQ     OPaddw
    
    CMPI.W  #$0101,D3
    BEQ     OPaddwv2
    
    CMPI.W  #$0010,D3
    BEQ     OPaddl
    
    CMPI.W  #$0110,D3
    BEQ     OPaddlv2
    
    BRA     OPdata
OPaddb
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPaddbv2
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode
OPaddw
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPaddwv2
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode
OPaddl
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv1
    
    BRA     askForNextCode
OPaddlv2
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     LetterD,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    
    JSR     compareEAModeADDv2
    
    BRA     askForNextCode

*********************************************************************************
* Method Name: OPasrmem - rolmem etc etc
* Description: Runs a method based on the OPcode
*********************************************************************************      
OPasrmem
    JSR     getNext2Bytes
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftEA
    
    BRA     askForNextCode
    
OPaslmem
    JSR     getNext2Bytes
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftEA
    
    BRA     askForNextCode
    
OPlsrmem
    JSR     getNext2Bytes
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftEA
    
    BRA     askForNextCode
    
OPlslmem
    JSR     getNext2Bytes
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftEA
    
    BRA     askForNextCode
    
OPrormem
    JSR     getNext2Bytes
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftEA
    
    BRA     askForNextCode
    
OProlmem
    JSR     getNext2Bytes
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftEA
    
    BRA     askForNextCode
    
*********************************************************
* IMPORTANT: the methods for all shift insructions like
* asr, lsl, etc are the same format. They all run a method
* based on whether i/r is 1 or 0. They then all run a methof
* based on the size.
*
*********************************************************

*********************************************************************************
* Method Name: OPasrreg - lslreg etc
* Description: Runs a method based on whether I is 0 or 1. 
*********************************************************************************      
OPasrreg
    *D3 == count? register + dr
    *D4 == size
    *D5 == i/r + 0
    JSR     getNext2Bytes   *****now pointing to 0 + start of register
    
    LSR.L   #04,D3  ****D3 now holds the count or register
    
    CMPI.B  #$10,D5
    BEQ     OPasrregI1
    
    CMPI.B  #$00,D5
    BEQ     OPasrregI0
    
    BRA     OPdata

*********************************************************************************
* Method Name: OPasrregI1, I0, lslregI1, etc etc
* Description: Runs a method based on the size
********************************************************************************* 
OPasrregI1
    CMPI.B  #$00,D4
    BEQ     OPasrregbi1
    
    CMPI.B  #$01,D4
    BEQ     OPasrregwi1
    
    CMPI.B  #$10,D4
    BEQ     OPasrregli1
    
    BRA     OPdata
    
OPasrregI0
    CMPI.B  #$00,D4
    BEQ     OPasrregbi0
    
    CMPI.B  #$01,D4
    BEQ     OPasrregwi0
    
    CMPI.B  #$10,D4
    BEQ     OPasrregli0
    
    BRA     OPdata

OPasrregbi1
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPasrregwi1
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPasrregli1
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPasrregbi0
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPasrregwi0
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPasrregli0
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
    
OPlsrreg
    *D3 == count? register + dr
    *D4 == size
    *D5 == i/r + 0
    JSR     getNext2Bytes
    
    LSR.L   #04,D3  ****D3 now holds the count or register
    
    CMPI.B  #$10,D5
    BEQ     OPisrregI1
    
    CMPI.B  #$00,D5
    BEQ     OPisrregI0
    
    BRA     OPdata
OPisrregI1
    CMPI.B  #$00,D4
    BEQ     OPisrregbi1
    
    CMPI.B  #$01,D4
    BEQ     OPisrregwi1
    
    CMPI.B  #$10,D4
    BEQ     OPisrregli1
    
    BRA     OPdata
OPisrregI0
    CMPI.B  #$00,D4
    BEQ     OPisrregbi0
    
    CMPI.B  #$01,D4
    BEQ     OPisrregwi0
    
    CMPI.B  #$10,D4
    BEQ     OPisrregli0
    
    BRA     OPdata
OPisrregbi1
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPisrregwi1
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPisrregli1
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPisrregbi0
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPisrregwi0
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPisrregli0
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
    
OProrreg
    *D3 == count? register + dr
    *D4 == size
    *D5 == i/r + 0
    JSR     getNext2Bytes
    
    LSR.L   #04,D3  ****D3 now holds the count or register
    
    CMPI.B  #$10,D5
    BEQ     OProrregI1
    
    CMPI.B  #$00,D5
    BEQ     OProrregI0
    
    BRA     OPdata
OProrregI1
    CMPI.B  #$00,D4
    BEQ     OProrregbi1
    
    CMPI.B  #$01,D4
    BEQ     OProrregwi1
    
    CMPI.B  #$10,D4
    BEQ     OProrregli1
    
    BRA     OPdata
OProrregI0
    CMPI.B  #$00,D4
    BEQ     OProrregbi0
    
    CMPI.B  #$01,D4
    BEQ     OProrregwi0
    
    CMPI.B  #$10,D4
    BEQ     OProrregli0
    
    BRA     OPdata
OProrregbi1
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OProrregwi1
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OProrregli1
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OProrregbi0
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OProrregwi0
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OProrregli0
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
    
OPaslreg
    *D3 == count? register + dr
    *D4 == size
    *D5 == i/r + 0
    JSR     getNext2Bytes
    
    LSR.L   #04,D3  ****D3 now holds the count or register
    
    CMPI.B  #$10,D5
    BEQ     OPaslregI1
    
    CMPI.B  #$00,D5
    BEQ     OPaslregI0
    
    BRA     OPdata
OPaslregI1
    CMPI.B  #$00,D4
    BEQ     OPaslregbi1
    
    CMPI.B  #$01,D4
    BEQ     OPaslregwi1
    
    CMPI.B  #$10,D4
    BEQ     OPaslregli1
    
    BRA     OPdata
OPaslregI0
    CMPI.B  #$00,D4
    BEQ     OPaslregbi0
    
    CMPI.B  #$01,D4
    BEQ     OPaslregwi0
    
    CMPI.B  #$10,D4
    BEQ     OPaslregli0
    
    BRA     OPdata
OPaslregbi1
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPaslregwi1
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPaslregli1
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPaslregbi0
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPaslregwi0
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPaslregli0
    LEA     LetterA,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
    
OPlslreg
    *D3 == count? register + dr
    *D4 == size
    *D5 == i/r + 0
    JSR     getNext2Bytes
    
    LSR.L   #04,D3  ****D3 now holds the count or register
    
    CMPI.B  #$10,D5
    BEQ     OPlslregI1
    
    CMPI.B  #$00,D5
    BEQ     OPlslregI0
    
    BRA     OPdata
OPlslregI1
    CMPI.B  #$00,D4
    BEQ     OPlslregbi1
    
    CMPI.B  #$01,D4
    BEQ     OPlslregwi1
    
    CMPI.B  #$10,D4
    BEQ     OPlslregli1
    
    BRA     OPdata
OPlslregI0
    CMPI.B  #$00,D4
    BEQ     OPlslregbi0
    
    CMPI.B  #$01,D4
    BEQ     OPlslregwi0
    
    CMPI.B  #$10,D4
    BEQ     OPlslregli0
    
    BRA     OPdata
OPlslregbi1
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPlslregwi1
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPlslregli1
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OPlslregbi0
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPlslregwi0
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OPlslregli0
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     LetterS,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
    
OProlreg
    *D3 == count? register + dr
    *D4 == size
    *D5 == i/r + 0
    JSR     getNext2Bytes
    
    LSR.L   #04,D3  ****D3 now holds the count or register
    
    CMPI.B  #$10,D5
    BEQ     OProlregi1
    
    CMPI.B  #$00,D5
    BEQ     OProlregi0
    
    BRA     OPdata
OProlregI1
    CMPI.B  #$00,D4
    BEQ     OProlregbi1
    
    CMPI.B  #$01,D4
    BEQ     OProlregwi1
    
    CMPI.B  #$10,D4
    BEQ     OProlregli1
    
    BRA     OPdata
OProlregI0
    CMPI.B  #$00,D4
    BEQ     OProlregbi0
    
    CMPI.B  #$01,D4
    BEQ     OProlregwi0
    
    CMPI.B  #$10,D4
    BEQ     OProlregli0
    
    BRA     OPdata
OProlregbi1
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OProlregwi1
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OProlregli1
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShift2Data
    
    BRA     askForNextCode
OProlregbi0
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterB,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OProlregwi0
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterW,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
OProlregli0
    LEA     LetterR,A2
    JSR     addBuffer
    LEA     LetterO,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     period,A2
    JSR     addBuffer
    LEA     LetterL,A2
    JSR     addBuffer
    LEA     space,A2
    JSR     addBuffer
    JSR     compareEAModeShiftCount
    
    BRA     askForNextCode
    
* Loads D5 and D6 with the MODE and EAXn bits respectively
* Precondition: OPCode bits are valid
* Postcondition: D5 holds the 3 MODE bits and D6 holds the 3 EAXn bits
EALoadBits
    MOVE.L      #$00000000,D5
    MOVE.L      #$00000000,D6
    ************Effective Address Mode = 000 001
    MOVE.L      D2,D5               *D5 now holds 0000 0000*
    LSL.L       #08,D5              *Shifts D5 to the left by 2*
    JSR         getNext2Bytes       *Grabs the next 2 bits... D2 now holds 0000 0000*
    ADD.L       D2,D5               *D5 now holds 0000 0000*
    LSL.L       #08,D5              *D5 now holds 0000 0000*
    JSR         getNext2Bytes       *Grabs the next 2 bits... D2 now holds 0000 0001*
    ADD.L       D2,D5               *D5 now holds the 6 bits of EA: 0000 0001*
    MOVE.L      D5,D6
    AND         #$00000111,D6       *D6 contains effective address register
    LSR.L       #08,D5               *D5 shift right once. D5 contains effective address mode
    LSR.L       #04,D5               *D5 shift right once. D5 contains effective address mode
    RTS

*********************************************************************************
* Method Name: EALoadBitsReverse
* Description: Loads the EA stuff into D5 and D6 but puts register into D5 and 
* mode in D6
*********************************************************************************      
EALoadBitsReverse
    MOVE.L      #$00000000,D5
    MOVE.L      #$00000000,D6
  
    MOVE.L      D2,D6               
    LSL.L       #08,D6              
    JSR         getNext2Bytes       
    ADD.L       D2,D6               
    LSL.L       #08,D6              
    JSR         getNext2Bytes       
    ADD.L       D2,D6               
    MOVE.L      D6,D5
    AND         #$00000111,D5       
    LSR.L       #08,D6              
    LSR.L       #04,D6              
    RTS

*********************************************************************************
* Method Name: EALoadBitsDestinationFromD0
* Description: Grabs the EA stored in D0 and stores register in D5 and mode in D6
*********************************************************************************      
EALoadBitsDestinationFromD0
    MOVE.L      #$00000000,D5
    MOVE.L      #$00000000,D6
    MOVE.L      D0,D5
    MOVE.L      D5,D6
    AND         #$00000111,D6
    LSR.L       #08,D5
    LSR.L       #04,D5
    RTS

*********************************************************************************
* Method Name: EALoadBitsRevDestinationFromD0
* Description: Grabs EA in D0 and stores register in D6 and mode in D5
*********************************************************************************      
EALoadBitsRevDestinationFromD0
    MOVE.L      #$00000000,D5
    MOVE.L      #$00000000,D6
    MOVE.L      D0,D6
    MOVE.L      D6,D5
    AND         #$00000111,D5       
    LSR.L       #08,D6              
    LSR.L       #04,D6 
    AND         #$00000111,D6
    RTS
    
*********************************************************************************
* Method Name: EALoadBitsSource
* Description: Clears D5 and D6, grabs the EA stuff from memory
*********************************************************************************  
EALoadBitsSource
    MOVE.L      #$00000000,D5
    MOVE.L      #$00000000,D6
    ************Effective Address Mode = 000 001
    MOVE.L      D2,D5               *D5 now holds 0000 0000*
    LSL.L       #08,D5              *Shifts D5 to the left by 2*
    JSR         getNext2Bytes       *Grabs the next 2 bits... D2 now holds 0000 0000*
    ADD.L       D2,D5               *D5 now holds 0000 0000*
    LSL.L       #08,D5             *D5 now holds 0000 0000*
    JSR         getNext2Bytes       *Grabs the next 2 bits... D2 now holds 0000 0001*
    ADD.L       D2,D5               *D5 now holds the 6 bits of EA: 0000 0001*
    MOVE.L      D5,D6
    AND         #$00000111,D6       *D6 contains effective address register
    LSR.L       #08,D5               *D5 shift right once. D5 contains effective address mode
    LSR.L       #04,D5               *D5 shift right once. D5 contains effective address mode
    RTS

*********************************************************************************
* Method Name: EAPushToD0
* Description: gets the EA information from memory and stores it in D0
*********************************************************************************      
EAPushToD0
    MOVE.L      #$00000000,D5
    MOVE.L      #$00000000,D6
    
    LSL.L       #08,D0
    LSL.L       #08,D0
    LSL.L       #08,D0
    
    MOVE.L      D2,D5
    LSL.L       #08,D5
    JSR         getNext2Bytes
    ADD.L       D2,D5
    LSL.L       #08,D5
    JSR         getNext2Bytes
    ADD.L       D2,D5
    ADD.L       D5,D0
    
    RTS

*********************************************************************************
* Method Name: compareEAModeShift2Data
* Description: Compares the EA data and runs the respective methods for shift
* Instructions in which 2 data regsiters are used
*********************************************************************************      
compareEAModeShift2Data
    ***D3 holds datax, D2 holds x+datay
    
    MOVE.L      D2,D5
    LSL.W       #08,D5
    JSR         getNext2Bytes
    ADD.L       D2,D5
    AND.L       #$00000111,D5
    **D5 now holds reg
    
    MOVE.L      D3,D6
    JSR         EAModeDataReg
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D5,D6
    JSR         EAModeDataReg
    
    RTS
*********************************************************************************
* Method Name: compareEAModeShiftCount
* Description: Compares the EA data and runs the respective methods for shift
* Insturtions in which a data reg and immedate value are used
*********************************************************************************  
compareEAModeShiftCount
    MOVE.L      D2,D5
    LSL.W       #08,D5
    JSR         getNext2Bytes
    ADD.L       D2,D5
    AND.L       #$00000111,D5

    LEA         NumberSign,A2
    JSR         addBuffer
    JSR         getImmediateValue
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D5,D6
    JSR         EAModeDataReg
    
    RTS
*********************************************************************************
* Method Name: compareEAModeShiftEA
* Description: Compares EA data and runs respective methods for shift Instructions
* for where they just print an EA
*********************************************************************************  
compareEAModeShiftEA
    JSR         EALoadBits
    
    CMPI.W      #$0010,D5              ; Mode bits are 010
    BEQ         EAModeARIndirect 
    
    CMPI.W      #$0011,D5              ; Mode bits are 011
    BEQ         EAModeIncrement 
    
    CMPI.W      #$0100,D5              ; Mode bits are 101
    BEQ         EAModeDecrement 
    
    CMPI.W      #$0111,D5              ; Mode bits are 111
    BEQ         EAModeDirect
    
    BRA         OPdata
*********************************************************************************
* Method Name: compareEAModeMOVE
* Description: Runs the respective EA methods based on the EA of move
*********************************************************************************  
compareEAModeMOVE
    JSR         EAPushToD0
    JSR         getNext2Bytes
    JSR         EALoadBitsSource
    MOVE.L      D0,D2
    LSR.L       #08,D0
    LSR.L       #08,D0
    LSR.L       #08,D0
    
    JSR         OPmoveEASourcecheck
    MOVE.L      D2,D0
    AND.L        #$00111111,D0
    LEA         comma,A2
    JSR         addBuffer
    
    JSR         EALoadBitsRevDestinationFromD0
    
    CMPI.W      #$0000,D5              ; Mode bits are 000
    BEQ         EAModeDataReg
    
    CMPI.W      #$0010,D5              ; Mode bits are 010
    BEQ         EAModeARIndirect 
    
    CMPI.W      #$0011,D5              ; Mode bits are 011
    BEQ         EAModeIncrement 
    
    CMPI.W      #$0100,D5              ; Mode bits are 101
    BEQ         EAModeDecrement 
    
    CMPI.W      #$0111,D5              ; Mode bits are 111
    BEQ         EAModeDirect
    
    BRA         OPdata
    
*********************************************************************************
* Method Name: OPmoveEASourcecheck
* Description: Checks for all possible MOVE combinations for EA
*********************************************************************************     
OPmoveEASourcecheck
     CMPI.W     #$0000,D5
     BEQ        EAModeDataReg
     
     CMPI.W     #$0001,D5
     BEQ        EAModeAddrReg
     
     CMPI.W     #$0010,D5
     BEQ        EAModeARIndirect
     
     CMPI.W     #$0011,D5
     BEQ        EAModeIncrement
     
     CMPI.W     #$0100,D5
     BEQ        EAModeDecrement
     
     CMPI.W     #$0111,D5
     BEQ        EAModeDirectOrImm  
     
     BRA        OPdata

*********************************************************************************
* Method Name: compareEAModeJSR
* Description: Checks for all possible JSR combinations for EA
*********************************************************************************       
compareEAModeJSR
    JSR         EALoadBits
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect

*********************************************************************************
* Method Name: compareEAModeMOVEA
* Description: Checks for all possible MOVEA combinations for EA
*********************************************************************************      
compareEAModeMOVEA
    LSL.W       #08,D2
    MOVE.L      D2,D3
    JSR         getNext2Bytes
    ADD.L       D2,D3
    LSR.L       #04,D3
    
    JSR         getNext2Bytes
    JSR         getNext2Bytes
    
    JSR         EALoadBits
    JSR         allEA
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D3,D6
    BRA         EAModeAddrReg
*********************************************************************************
* Method Name: allEA
* Description: Checks for all possible EA modes
*********************************************************************************     
allEA
    CMPI.W      #$0000,D5              ; Mode bits are 000
    BEQ         EAModeDataReg
    
    CMPI.W      #$0001,D5
    BEQ         EAModeAddrReg
    
    CMPI.W      #$0010,D5              ; Mode bits are 010
    BEQ         EAModeARIndirect 
    
    CMPI.W      #$0011,D5              ; Mode bits are 011
    BEQ         EAModeIncrement 
    
    CMPI.W      #$0100,D5              ; Mode bits are 101
    BEQ         EAModeDecrement 
    
    CMPI.W      #$0111,D5              ; Mode bits are 111
    BEQ         EAModeDirectOrImm
    
    BRA         OPdata
*********************************************************************************
* Method Name: compareEAModeADDv1
* Description: Checks for all possible ADD combinations for EA where data reg is
* printed second
*********************************************************************************     
compareEAModeADDv1
    MOVE.L      D2,D3
    LSL.L       #08,D3
    JSR         getNext2Bytes
    ADD.L       D2,D3
    LSR.L       #04,D3
    
    JSR         getNext2Bytes
    JSR         getNext2Bytes
    
    JSR         EALoadBits
    JSR         allEA
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D3,D6
    BRA         EAModeDataReg

*********************************************************************************
* Method Name: compareEAModeADDv2
* Description: Checks for all possible ADD combinations for EA where data reg is
* printed first
*********************************************************************************     
compareEAModeADDv2
    MOVE.L      D2,D3
    LSL.L       #08,D3
    JSR         getNext2Bytes
    ADD.L       D2,D3
    LSR.L       #04,D3

    MOVE.L      D3,D6
    JSR         EAModeDataReg

    LEA         comma,A2
    JSR         addBuffer

    JSR         getNext2Bytes
    JSR         getNext2Bytes

    JSR         EALoadBits  
    CMPI.W      #$0010,D5              ; Mode bits are 010
    BEQ         EAModeARIndirect 
    
    CMPI.W      #$0011,D5              ; Mode bits are 011
    BEQ         EAModeIncrement 
    
    CMPI.W      #$0100,D5              ; Mode bits are 101
    BEQ         EAModeDecrement 
    
    CMPI.W      #$0111,D5              ; Mode bits are 111
    BEQ         EAModeDirect  
*********************************************************************************
* Method Name: compareEAModeLEA
* Description: Checks for all possible LEA combinations for EA
********************************************************************************* 
compareEAModeLEA
    JSR     getNext2Bytes
    MOVE.L  D2,D6
    LSL.W   #08,D6
    JSR     getNext2Bytes
    ADD.L   D2,D6
    LSR.W   #04,D6
    MOVE.L  D6,D1
    
    JSR     getNext2Bytes
    JSR     getNext2Bytes
    
    JSR EALoadBits
    JSR     LEAmethod
    
    MOVE.L  D1,D6
    
    LEA comma,A2
    JSR addBuffer
    BRA EAModeAddrReg
LEAmethod
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect
    
    BRA         OPdata
*********************************************************************************
* Method Name: compareEAModeADDA
* Description: Checks for all possible ADDA combinations for EA
********************************************************************************* 
compareEAModeADDA
    MOVE.L      D2,D3
    LSL.L       #08,D3
    JSR         getNext2Bytes
    ADD.L       D2,D3
    LSR.L       #04,D3
    
    JSR         getNext2Bytes
    JSR         getNext2Bytes
    
    JSR         EALoadBits
    JSR         allEA
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D3,D6
    BRA         EAModeAddrReg

* Prints the <ea> for SUB
* Supported Modes: All
* Note: OPMODE bits determine the syntax    
compareEAModeSUB
    JSR         EALoadBits
    
    CMPI.W      #$0000,D5
    BEQ         EAModeDataReg
    
    CMPI.W      #$0001,D5
    BEQ         EAModeAddrReg
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirectOrImm
    
    BRA         OPdata
    
* Prints the <ea> for OR
* Supported Modes: Dn, (An), (An)+, -(An), Direct, Immediate
compareEAModeOR
    JSR         EALoadBits
    
    CMPI.W      #$0000,D5
    BEQ         EAModeDataReg
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirectOrImm
    
    BRA         OPdata
    
* Prints the <ea> for EOR
* Supported Modes: Dn, (An), (An)+, -(An), Direct
compareEAModeEOR
    JSR         EAModeDataReg
    
    LEA         comma,A2
    JSR         addBuffer

    JSR         EALoadBits
    
    CMPI.W      #$0000,D5
    BEQ         EAModeDataReg
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect
    
    BRA         OPdata

* Prints the <ea> for CMP
* Supported Modes: All
compareEAModeCMP
    JSR         EALoadBits
    
    JSR         allEA
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D3,D6
    BRA         EAModeDataReg
    
    BRA         OPdata

*********************************************************************************
* Method Name: compareEAModeBCLRDynamic
* Description: Checks for all possible BCLR combinations when BCLR is dynamic
********************************************************************************* 
compareEAModeBCLRDynamic
    JSR         EAModeDataReg
    LEA         comma,A2
    JSR         addBuffer
    
    JSR         EALoadBits

    CMPI.W      #$0000,D5
    BEQ         EAModeDataReg
    
    CMPI.W      #$0001,D5
    BEQ         EAModeAddrReg
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirectOrImm
    
    BRA         OPdata
*********************************************************************************
* Method Name: compareEAModeBCLRStatic
* Description: Checks for all possible BCLR combinations when BCLR is static
*********************************************************************************     
compareEAModeBCLRStatic
    JSR         EALoadBits
    MOVE.L      D5,D3
    MOVE.L      D6,D4
    
    MOVE.L      #$00000011,D0
    JSR         EAModeImmediate
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D3,D5
    MOVE.L      D4,D6
    
    CMPI.W      #$0000,D5
    BEQ         EAModeDataReg
    
    CMPI.W      #$0001,D5
    BEQ         EAModeAddrReg
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirectOrImm

* Prints the <ea> for NEG
* Supported Modes: Dn, (An), (An)+, -(An), Direct
compareEAModeNEG
    JSR         EALoadBits
    
    CMPI.W      #$0000,D5
    BEQ         EAModeDataReg
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect
    
    BRA         OPdata

*********************************************************************************
* Method Name: compareEAModeMULS
* Description: Checks for all possible MULS combinations for EA
*********************************************************************************     
compareEAModeMULS
    MOVE.L      D2,D3
    LSL.W       #08,D3
    JSR         getNext2Bytes
    ADD.L       D2,D3
    LSR.W       #04,D3
    
    JSR         getNext2Bytes
    JSR         getNext2Bytes
    
    JSR         EALoadBits
    
    CMPI.W      #$0001,D5
    BEQ         OPdata
    
    JSR         allEA
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D3,D6
    BRA         EAModeDataReg

*********************************************************************************
* Method Name: compareEAModeDIVS
* Description: Checks for all possible DIVS combinations for EA
*********************************************************************************     
compareEAModeDIVS
    MOVE.L      D2,D3
    LSL.W       #08,D3
    JSR         getNext2Bytes
    ADD.L       D2,D3
    LSR.W       #04,D3
    
    JSR         getNext2Bytes
    JSR         getNext2Bytes
    
    JSR         EALoadBits
    
    CMPI.W      #$0001,D5
    BEQ         OPdata
    
    JSR         allEA
    
    LEA         comma,A2
    JSR         addBuffer
    
    MOVE.L      D3,D6
    BRA         EAModeDataReg

*********************************************************************************
* Method Name: compareEAModeSUBQ
* Description: Checks for all possible SUBQ combinations for EA
*********************************************************************************     
compareEAModeSUBQ
    JSR         EALoadBits
    
    LEA         NumberSign,A2
    JSR         addBuffer
    JSR         getImmediateValue
    
    LEA         comma,A2
    JSR         addBuffer
    
    BRA         allEA

*********************************************************************************
* Method Name: getImmediateValue
* Description: Writes a value to the string buffer based on the value in D3
********************************************************************************* 
getImmediateValue
    CMPI.W      #$0000,D3
    BEQ         write8
    
    CMPI.W      #$0001,D3
    BEQ         write1
    
    CMPI.W      #$0010,D3
    BEQ         write2
    
    CMPI.W      #$0011,D3
    BEQ         write3
    
    CMPI.W      #$0100,D3
    BEQ         write4
    
    CMPI.W      #$0101,D3
    BEQ         write5
    
    CMPI.W      #$0110,D3
    BEQ         write6
    
    CMPI.W      #$0111,D3
    BEQ         write7
* Prints the <ea> for ORI
* Supported Modes: Dn, (An), (An)+, -(An), Direct
* Note: Syntax is ORI #<data>, <ea>, but EA bits come before the immediate bits
compareEAModeORI
    MOVE.L      A6,D4
    MOVE.L      A4,D3

    JSR         EALoadBits
    
    JSR         OrigetNext
    
    SUBI        #1,D3
    MOVE.L      D3,A4
    
    JSR         getNext2Bytes
    JSR         EALoadBits
    
    LEA         comma,A2
    JSR         addBuffer
    
    CMPI.W      #$0000,D5
    BEQ         EAModeDataReg
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect
    
    BRA         OPdata

*********************************************************************************
* Method Name: ORIget ---- ORI....
* Description: Checks for all possible ORI combinations for EA.
*********************************************************************************     
OrigetNext
    CMPI        #$00,D0
    BEQ         Oriword
    
    CMPI        #$01,D0
    BEQ         Orilong
Oriword
    MOVE.W      (A6)+,D5
    JSR         OriprintLong
    RTS
Orilong
    MOVE.L      (A6)+,D5
    JSR         OriprintLong
    RTS
    
OriprintLong
    
    LEA         DollarSign,A2 ; Print $
    JSR         addBuffer
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    RTS

*********************************************************************************
* Method Name: compareEAModeMOVEMreg
* Description: Checks for all possible MOVEM combinations for EA
*********************************************************************************     
compareEAModeMOVEMreg
    JSR         EALoadBits
    JSR         Movemword
    
    LEA         comma,A2
    JSR         addBuffer
    
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect

*********************************************************************************
* Method Name: MOVEMmemhexcheck
* Description: grabs 4 hex values and prints A0 - D7 based on whether they are 1 or not
*********************************************************************************     
MOVEMmemhexcheck
    ROL.L       #4,D0
    ROL.L       #4,D0
    ROL.L       #4,D0
    ROL.L       #4,D0
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    
    MOVE.L      #$00000000,D1
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA7
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA6
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA5
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA4
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA3
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA2
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA1
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA0
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD7
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD6

    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD5
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD4
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD3
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD2

    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD1
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD0
    
    RTS

*********************************************************************************
* Method Name: compareEAModeMOVEMmem
* Description: Checks for all possible MOVEM combinations for EA
********************************************************************************* 
compareEAModeMOVEMmem
    JSR         EALoadBits
    JSR         MOVEMmemcheck
    
    RTS
*********************************************************************************
* Method Name: MOVEMreghexcheck
* Description: Grabs 4 hex values and prints A0 - D7 based on if they are 1 or not
*********************************************************************************     
MOVEMreghexcheck
    ROL.L       #4,D0
    ROL.L       #4,D0
    ROL.L       #4,D0
    ROL.L       #4,D0
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    ROL.L       #4,D4
    
    MOVE.L      #$00000000,D1
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD0
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD1
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD2
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD3
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD4
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD5
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD6
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkD7
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA0
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA1

    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA2
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA3
    
    ROL.L       #4,D0
    MOVE.B      D0,D3
    AND.B       #$0F,D3
    JSR         hexToBinary
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA4
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA5

    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA6
    
    ROL.L       #4,D4
    MOVE.L      D4,D3
    AND.B       #$01,D3
    JSR         checkA7
    
    RTS

    
MOVEMmemcheck
    JSR         movemmemEA
    LEA         comma,A2
    JSR         addBuffer
    
    JSR         Movemwordmem
    RTS

movemmemEA
    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect
    
    RTS
    
Movemword
    MOVE.W      (A6)+,D0
    JSR         MOVEMreghexcheck
    RTS 
    
Movemwordmem
    MOVE.W      (A6)+,D0
    JSR         MOVEMmemhexcheck
    RTS
    
hexToBinary
    CMPI.B      #$00,D3
    BEQ         Hex0
    
    CMPI.B      #$01,D3
    BEQ         Hex1
    
    CMPI.B      #$02,D3
    BEQ         Hex2
    
    CMPI.B      #$03,D3
    BEQ         Hex3
    
    CMPI.B      #$04,D3
    BEQ         Hex4
    
    CMPI.B      #$05,D3
    BEQ         Hex5
    
    CMPI.B      #$06,D3
    BEQ         Hex6
    
    CMPI.B      #$07,D3
    BEQ         Hex7
    
    CMPI.B      #$08,D3
    BEQ         Hex8
    
    CMPI.B      #$09,D3
    BEQ         Hex9
    
    CMPI.B      #$0A,D3
    BEQ         HexA
    
    CMPI.B      #$0B,D3
    BEQ         HexB
    
    CMPI.B      #$0C,D3
    BEQ         HexC
    
    CMPI.B      #$0D,D3
    BEQ         HexD
    
    CMPI.B      #$0E,D3
    BEQ         HexE
    
    CMPI.B      #$0F,D3
    BEQ         HexF
    ****compare for all possible hex***
    
Hex0
    MOVE.L      #$00000000,D4
    RTS
Hex1
    MOVE.L      #$00000001,D4
    RTS
Hex2
    MOVE.L      #$00000010,D4
    RTS
Hex3
    MOVE.L      #$00000011,D4
    RTS
Hex4
    MOVE.L      #$00000100,D4
    RTS
Hex5
    MOVE.L      #$00000101,D4
    RTS
Hex6
    MOVE.L      #$00000110,D4
    RTS
Hex7
    MOVE.L      #$00000111,D4
    RTS
Hex8
    MOVE.L      #$00001000,D4
    RTS
Hex9
    MOVE.L      #$00001001,D4
    RTS
HexA
    MOVE.L      #$00001010,D4
    RTS
HexB
    MOVE.L      #$00001011,D4
    RTS
HexC
    MOVE.L      #$00001100,D4
    RTS
HexD
    MOVE.L      #$00001101,D4
    RTS
HexE
    MOVE.L      #$00001110,D4
    RTS
HexF
    MOVE.L      #$00001111,D4
    RTS   

checkSlash
    CMPI.B      #$01,D1
    BEQ         writeSlash
    RTS
writeSlash
    LEA         slash,A2
    MOVE.L      #$00000000,D1
    JSR         addBuffer
    RTS
checkA0
    CMPI.B        #$01,D3
    BEQ         movemA0
    RTS
checkA1
    CMPI.B        #$01,D3
    BEQ         movemA1
    RTS
checkA2
    CMPI.B        #$01,D3
    BEQ         movemA2   
    RTS 
checkA3
    CMPI.B        #$01,D3
    BEQ         movemA3
    RTS
checkA4
    CMPI.B        #$01,D3
    BEQ         movemA4
    RTS
checkA5
    CMPI.B        #$01,D3
    BEQ         movemA5
    RTS
checkA6
    CMPI.B        #$01,D3
    BEQ         movemA6
    RTS
checkA7
    CMPI.B        #$01,D3
    BEQ         movemA7
    RTS
checkD0
    CMPI.B        #$01,D3
    BEQ         movemD0
    RTS
checkD1
    CMPI.B        #$01,D3
    BEQ         movemD1
    RTS
checkD2
    CMPI.B        #$01,D3
    BEQ         movemD2
    RTS
checkD3
    CMPI.B        #$01,D3
    BEQ         movemD3
    RTS
checkD4
    CMPI.B        #$01,D3
    BEQ         movemD4
    RTS
checkD5
    CMPI.B        #$01,D3
    BEQ         movemD5
    RTS
checkD6
    CMPI.B        #$01,D3
    BEQ         movemD6
    RTS
checkD7
    CMPI.B        #$01,D3
    BEQ         movemD7
    RTS
movemA0
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number0,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemA1
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number1,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemA2
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number2,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemA3
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number3,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemA4
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number4,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemA5
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number5,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemA6
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number6,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemA7
    JSR         checkSlash
    LEA         LetterA,A2
    JSR         addBuffer
    LEA         Number7,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemD0
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number0,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemD1
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number1,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemD2
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number2,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemD3
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number3,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemD4
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number4,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemD5
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number5,A2
    MOVE.L      #$00000001,D1
   JSR         addBuffer
    RTS
movemD6
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number6,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
movemD7
    JSR         checkSlash
    LEA         LetterD,A2
    JSR         addBuffer
    LEA         Number7,A2
    MOVE.L      #$00000001,D1
    JSR         addBuffer
    RTS
* Prints the <ea> for ASL and ASR
* Only valid on ASd <ea> syntax
* Supported Modes: (An), (An)+, -(An), Direct
* Note: ASd has two other syntaxes
*       ASd Dx,Dy and ASd #<data>,Dy
*       which are dependent on the OPCode bits
compareEAModeASd
    JSR         EALoadBits

    CMPI.W      #$0010,D5
    BEQ         EAModeARIndirect
    
    CMPI.W      #$0011,D5
    BEQ         EAModeIncrement
    
    CMPI.W      #$0100,D5
    BEQ         EAModeDecrement
    
    CMPI.W      #$0111,D5
    BEQ         EAModeDirect
    
    BRA         OPdata
    
    
* Loads D5 with the last 8 bits in the OPCode which
* represent displacement bits
* Used in BRA and Bcc operations
* Precondition: OPCode bits are valid
* Postcondition: D5 holds the 8 DISPLACEMENT bits  
EALoadDisplacementBits
    CLR.L       D5
    
    MOVE.L      D2,D5
    LSL.L       #08,D5
    JSR         getNext2Bytes
    
    ADD.L       D2,D5
    LSL.L       #08,D5
    JSR         getNext2Bytes
    
    ADD.L       D2,D5
    LSL.L       #08,D5
    JSR         getNext2Bytes
    
    ADD.L       D2,D5
    
    RTS

* Prints the <label> for Bcc and BRA
* Note: Displacement length is dependent on
*       the last 8 bits of the OPCode
*       8-bit: Two's compliment integer specifying # of bytes
*              between branch and next instruction
*       16-bit: 8 bits = $00. Displacement is next word
*       32-bit: 8 bits = $FF. Displacement is next long
compareLabelBcc
    JSR         EALoadDisplacementBits
    
    MOVE.L      #$00000000,D0
    MOVE.L      A6, D0

    CMPI.L      #$00000000,D5
    BEQ         BccNextWord ; print following word

    CMPI.L      #$11111111,D5
    BEQ         BccNextLong ; print following long
    
    BRA         DisplacementByte ; convert D5 to hex values and print

* Used for BCC and BRA.
* Adds instruction address location to the displacement
* and prints  (for word)   
BccNextWord
    JSR         getNextWord
    
    ADD.L       D0,D5
    MOVE.L      #$00000000,D0
    CLR         D0
    
    LEA         DollarSign,A2 ; Print $
    JSR         addBuffer
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    RTS

* Used for BCC and BRA.
* Adds instruction address location to the displacement
* and prints  (for long)  
BccNextLong
    JSR         getNextLong
    
    ADD.L       D0,D5
    MOVE.L      #$00000000,D0
    CLR         D0
    
    LEA         DollarSign,A2 ; Print $
    JSR         addBuffer
    
    CLR         D0
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    RTS

 

* Prints out the address that BRA or BCC is going to
* Grabs the address location of instruction, Adds it
* To the 8 bit displacement of the instruction, subtracts
* $0100 from it and prints it.
DisplacementByte
    MOVE.L      #$00000000,D1
    CLR         D1
    MOVE.L      D0,D1
    MOVE.L      #$00000000,D0
    CLR         D0

    SWAP        D5
    JSR         Print16BitsToHex
    
    LSL.W       #04,D0
    
    SWAP        D5
    JSR         Print16BitsToHex
    
    ADD.L       D0, D1
    SUB.L         #$0100,D1
    
    LEA         DollarSign,A2 ; Print $
    JSR         addBuffer
    
    MOVE.L      D1,D5
    
    ROL.L       #4,D5
    
    ROL.L       #4,D5
    
    ROL.L       #4,D5
    
    ROL.L       #4,D5
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    RTS

* Helper function used to convert the 32 LSB bits in D5
* into a single hex value and print it.
Print16BitsToHex
    CMPI.W  #$0000,D5
    BEQ     bcc0
    
    CMPI.W  #$0001,D5
    BEQ     bcc1
    
    CMPI.W  #$0010,D5
    BEQ     bcc2
    
    CMPI.W  #$0011,D5
    BEQ     bcc3
    
    CMPI.W  #$0100,D5
    BEQ     bcc4
    
    CMPI.W  #$0101,D5
    BEQ     bcc5
    
    CMPI.W  #$0110,D5
    BEQ     bcc6
    
    CMPI.W  #$0111,D5
    BEQ     bcc7
    
    CMPI.W  #$1000,D5
    BEQ     bcc8
    
    CMPI.W  #$1001,D5
    BEQ     bcc9
    
    CMPI.W  #$1010,D5
    BEQ     bccA
    
    CMPI.W  #$1011,D5
    BEQ     bccB
    
    CMPI.W  #$1100,D5
    BEQ     bccC
    
    CMPI.W  #$1101,D5
    BEQ     bccD
    
    CMPI.W  #$1110,D5
    BEQ     bccE
    
    CMPI.W  #$1111,D5
    BEQ     bccF
    
    BRA     OPdata

bcc0
    ADD.L  #$00000000,D0
    RTS  
bcc1
    ADD.L  #$00000001,D0
    RTS 
bcc2
    ADD.L  #$00000002,D0
    RTS 
bcc3
    ADD.L  #$00000003,D0
    RTS 
bcc4
    ADD.L  #$00000004,D0
    RTS 
bcc5
    ADD.L  #$00000005,D0
    RTS 
bcc6
    ADD.L  #$00000006,D0
    RTS 
bcc7
    ADD.L  #$00000007,D0
    RTS 
bcc8
    ADD.L  #$00000008,D0
    RTS 
bcc9
    ADD.L  #$00000009,D0
    RTS 
bccA
    ADD.L  #$0000000A,D0
    RTS 
bccB
    ADD.L  #$0000000B,D0
    RTS 
bccC
    ADD.L  #$0000000C,D0
    RTS 
bccD
    ADD.L  #$0000000D,D0
    RTS 
bccE
    ADD.L  #$0000000E,D0
    RTS 
bccF
    ADD.L  #$0000000F,D0
    RTS     
* /$$$$$$$$  /$$$$$$        /$$      /$$                 /$$                    
*| $$_____/ /$$__  $$      | $$$    /$$$                | $$                    
*| $$      | $$  \ $$      | $$$$  /$$$$  /$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$$
*| $$$$$   | $$$$$$$$      | $$ $$/$$ $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$_____/
*| $$__/   | $$__  $$      | $$  $$$| $$| $$  \ $$| $$  | $$| $$$$$$$$|  $$$$$$ 
*| $$      | $$  | $$      | $$\  $ | $$| $$  | $$| $$  | $$| $$_____/ \____  $$
*| $$$$$$$$| $$  | $$      | $$ \/  | $$|  $$$$$$/|  $$$$$$$|  $$$$$$$ /$$$$$$$/
*|________/|__/  |__/      |__/     |__/ \______/  \_______/ \_______/|_______/                                                                                                                                                                                                                                                                                                   
                                                                     
* Branch to these methods after analyzing the MODE bits in D5
* Precondition: D5 contains 000
EAModeDataReg
    LEA         LetterD,A2      ; Print D
    JSR         addBuffer
    
    AND.L       #$00000111,D6
    
    CMPI.W      #$0000,D6       ; D0
    BEQ         write0
    
    CMPI.W      #$0001,D6       ; D1
    BEQ         write1
    
    CMPI.W      #$0010,D6       ; D2
    BEQ         write2
    
    CMPI.W      #$0011,D6       ; D3
    BEQ         write3
    
    CMPI.W      #$0100,D6       ; D4
    BEQ         write4
    
    CMPI.W      #$0101,D6       ; D5
    BEQ         write5
    
    CMPI.W      #$0110,D6       ; D6
    BEQ         write6
    
    CMPI.W      #$0111,D6       ; D7
    BEQ         write7
    
    * Invalid Xn bits
    BRA         OPdata
    
* Precondition: D5 contains 001 and OPCode supports the MODE
EAModeAddrReg
    LEA         LetterA,A2      ; Print A
    JSR         addBuffer
    
    AND.L       #$00000111,D6
    
    CMPI.W      #$0000,D6       ; A0
    BEQ         write0
    
    CMPI.W      #$0001,D6       ; A1
    BEQ         write1
    
    CMPI.W      #$0010,D6       ; A2
    BEQ         write2
    
    CMPI.W      #$0011,D6       ; A3
    BEQ         write3
    
    CMPI.W      #$0100,D6       ; A4
    BEQ         write4
    
    CMPI.W      #$0101,D6       ; A5
    BEQ         write5
    
    CMPI.W      #$0110,D6       ; A6
    BEQ         write6
    
    CMPI.W      #$0111,D6       ; A7
    BEQ         write7
    
    * Invalid Xn bits
    BRA         OPdata

* Helper function to print An only if
* size of operation is W or L
* Precondition: D0 contains the size bits #$01, #$11, or #$10
EAModeAddrRegWL
                    ; Only branch if W or L, else OPData
    CMPI.W      #$0001,D0       ; Check if byte
    BEQ         OPdata 
    BRA         EAModeAddrReg
    
* AR Indirect accesses the data at an Address Register
* Precondition: D5 contains 010 and OPCode supports the MODE 
EAModeARIndirect
    LEA         LeftParen,A2    ; Print (
    JSR         addBuffer
   
    JSR         EAModeAddrReg   ; Print An
    
    LEA         RightParen,A2   ; Print )
    JSR         addBuffer
    
    RTS

* print a + for increment    
EAModeIncrement
    JSR         EAModeARIndirect    ; Print (An)
    
    LEA         Plus,A2             ; Print +
    JSR         addBuffer
    RTS

* print a - for increment
EAModeDecrement
    LEA         Minus,A2        ; Print -
    JSR         addBuffer
    
    JSR         EAModeARIndirect      ; Print (An)
    
    RTS

* Precondition: D5 contains 111 and the function
* does not take immediates in EA portion
* D6 also contains the Xn bits
EAModeDirect
    CMPI.W      #$0000,D6
    BEQ         EAModeDirectWord
    
    CMPI.W      #$0001,D6
    BEQ         EAModeDirectLong
    
    BRA         OPdata

* Precondition: D5 contains 111 and the function
* can take a direct address W/L and immediate
* D6 also contains the Xn bits
EAModeDirectOrImm
    CMPI.W      #$0000,D6
    BEQ         EAModeDirectWord
    
    CMPI.W      #$0001,D6
    BEQ         EAModeDirectLong

    CMPI.W      #$0100,D6
    BEQ         EAModeImmediate
    
    BRA         OPdata

* Precondition: D5 contains 111 and D6 contains 000
* Fetches and prints the word after the OPCode
* Postcondition: D0 working directory is cleared
*                D5 contains the word in hex
* 
EAModeDirectWord
    JSR         getNextWord
    
    LEA         DollarSign,A2 ; Print $
    JSR         addBuffer
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.W       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    RTS
    
* Precondition: D5 contains 111 and D6 contains 001
* Fetches and prints the long after the OPCode
* Postcondition: D0 working directory is cleared
*                D5 contains the word in hex
EAModeDirectLong
    JSR         getNextLong
    
    LEA         DollarSign,A2 ; Print $
    JSR         addBuffer
    
    CLR         D0
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.L       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    RTS
    
* Outputs the immediate value addressing mode depending on
* the operations EA and size bits
* Precondition:  D5 contains 111 and D6 contains 100
*                Size #$01, #$11, or #$10 stored in D0
EAModeImmediate
    ; Branch depending on size bits
    
    LEA         NumberSign,A2 ; Print #
    JSR         addBuffer     
     
    CMPI.B      #$01,D0
    BEQ         EAModeImmediateByte   
    
    CMPI.B      #$11,D0
    BEQ         EAModeImmediateWord
    
    CMPI.B      #$10,D0
    BEQ         EAModeImmediateLong
    
    BRA         OPdata  

*********************************************************************************
* Method Name: EAModeImmediateByte
* Description: Prints out the next immediate byte in word form
*********************************************************************************     
EAModeImmediateByte
    LEA         DollarSign,A2
    JSR         addBuffer

    JSR         getNextWord
    
    ROR.B       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    ROL.B       #4,D5
    MOVE.B      D5,D0
    ANDI.B      #$0F,D0
    JSR         doEachHex
    
    RTS

*********************************************************************************
* Method Name: EAModeImmediateWord
* Description: Prints out the next immediate word in hex
*********************************************************************************   
EAModeImmediateWord   

    JSR         EAModeDirectWord
    
    RTS

*********************************************************************************
* Method Name: EAModeImmediateLong
* Description: Prints out the next immediate long in hex
*********************************************************************************   
EAModeImmediateLong  

    JSR         EAModeDirectLong
    
    RTS
    
*********************************************************************************
* Method Name: TrapTask13
* Description: Creates a file if none exists, and appends bytes to that file
*   while also echoing the written bytes to the screen.  You shouldn't need to
*   change this code.
*
* Calling Convention: Callee-Saved 
*
* Preconditions & Method Input:
*   A1 points to the null-terminated buffer to write (newline will be added for you)
*
* Postconditions & Output:
*   ALL files that were previously open will be CLOSED (FileIDs will be invalid)
*   See 'Output.txt' in directory for the results, also piped to the console
*
*
*  A2 holds a pointer to null terminated string to write (input)
*  A3 points to the null-terminated file name
*  D3 holds the number of bytes already in the file to write
*
*  D5 holds number of bytes to write
********************************************************************************
toSave REG D0-D5/A2-A3
TrapTask13:

    *******************************************************************
    * Method initialization, regsiter spilling, parameter saving, etc.
    *******************************************************************
    MOVEM.L toSave, -(SP)   ;  Callee-Saved, so save and restore     
      
    MOVEA.L A1, A2 ; save this buffer to write
    LEA outFilename, A3  ; save this for later, too
      
    move #50,d0   
    trap #15 ; close all files, suggested to begin any IO 
    *******************************************************************
    * End Method Init
    *******************************************************************

    ******************************************************************************************
    * Calculate the number of bytes to write by searching for the null in the target buffer A0
    ******************************************************************************************
    CLR.L D5 *D5 is now the number of bytes to write
nullLoop:
    MOVE.B (A1)+, D0
    CMPI.B #0,D0  * compare to null
    BEQ findNullLoopDone
    ADDI.W #1, D5
    BRA nullLoop
    
findNullLoopDone:
    MOVEA.L A3, A1 * reset A1 so it points to the file to write to (to open, next)
    
    ;check if file exists, and open with task 51 if so, otherwise 52
    ;(precondition here is A1 points to the null-terminated filename )
    MOVE.B #51, D0      ;open file (task 51 is existing, 52 is new)
    trap #15
      
    if.w D0 <NE> #0 then.s         ; if file error (404, not found)
        MOVE.B #52, D0             ; open new file (52 is new)
        trap #15
    endi
    
    ********************************************************************************************************* 
    * Seek to END of FILE by counting the number of bytes, closing, reopening, then seeking.
    *    (first, count number of bytes already in the file to obtain seek position)
    *********************************************************************************************************
    Clr.L D3   ;TODO: reg save, D3 is now our count of bytes read
    MOVE.L #1, D2 ; read one byte at a time
    LEA byteRead, A1
    
countLoop:
    MOVE.B #53, D0 ; try to read one byte (TODO: move out of loop)
    trap #15
    
    CMPI.W #1,D0  ;1 == EOF
    BEQ countDone
    ADDI #1, D3
    BRA countLoop
    
countDone:    
    * close this file
     move #56,d0  
     trap #15 
     
     * reopen the target file
     MOVE.L A3,A1
     MOVE #51, D0
     trap #15
     
    * seek to right position, then continue with writing
    MOVE.L D3, D2 ; move the number of bytes found in the file to D2
    MOVE #55, D0  ; position file task
    trap #15

    ******************************************************************************
    * Actually write the buffer to the file, after caculating the number of bytes 
    *  to write and after seeking to the right location in the file for append
    ******************************************************************************

    MOVE.L D5, D2 ; restore this for the actually writing the buffer 
    ; assumes A0 hasnt changed since handed to this method      
    MOVEA.L A2, A1 ; load the address of the buffer we want to write to disk
    ; assumes file ID is still stored in D1.L  
    MOVE.B #54, D0 ; subtask 54 is write to open file (append, or?), assumes D2 holds # of bytes
    trap #15

    ; add a newline to the file output
    
    LEA NEWLINE, A1
    MOVE.B #54, D0 
    MOVE.B #2,D2  ; kills # of bytes to write from input param
    trap #15      
    
    ; finally, close only this file
    MOVE.B #56, D0 ; close file task
    trap #15
  
    ; report to screen
    MOVEA.L A2, A1 ; load the address of the buffer we want to write to disk & screen
    MOVE.B #13, D0
    trap #15
    
    ; restore context
    MOVEM.L (SP)+, toSave
    
    RTS
    
* Required variables and constants go here for your Disassembler
CR                  EQU $0D
LF                  EQU $0A
NEWLINE             DC.B CR,LF,0  
MSG1                DC.B 'DATA'
MSG2                DC.B 'NOP',0
outFilename         DC.B 'Output.txt',0
byteRead            DS.B 1
config              DC.B 'Config.cfg',0
fileID              DS.L 1
AddressLength       EQU  8 
startingAddress     DS.B AddressLength
inbetweenAddress    DS.B 2
endingAddress       DS.B AddressLength

MESSAGE1 DC.B    'Config.cfg contains an odd address',CR,LF,0
MESSAGE2 DC.B    'Config.cfg contains an out of range address',CR,LF,0
MESSAGE3 DC.B    'Config.cfg has a starting address larger than the ending',CR,LF,0
MESSAGE4 DC.B    'Config.cfg was not found',CR,LF,0

DATA0               DC.B ' D0',0
DATA1               DC.B ' D1',0
DATA2               DC.B ' D2',0
DATA3               DC.B ' D3',0
DATA4               DC.B ' D4',0
DATA5               DC.B ' D5',0
DATA6               DC.B ' D6',0
DATA7               DC.B ' D7',0

ADDR0               DC.B ' A0',0
ADDR1               DC.B ' A1',0
ADDR2               DC.B ' A2',0
ADDR3               DC.B ' A3',0
ADDR4               DC.B ' A4',0
ADDR5               DC.B ' A5',0
ADDR6               DC.B ' A6',0
ADDR7               DC.B ' A7',0

ARI0                DC.B ' (A0)',0
ARI1                DC.B ' (A1)',0
ARI2                DC.B ' (A2)',0
ARI3                DC.B ' (A3)',0
ARI4                DC.B ' (A4)',0
ARI5                DC.B ' (A5)',0
ARI6                DC.B ' (A6)',0
ARI7                DC.B ' (A7)',0

ARIncr0             DC.B ' (A0)+',0
ARIncr1             DC.B ' (A1)+',0
ARIncr2             DC.B ' (A2)+',0
ARIncr3             DC.B ' (A3)+',0
ARIncr4             DC.B ' (A4)+',0
ARIncr5             DC.B ' (A5)+',0
ARIncr6             DC.B ' (A6)+',0
ARIncr7             DC.B ' (A7)+',0

ARDecr0             DC.B ' -(A0)',0
ARDecr1             DC.B ' -(A1)',0
ARDecr2             DC.B ' -(A2)',0
ARDecr3             DC.B ' -(A3)',0
ARDecr4             DC.B ' -(A4)',0
ARDecr5             DC.B ' -(A5)',0
ARDecr6             DC.B ' -(A6)',0
ARDecr7             DC.B ' -(A7)',0

DataArray           DS.W 100
Buffer         DS.W 100
null                DC.B 0

LetterA                   DC.B 'A'
LetterB                   DC.B 'B'
LetterC                   DC.B 'C'
LetterD                   DC.B 'D'
LetterE                   DC.B 'E'
LetterF                   DC.B 'F'
LetterG                   DC.B 'G'
LetterH                   DC.B 'H'
LetterI                   DC.B 'I'
LetterJ                   DC.B 'J'
LetterK                   DC.B 'K'
LetterL                   DC.B 'L'
LetterM                   DC.B 'M'
LetterN                   DC.B 'N'
LetterO                   DC.B 'O'
LetterP                   DC.B 'P'
LetterQ                   DC.B 'Q'
LetterR                   DC.B 'R'
LetterS                   DC.B 'S'
LetterT                   DC.B 'T'
LetterU                   DC.B 'U'
LetterV                   DC.B 'V'
LetterW                   DC.B 'W'
LetterX                   DC.B 'X'
LetterY                   DC.B 'Y'
LetterZ                   DC.B 'Z'
Number0                   DC.B '0'
Number1                   DC.B '1'
Number2                   DC.B '2'
Number3                   DC.B '3'
Number4                   DC.B '4'
Number5                   DC.B '5'
Number6                   DC.B '6'
Number7                   DC.B '7'
Number8                   DC.B '8'
Number9                   DC.B '9'
LeftParen                 DC.B '('
RightParen                DC.B ')'
Plus                      DC.B '+'
Minus                     DC.B '-'
NumberSign                DC.B '#'
DollarSign                DC.B '$'
Space                     DC.B ' '
Comma                     DC.B ','
Period                    DC.B '.'
Slash                     DC.B '/'

   END    START        ; last line of source

















































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
