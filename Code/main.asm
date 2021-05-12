LCD_E BIT P3.4
LCD_RS BIT P3.5   	

ORG 0000H
SJMP MAIN
ORG 0003H	        //Ngat ngoai 0, chan IN
SJMP ISR_EX0
ORG 0013H	        //Ngat ngoai 1, chan OUT
SJMP ISR_EX1

MAIN: 
MOV IE, #10000101B
SETB IT0	   // Cho phep ngat canh xuong
SETB IT1
MOV 20H, #0    // Dung 2 bit 20H.0 va 20H.1 lam bien trang thai cho IN va OUT

MOV R1, #0      // Bien dem so nguoi
ACALL INIT_LCD
MOV R2, #0      // Dem vi tri xuat
MOV DPTR, #BANG
DISPLAY:         MOV A, R2
		         MOVC A, @A+DPTR 
				 JZ XUAT
				 ACALL WRITETEXT
				 INC R2
				 JMP DISPLAY    
XUAT:   CJNE R1, #0, NHAY
        SETB P2.7
		JMP NHAY1
NHAY:	CLR P2.7
NHAY1:  MOV A, #0C6H		// Xuong ky tu 7 hang 2
        ACALL WRITECOM
        MOV A, R1
        MOV B, #100
		DIV AB

		ADD A, #30H
		ACALL WRITETEXT
		MOV A, #0C7H
        ACALL WRITECOM
		MOV A, B
		MOV B, #10
		DIV AB
		ADD A, #30H
		ACALL WRITETEXT
		MOV A, #0C8H
		ACALL WRITECOM
		MOV A, B
		ADD A, #30H
		ACALL WRITETEXT
SJMP XUAT
	
ISR_EX0:   //Ngat chan IN
JB 20H.1,TRU
SETB 20H.0
JMP KT0
TRU: DEC R1	   // Co nguoi buoc ra
CLR 20H.1 	 
CLR 20H.0
MOV 21H, R1
JNB 21H.7, KT0 // Neu R1 < 0 thi cho R1 = 0, khi reset nguoi dung van o trong phong nhung den se tat
MOV R1, #0 
KT0: CLR IE0
RETI

ISR_EX1:	  //Ngat chan OUT
JB 20H.0,CONG
SETB 20H.1
JMP KT1
CONG: INC R1	   // Co nguoi buoc vao
CLR 20H.1 	 
CLR 20H.0 
KT1: CLR IE1
RETI


	INIT_LCD:
		MOV	A, #38H
		ACALL	WRITECOM
		MOV	A, #0CH
		ACALL	WRITECOM
		MOV	A, #06H
		ACALL	WRITECOM
		RET
	CLEAR:
		MOV	A, #01H
		ACALL	WRITECOM		
		RET
	WRITECOM:
		SETB	LCD_E
		CLR		LCD_RS
		MOV	    P1,A
		CLR		LCD_E
		ACALL	WAIT_LCD
		RET
	WRITETEXT:
		SETB	LCD_E
		SETB	LCD_RS
		MOV	    P1,A
		CLR		LCD_E
		ACALL	WAIT_LCD
		RET
	
	WAIT_LCD: PUSH 6
	          PUSH 7	
		      MOV R6,#10
	DL1:	  MOV	R7, #250
		      DJNZ	R7, $
		      DJNZ	R6,DL1
		      POP 7
		      POP 6
		      RET
BANG: DB "SO NGUOI LA", 0
END