		ORG 00H
		JMP Start
		
Start: 	MOV SP,#30H  			;將堆疊指標初值置於位元定址區之上。
		MOV IE,#00000000B 		;禁止所有中斷
		MOV PSW,#00000000B		;選擇使用 Register Bank 0。
		MOV SCON,#01000000B 	;串列通訊模式 1，8-Bit UART, Baud Rate 可變。 
								;SCON: Serial Communication Control Register
								; 		SM0  SM1  SM2  REN  TB8  RB8  TI  RI
								; MODE0  0    0	   致   致		同		傳  接
								; MODE1  0    1    能   能		位		送  收
								; MODE2  1    0   	    接		位		完  完
								; MODE3  1    1			收		元		成  成

		MOV TMOD,#00100000B		;TIMER1 8-Bit Auto-Reload（模式 2）。
		ORL PCON,#10000000B 	;將 SMOD（i.e., PCON.7）設為 1＝>雙倍鮑率。
								;PCON: Power Control Register
		MOV TH1,#0F3H 			;Baud Rate=4800bps。  2/32  * 12*10^6 / 12*(256-F3H) = 4807.69
		SETB TR1 				;TIMER1 開始計時。

		
Again: 	MOV R0,#26
		MOV R1,#00
		MOV DPTR,#Table
		
Loop:   MOV A,R1			; A<=0;
		INC R1				;increase by one 
		MOVC A,@A+DPTR 		;使用查表法。 =>去程式記憶體
		MOV SBUF,A 			;將待傳送資料丟至傳送緩衝區。  SBUF ＝ Serial Communication Buffer
		JNB TI,$ 			;串列傳送完畢時 TI 旗標會被設定為 1。
		CLR TI 				;TI 旗標必須手動清除。
		MOV R5,#10 			;CALL Delay
		CALL Delay
		DJNZ R0,Loop		;減一不等於一
		MOV R5,#200
		CALL Delay
		JMP Again
;┌────────────────────────┐
;│ DELAY TIME= R5 * 20 ms │
;└────────────────────────┘
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

; 串列通訊模式說明:
; Mode 0:Baud Rate 固定，傳送 8 位元
; Mode 1:Baud Rate 可調，傳送 8 位元
; Mode 2:Baud Rate 固定，傳送 9 位元;第 9 位元存放於 SCON 之 TB8 或 RB8 Mode 3:Baud Rate 可調，傳送 9 位元;第 9 位元存放於 SCON 之 TB8 或 RB8
; MOde 3:Baud Rate 可調，傳送 9 位元
; 綜合上述，一般使用 Mode 1(鮑率可調)較為適當!

; Timer1:
; Mode 0: 13 bit Timer
; Mode 1:16 bit Timer
; Mode 2:8 bit auto-reload Timer
; Mode 3:Dual 8 bit Timer


; Mode 1 鮑率(Baud Rate)計算
; 震盪器頻率 = fosc
; 1機械週期 = Tosc
; 雙倍鮑率控制位元=SMOD
; 當 MCS-51 工作於串列通訊模式 1 時，其 Baud Rate 由 Timer1 所控制。此時 Timer1 必須工作於 Mode2(亦即 8-bit Auto Reload)
; BaudRate = (2^SMOD / 32)   * (Timer1的溢位率)
		;  = (2 ^SMOD / 32) * 1/ (機械週期*[256-(TH1)])   
		;  = (2 ^SMOD / 32)  * 1/  (12 Tosc  * [256-(TH1)] )
		;  = (2 ^SMOD / 32)  * fosc /  (12  * [256-(TH1)] )

;換言之，若已選定 Baud Rate，則 TH1 之設定值如下:
; TH1 = 256 - 2 ^SMOD / 32  * 震盪器頻率 / (384*鮑率)