    ORG 00H
    JMP START
    ORG 13H                     ;INT1 中斷向量 以下程式碼放在13H
    JMP INT1INT
                                ;Start 在0016H
START:  MOV SP,#30H             ;設定堆疊指標之初值
        MOV IE,#10000100B       ;INT1 中斷致能 ;UART TIMER1 INT1 TIMER0: 00100
        CLR IT1                 ;設定中斷為低準位觸發
        MOV PSW,#00H            ;設定程式狀態字語之初值
        MOV A,#0FEH             ;共陽極，設定 LED 之初始狀態
        MOV P1,A                ;寫入 Port1
        JMP $                   ;原地跳躍
INT1INT: RL A                   ;累加器向左旋轉 
         MOV P1,A               ;寫入 Port1
Wait:   MOV R5,#10              ;將十進位資料 10 移入暫存器 R5
        CALL DELAY              ;呼叫 DELAY 副程式；延遲 200ms
        SETB P3.3               ;讀取接腳電壓前需先寫入高電壓以關閉 Pull down Transitor(電晶體)
        JNB P3.3,Wait           ;INT1 為 0 則跳至 Wait；繼續等待，解彈跳 JNB jump no bit (不等於1跳)
        RETI                    ; return I (和return 差別為會再次打開中斷遮罩)
;┌────────────────────────┐
;│ DELAY TIME= R5 * 20 ms |
;└────────────────────────┘
DELAY:  MOV R6,#40
DEL:    MOV R7,#248
        DJNZ R7,$
        DJNZ R6,DEL
        DJNZ R5,DELAY
        RET
        END

;中斷向量 :
;Timer0 -> 0BH
;INT1   -> 13H
;Timer1 -> 1BH 
;UART   -> 23H

;ISR : Interrupt Service Routine