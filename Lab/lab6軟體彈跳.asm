		ORG 00H
		JMP Start
		
Start: 	MOV SP,#30H ;�N���|���Ъ�ȸm��줸�w�}�Ϥ��W�C
		MOV IE,#00000000B ;�T��Ҧ����_�C
		MOV PSW,#00000000B ;��ܨϥ� Register Bank 0�C
		MOV SCON,#01000000B ;��C�q�T�Ҧ� 1�A8-Bit UART, Baud Rate �i�ܡC
		MOV TMOD,#00100000B ;TIMER1 8-Bit Auto-Reload�]�Ҧ� 2�^�C
		ORL PCON,#10000000B ;�N SMOD�]i.e., PCON.7�^�]�� 1��>�����j�v�C
		MOV TH1,#0F3H ;Baud Rate=4800bps�C
		SETB TR1 ;TIMER1 �}�l�p�ɡC
		
Again: 	MOV R0,#26
		MOV R1,#00
		MOV DPTR,#Table
		
Loop: 	MOV A,R1
		INC R1
		MOVC A,@A+DPTR ;�ϥάd��k�C
		MOV SBUF,A ;�N�ݶǰe��ƥ�ܶǰe�w�İϡC
		JNB TI,$ ;��C�ǰe������ TI �X�з|�Q�]�w�� 1�C
		CLR TI ;TI �X�Х�����ʲM���C
		MOV R5,#10 ;CALL Delay
		CALL Delay
		DJNZ R0,Loop
		MOV R5,#200
		CALL Delay
		JMP Again

Delay: 	MOV R6,#40
Del: 	MOV R7,#248
		DJNZ R7,$
		DJNZ R6,Del
		DJNZ R5,Delay
		RET
		
Table:	DB 65,66,67,68,69,70,71,72 ;�x�s A �� Z
		DB 73,74,75,76,77,78,79,80
		DB 81,82,83,84,85,86,87,88
		DB 89,90
		END
