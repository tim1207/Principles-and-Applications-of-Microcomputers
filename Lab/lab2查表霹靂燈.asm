;-------------------------------------;
;				 查表霹靂燈lab1	        ;
;-------------------------------------;
        ORG     00h
        JMP     START
START:  MOV     SP,#30h		
        MOV     IE,#00H
        MOV     PSW,#00H
	MOV	DPTR,#TABLE	
	MOV	R0,#00H	
NEXT:	MOV	A,R0	
	MOVC	A,@A+DPTR
	MOV	P1,A
	MOV	R5,#100
	CALL	DELAY
	INC	R0
	CJNE	R0,#14,NEXT
	MOV	R0,#00H
       	JMP	NEXT
;┌─────────────┐
;│ 時間延遲副程式 │
;│ Delay Time = R5 * 20 ms |
;└─────────────┘
DELAY:  MOV     R6,#40
DEL:    MOV     R7,#248
        DJNZ    R7,$
        DJNZ    R6,DEL
        DJNZ    R5,DELAY
        RET
;不加ORG 由組譯器提供
TABLE:	DB	07FH,0BFH,0DFH,0EFH,0F7H,0FBH,0FDH
		;01111111B,
		;10111111B,11011111
		DB	0FEH,0FDH,0FBH,0F7H,0EFH,0DFH,0BFH
	END
