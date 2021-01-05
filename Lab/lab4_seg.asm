	ORG 00H
	JMP START
	ORG 0BH ;Timer0 中斷向量進入點
	JMP TIMER0INT ;跳躍至 Timer0 中斷服務程式
START:
	MOV SP,#30H ;設定堆疊在資料記憶體空間之起始位置
	MOV IE,#10000010B ;Timer0 中斷致能
	MOV TMOD,#00000001B ;Timer0 工作於模式 1，亦即 16 位元計時器
	MOV R0,#20 ;20x50,000us=1sec
	MOV R1,#00H
	MOV P1,#00H
	MOV TH0,#>(65536-50000) ;取出(65536-50000)二進位表示法的 High Byte
	MOV TL0,#<(65536-50000) ;取出(65536-50000)二進位表示法的 Low Byte
	SETB TR0 ;計時開始
	JMP $ ;原地跳躍（等待下一次 Timer0 的中斷）
TIMER0INT:
	DJNZ R0,NOT_1S ;R0 減 1 後若不為 0 表示還未達 1 秒
	MOV R0,#20 ;R0 減 1 後為 0，表示已經 1 秒，須重設 R0
	MOV A,R1 ;將 R1 加 1；加法運算僅能透過 A 暫存器進行
	ADD A,#01H
	DA A 		;It becomes 100 when R1 is 99.
				;The MSB, 1, of 100 will be stored in C,
				;i.e., the carry bit in PSW.
				;The carry can be discarded. Only the 00 will be
				;stored in the register R1.
	CJNE A,#50H,CON ;不等於50跳到 CON
	MOV	A,#00H

CON:
	MOV R1,A ;將調整後的 R1 值記錄下來
	SWAP A ;這個調整是配合硬體電路的設計（配合 JP4
			;調整；U2 是 MSB，U5 是 LSB）
	MOV P1,A ;將新的秒數輸出至七段顯示器
NOT_1S:
	MOV TH0,#>(65536-50000) ;取出(65536-50000)二進位表示法的 High Byte
	MOV TL0,#<(65536-50000) ;取出(65536-50000)二進位表示法的 Low Byte
	RETI ;中斷返回
	END




	CJNE A,#50H,CON ;不等於50跳到 CON
	MOV	A,#00H
