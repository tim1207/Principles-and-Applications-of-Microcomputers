        ORG     00H
        JMP     START
		ORG		13H
		JMP		INT1INT
START:  MOV     SP,#30H	
        MOV     IE,#10000100B
		CLR 	IT1
        MOV     PSW,#00H
		MOV		A,#0FEH
		MOV		P1,A
		JMP		$
INT1INT: 	RL		A
		MOV		P1,A
WAIT: 	MOV 	R5,#10
		CALL	DELAY
		SETB	P3.3
		JNB		P3.3,WAIT
		RETI
DELAY:  MOV     R6,#40
DEL:    MOV     R7,#248
        DJNZ    R7,$
        DJNZ    R6,DEL
        DJNZ    R5,DELAY
        RET
		END
