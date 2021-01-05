		ORG 00H
		JMP Start
		
Start: 	MOV SP,#30H ;將堆疊指標初值置於位元定址區之上。
		MOV IE,#00000000B ;禁止所有中斷。
		MOV PSW,#00000000B ;選擇使用 Register Bank 0。
		MOV SCON,#01000000B ;串列通訊模式 1，8-Bit UART, Baud Rate 可變。
		MOV TMOD,#00100000B ;TIMER1 8-Bit Auto-Reload（模式 2）。
		ORL PCON,#10000000B ;將 SMOD（i.e., PCON.7）設為 1＝>雙倍鮑率。
		MOV TH1,#0F3H ;Baud Rate=4800bps。
		SETB TR1 ;TIMER1 開始計時。
		
Again: 	MOV R0,#26
		MOV R1,#00
		MOV DPTR,#Table
		
Loop: 	MOV A,R1
		INC R1
		MOVC A,@A+DPTR ;使用查表法。
		MOV SBUF,A ;將待傳送資料丟至傳送緩衝區。
		JNB TI,$ ;串列傳送完畢時 TI 旗標會被設定為 1。
		CLR TI ;TI 旗標必須手動清除。
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
		
Table:	DB 65,66,67,68,69,70,71,72 ;儲存 A 至 Z
		DB 73,74,75,76,77,78,79,80
		DB 81,82,83,84,85,86,87,88
		DB 89,90
		END
