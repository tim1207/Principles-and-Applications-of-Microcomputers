;1. Topic: Seven segment count from 0 to 99 with interval 1 second
;2. Crystal: 12MHz
;3. R0: Decrease by 1 every 50,000us（Use to indicate if it is 1 second now）
;4. R1: Record the counting value now（亦即紀錄將顯示於七段顯示器的秒數）.
;5. JP9（Port1）的 8 支接腳以杜邦線接至 JP4（提醒：有標註 JPX 者為第 0 腳）。
    
    ORG 00H
    JMP START
    ORG 0BH                 ;Timer0 --> 0BH 中斷向量進入點
    JMP TIMER0INT           ;跳躍至 Timer0 中斷服務程式
START:
    MOV SP,#30H             ;設定堆疊在資料記憶體空間之起始位置
    MOV IE,#10000010B       ;Timer0 中斷致能
    MOV TMOD,#00000001B     ;Timer0 工作於模式 1，亦即 16 位元計時器 TOMD:計時器的模式 前4給 Timer1 後4給 Timer0 ->mode 1=> 16-bit Timer
    MOV R0,#20              ;20x50,000us=1sec
    MOV R1,#00H             ;R1用來記錄目前秒數
    MOV P1,#00H
    MOV TH0,#>(65536-50000) ;取出(65536-50000)二進位表示法的 High Byte 
                            ;（15536)開始往上數 將15536轉為二進位制的 High Byte 填入
    MOV TL0,#<(65536-50000) ;取出(65536-50000)二進位表示法的 Low Byte
                            ;（15536)開始往上數 將15536轉為二進位制的 Low Byte 填入
    SETB TR0                ;計時開始
    JMP $                   ;原地跳躍（等待下一次 Timer0 的中斷）
TIMER0INT:
    DJNZ R0,NOT_1S          ;R0 減 1 後若不為 0 表示還未達 1 秒
    MOV R0,#20              ;R0 減 1 後為 0，表示已經 1 秒，須重設 R0
    MOV A,R1                ;將 R1 加 1；加法運算僅能透過 A 暫存器進行 R1格式為 BCD
    ADD A,#01H
    DA A                    ;It becomes 100 when R1 is 99.
                            ;The MSB, 1, of 100 will be stored in C,
                            ;i.e., the carry bit in PSW.
                            ;The carry can be discarded. Only the 00 will be
                            ;stored in the register R1.
    MOV R1,A                ;將調整後的 R1 值記錄下來
    SWAP A                  ;這個調整是配合硬體電路的設計（配合 JP4
                            ;調整；U2 是 MSB，U5 是 LSB）
    MOV P1,A                ;將新的秒數輸出至七段顯示器
NOT_1S:
    MOV TH0,#>(65536-50000) ;取出(65536-50000)二進位表示法的 High Byte
    MOV TL0,#<(65536-50000) ;取出(65536-50000)二進位表示法的 Low Byte
    RETI                    ;中斷返回
    END 