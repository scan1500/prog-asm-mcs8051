ORG 0000H
	LJMP MAIN
	ORG 0030H
MAIN:

;--------------------------INIT-----------------------------------

	
	MOV DPTR, #3000H

	MOV A, #00001110B 
	MOVX @DPTR, A


	MOV A, #38H
	MOVX @DPTR, A
	ACALL DELAY


	MOV A, #00000001B
	MOVX @DPTR, A
	ACALL DELAY

;--------------------------DATA-----------------------------------

	MOV DPTR, #3001H

	MOV A, #01001000B
	MOVX @DPTR, A
	ACALL DELAY2


	MOV R5, #25H


test2:	
	MOV A, #01001000B
	MOVX @DPTR, A
	ACALL DELAY2
	DJNZ R5, test2





	ACALL DELAY2


	MOV DPTR, #3000H

	MOV A, #0001000B
	MOVX @DPTR, A
		

DELAY:
	MOV R2, #10
del2: MOV R1, #250
del1: DJNZ R1, del1
	DJNZ R2, del2
	RET


DELAY2:
	MOV R3, #1
del31: MOV R2, #0FFH
del21: MOV R1, #0FFH
del11: DJNZ R1, del11
	DJNZ R2, del21
	DJNZ R3, del31
	RET

	END