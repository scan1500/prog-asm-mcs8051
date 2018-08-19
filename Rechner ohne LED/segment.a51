;R0 -> Speichert die Zahl, die aktuell eingeben wird -> Ausgabe auf rechter 7-Seg-Anzeige
;R1 -> Speichert die Zahl aus R0 in R1 wenn R0 bereits belegt ist und gibt diese auf der linken Anzeige aus
;R2 -> Zwischenspeicher für R0
;R3 -> Zwischenspeicher für R1
;R5 -> Register für "="
;R6 -> Register für Warteschleife
;R7 -> Speichert den Operator ab
;B (R8) -> Vorladen mit Wert 10 für Mult. / Verw. für Rest bei Divisionen

;TABLE: #00111111B, #00000110B, #01011011B, #01001111B, #01100110B, #01101101B, #01111101B, #00000111B, #01111111B, #01100111B
			
;  7 Segment format
;----------------------
;  0 -> 00111111
;  1 -> 00000110
;  2 -> 01011011
;  3 -> 01001111
;  4 -> 01100110
;  5 -> 01101101
;  6 -> 01111101
;  7 -> 00000111
;  8 -> 01111111
;  9 -> 01100111
/*
;Initialisierung des LCD HD44780
LJMP INIT_LCD

ORG 920H

INIT_LCD:

	MOV A, #00111100B ;Interface 8 Bit, Einzeilig, 5x8
	ACALL COMMAND
	MOV A, #00000001B ;Löscht Display, Cursor an 0
	ACALL COMMAND
	MOV A, #00000110B ;Autoinkrement
	ACALL COMMAND
	MOV A, #00001111B ;Display ein, Cursor ein, Blinken
	ACALL COMMAND

	MOV A, #'T'
	ACALL DATA_DISPLAY
	MOV A, #'E
	ACALL DATA_DISPLAY
	MOV A, #'S'
	ACALL DATA_DISPLAY
	MOV A, #'T'
	ACALL DATA_DISPLAY

ORG 960H

COMMAND:
	ACALL READY 	;Prüfen ob LCD bereit ist
	MOV P1, A	
	CLR P2.0		;RS=0 für Befehl
	CLR P2.1		;RW=0 zum schreiben
	SETB P2.2		;E=1 H-to-L
	CLR P2.2		;E=0, Latch in
RET

DATA_DISPLAY:
	ACALL READY		;Prüfen ob LCD bereit ist
	MOV P1, A
	SETB P2.0		;RS=1 für Daten
	CLR P2.1		;RW=0 zum schreiben
	SETB P2.2		;E=1 H-to-L
	CLR P2.2		;E=0, Latch in
RET

READY:
	SETB P1.7		;Busy Flag setzen
	CLR P2.0		;RS=0 für Befehl
	SETB P2.1		;RW=1 zum schreiben
	BACK:			;Schleife läuft bis Busy Flag nicht mehr gesetzt
		SETB P2.2	;E=1 H-to-L
		CLR P2.2	;E=0, Latch in
		JB P1.7, BACK
RET
*/

ORG 0
LJMP MAIN
  
ORG 23H
LJMP SERINT

ORG 100H
SERINT:

	CJNE R0, #255, INIT_NEXT_INPUT ;Wenn bereits ein Wert in R0 (Wert != 255) steht, springe an INIT_NEXT_INPUT
	JMP READSBUF_DIGIT
	
	INIT_NEXT_INPUT: ;Hier wird der Wert von R0 in R1 zwischengespeichert und auf die nächste Eingabe gewartet
	MOV A, R0
	MOV R1, A
	MOV R0, #255 ;R0 zurücksetzen, Wert ist jetzt in R1 gespeichert
	
	READSBUF_DIGIT:
	MOV A, SBUF ;Tastatureingabe von SBUF IN AKKU laden
	ANL A, #01111111B ;Forderste 1 (Parity Bit) wegfiltern, um ASCII Wert zu erhalten
	CLR RI 

MOV R0, A ;Speichere die Eingabe in R0, egal welcher Wert...
	
	 OUT_0:
     CJNE R0, #'0', OUT_1
	 MOV R0, #0
     MOV P1, #00111111B
     RETI
     
     OUT_1:
     CJNE R0, #'1', OUT_2
	 MOV R0, #1
     MOV P1, #00000110B
     RETI
     
     OUT_2:
     CJNE R0, #'2', OUT_3
	 MOV R0, #2
     MOV P1, #01011011B
     RETI
     
     OUT_3:
     CJNE R0, #'3', OUT_4
	 MOV R0, #3
     MOV P1, #01001111B
     RETI
     
     OUT_4:
     CJNE R0, #'4', OUT_5
	 MOV R0, #4
     MOV P1, #01100110B
     RETI
     
     OUT_5:
     CJNE R0, #'5', OUT_6
	 MOV R0, #5
     MOV P1, #01101101B
     RETI
     
     OUT_6:
     CJNE R0, #'6', OUT_7
	 MOV R0, #6
     MOV P1, #01111101B
     RETI
     
     OUT_7:
     CJNE R0, #'7', OUT_8
	 MOV R0, #7
     MOV P1, #00000111B
     RETI
     
     OUT_8:
     CJNE R0, #'8', OUT_9
	 MOV R0, #8
     MOV P1, #01111111B
     RETI
     
     OUT_9:
     CJNE R0, #'9', NO_DIGIT
	 MOV R0, #9
     MOV P1, #01100111B
	 RETI

NO_DIGIT:	
MOV R0, #255 ;R0 zurücksetzen
RETI

;--------------------------------- MAIN -----------------------------------
MAIN:

MOV R0, #255
MOV R1, #255
MOV R2, #255
MOV R3, #255
MOV R4, #0
MOV R5, #0
MOV R6, #0
MOV R7, #0

MOV TMOD, #20H ;Timer 1 Modus 2
MOV TH1, #230 ;1200 bps
MOV SCON, #01010000B ;UART 8 Bit, 1 Stopbit
SETB TR1 ;Empfang an Timer 1 starten
MOV P1,#0 ; 7-Segment ausschalten

ENABLE_INT:
MOV IE, #10010000B ;Serieller Interrupt aktiviert

	PRUEF_R1_BELEGT:
		CJNE R1,#255, PRUEF_R0_BELEGT
	SJMP PRUEF_R1_BELEGT

	PRUEF_R0_BELEGT:
		CJNE R0, #255, DISABLE_INT
	SJMP PRUEF_R0_BELEGT

DISABLE_INT:
MOV IE,#00000000B

DO_MULTIPLEX:

	LCALL LEFT_MULT
	LCALL DELAY ;WAIT 1ms
	LCALL RIGHT_MULT	
	LCALL DELAY ;WAIT 1ms

	CJNE R2, #255, GO_EQUALS_POLLING	;R2 und/oder R3 sind nach Drücken einer Operation belegt (save_values) 
	CJNE R3, #255, GO_EQUALS_POLLING	;daher überspringe das Operation-Polling
	LCALL OPERATION_POLLING 			;Überprüfen, ob eine Operation ausgewählt wurde
	CJNE R7, #0, ENABLE_INT 			;Wenn ein Operator ausgewählt wurde dann springe zu ENABLE_INT -> Neue Zahl einlesen...
	
SJMP DO_MULTIPLEX

	GO_EQUALS_POLLING:
		LCALL EQUALS_POLLING
	JMP DO_MULTIPLEX

;Subroutine(1ms delay)
ORG 300H
DELAY:
		MOV R6, #230
		LOOP_WAIT:
			NOP
			NOP
		DJNZ R6, LOOP_WAIT
RET

ORG 400H
OPERATION_POLLING:

	CJNE R7, #0, RETURN
	JMP READSBUF_OP

	RETURN:
	RET
	 
	READSBUF_OP:
	JNB RI, NO_OPCODE ;Falls RI nicht gsetzt, sprich Stopbit noch nicht angekommen, springe zu NO_OPCODE
	MOV A, SBUF ;Tastatureingabe von SBUF IN AKKU laden
	ANL A, #01111111B ;Forderste 1 (Parity Bit) wegfiltern, um ASCII Wert zu erhalten
	CLR RI

MOV R7, A ;Speichere die Eingabe in R7, egal welcher Wert...
	
	 PLUS:
     CJNE R7, #'+', MINUS
	 SJMP SAVE_VALUES
     RET
     
     MINUS:
     CJNE R7, #'-', MULT
	 SJMP SAVE_VALUES
     RET
     
     MULT:
     CJNE R7, #'*', DIVIDE
	 SJMP SAVE_VALUES
     RET
     
     DIVIDE:
     CJNE R7, #'/', NO_OPCODE
	 SJMP SAVE_VALUES
     RET
	 
NO_OPCODE:	
MOV R7, #0  ;R7 zurücksetzen
RET
	 
SAVE_VALUES: 
MOV A, R0 ;Wert von R0 in R2 zwischenspeichern
MOV R2, A
MOV R0, #255
	
MOV A, R1 ;Wert von R1 in R3 zwischenspeichern
MOV R3, A
MOV R1, #255

MOV P1, #0
RET
	 
ORG 600H
EQUALS_POLLING:
	 
	CJNE R5, #0, RETURN_EQ
	JMP READSBUF_EQ
	
	RETURN_EQ:
	RET
	 
	READSBUF_EQ:
	MOV A, SBUF ;Tastatureingabe von SBUF IN AKKU laden
	ANL A, #01111111B ;Forderste 1 (Parity Bit) wegfiltern, um ASCII Wert zu erhalten
	CLR RI


	MOV R5, A ;Speichere die Eingabe in R5, egal welcher Wert...
	 
	CJNE R5, #'=', NO_CALC
	JMP CALC
	 
	 NO_CALC:
	 MOV R5, #0
	 RET
	 
	 CALC:
	 MOV B, #10
	 
	 CALC_ADD:
	 CJNE R7, #'+', CALC_SUB
		
		MOV A, R1
		MUL AB
		ADD A, R0
		
		MOV R0, A
		
		MOV A, R3
		MOV B, #10
		MUL AB
		ADD A, R2
		
		ADD A, R0
		
		MOV B, #10
		DIV AB 		;A -> Dezimalstelle, B-> Einerstelle
		MOV R0, B
		MOV R1, A
		MOV R2, #255
		MOV R3, #255
		MOV R5, #0
		MOV R7, #0
	
	 RET
	 
	 CALC_SUB:
	 CJNE R7, #'-', CALC_MUL
		
		MOV A, R1
		MUL AB
		ADD A, R0
		
		MOV R0, A
		
		MOV A, R3
		MOV B, #10
		MUL AB
		ADD A, R2
		
		;CLR C ;Setzte Carry Bit in jeden Fall auf 0 vor Rechnung ????
		SUBB A, R0
		MOV B, #10
		
		DIV AB 		;A -> Dezimalstelle, B-> Einerstelle
		MOV R0, B
		MOV R1, A
		MOV R2, #255
		MOV R3, #255
		MOV R5, #0
		MOV R7, #0
	
	 RET
	 
	 CALC_MUL:
	 CJNE R7, #'*', CALC_DIV
		
		MOV A, R1
		MUL AB
		MOV B, #10
		ADD A, R0
		
		MOV R0, A
		
		MOV A, R3
		MUL AB
		MOV B, #10
		ADD A, R2
		
		MOV B, R0
		MUL AB
		MOV B, #10
		
		DIV AB 		;A -> Dezimalstelle, B-> Einerstelle
		MOV R0, B
		MOV R1, A
		MOV R2, #255
		MOV R3, #255
		MOV R5, #0
		MOV R7, #0
	 
	 RET
	 
	 CALC_DIV:
		
		MOV A, R1
		MUL AB
		ADD A, R0
		
		MOV R0, A
		
		MOV A, R3
		MOV B, #10
		MUL AB
		ADD A, R2
		MOV B, R0
		DIV AB
		
		MOV B, #10
		
		DIV AB 		;A -> Dezimalstelle, B-> Einerstelle
		MOV R0, B
		MOV R1, A
		MOV R2, #255
		MOV R3, #255
		MOV R5, #0
		MOV R7, #0
		
	 RET

;Linke und Rechte 7Seg-Ausgabe als Unterprogramme
;R0 und R1 umwandeln:
ORG 800H
LEFT_MULT:

     CJNE R1, #0, SEG_LEFT_1
     MOV P1, #10111111B
     RET
     
     SEG_LEFT_1:
     CJNE R1, #1, SEG_LEFT_2
     MOV P1, #10000110B
     RET
     
     SEG_LEFT_2:
     CJNE R1, #2, SEG_LEFT_3
     MOV P1, #11011011B
     RET
    
     SEG_LEFT_3:
     CJNE R1, #3, SEG_LEFT_4
     MOV P1, #11001111B
     RET
     
     SEG_LEFT_4:
     CJNE R1, #4, SEG_LEFT_5
     MOV P1, #11100110B
     RET
     
     SEG_LEFT_5:
     CJNE R1, #5, SEG_LEFT_6
     MOV P1, #11101101B
     RET
     
     SEG_LEFT_6:
     CJNE R1, #6, SEG_LEFT_7
     MOV P1, #11111101B
     RET
     
     SEG_LEFT_7:
     CJNE R1, #7, SEG_LEFT_8
     MOV P1, #10000111B
     RET
     
     SEG_LEFT_8:
     CJNE R1, #8, SEG_LEFT_9
     MOV P1, #11111111B
     RET
     
     SEG_LEFT_9:
	 CJNE R1, #9, SEG_LEFT_END
     MOV P1, #11100111B
	 RET

SEG_LEFT_END:
RET

ORG 900H
RIGHT_MULT:

     CJNE R0, #0, SEG_RIGHT_1
     MOV P1, #00111111B
     RET
     
     SEG_RIGHT_1:
     CJNE R0, #1, SEG_RIGHT_2
     MOV P1, #00000110B
     RET
     
     SEG_RIGHT_2:
     CJNE R0, #2, SEG_RIGHT_3
     MOV P1, #01011011B
     RET
    
     SEG_RIGHT_3:
     CJNE R0, #3, SEG_RIGHT_4
     MOV P1, #01001111B
     RET
     
     SEG_RIGHT_4:
     CJNE R0, #4, SEG_RIGHT_5
     MOV P1, #01100110B
     RET
     
     SEG_RIGHT_5:
     CJNE R0, #5, SEG_RIGHT_6
     MOV P1, #01101101B
     RET
     
     SEG_RIGHT_6:
     CJNE R0, #6, SEG_RIGHT_7
     MOV P1, #01111101B
     RET
     
     SEG_RIGHT_7:
     CJNE R0, #7, SEG_RIGHT_8
     MOV P1, #00000111B
     RET
     
     SEG_RIGHT_8:
     CJNE R0, #8, SEG_RIGHT_9
     MOV P1, #01111111B
     RET
     
     SEG_RIGHT_9:
	 CJNE R0, #9, SEG_RIGHT_END
     MOV P1, #01100111B
	 RET
	 
SEG_RIGHT_END:
RET

END