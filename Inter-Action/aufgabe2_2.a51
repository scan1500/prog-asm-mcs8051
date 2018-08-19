ORG 0

MOV R3, #01H // Taster 1 offen
MOV R4, #02H // Taster 2 offen

// Taster aktivieren
MOV A, #0FFH
MOV P1, A

// Schleife solange bis Taster 1 gedrückt
TASTER1_GEDRUECKT:
	MOV A, P1 // Einlesen 0=gedrückt 1=offen
	ANL A, R3 // Überprüfen ob Taster 1 gedrückt
JNZ TASTER1_GEDRUECKT

// Erstes Licht laden
MOV R5, #1
MOV P3, #0

//Links-Rechts-Lauf Lichter
SHIFT_LEFT:
	
	MOV R1, #100
	MOV R2, #180

	MOV P3, R5
	MOV A, R5
	RL A
	MOV R5, A
	
	WAIT_OUT_LEFT:
		WAIT_IN_LEFT:
		NOP
		NOP
		NOP
		DJNZ R1, WAIT_IN_LEFT 
	DJNZ R2, WAIT_OUT_LEFT

MOV A, P1 // Einlesen 0=gedrückt 1=offen
ANL A, R3 // Überprüfen ob Taster 1 gedrückt
JNZ TASTER1_GEDRUECKT

CJNE R5, #10000000B, SHIFT_LEFT


SHIFT_RIGHT:

	MOV R1, #100
	MOV R2, #180


	MOV P3, R5
	MOV A,R5
	RR A
	MOV R5,A

	WAIT_OUT_RIGHT:
		WAIT_IN_RIGHT:
		NOP
		NOP
		NOP
		DJNZ R1, WAIT_IN_RIGHT 
	DJNZ R2, WAIT_OUT_RIGHT

MOV A, P1 // Einlesen 0=gedrückt 1=offen
ANL A, R4 // Überprüfen ob Taster 2 gedrückt
JZ SHIFT_RIGHT

CJNE R5, #00000001B, SHIFT_RIGHT

SJMP TASTER1_GEDRUECKT



END