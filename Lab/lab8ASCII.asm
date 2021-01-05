; MCS-51 進階實驗
; 實驗名稱:RS232C 接收程式(PC 端 --> 8051 單板端)
; 日期:2014/12/24
; 說明:
; 1. 本程式將 PC 端所按下鍵盤之 ASCII Code 傳送至單板端(例如 A-65，B-66，C-67，a-97，b-98，c-99...) 2. 使用鮑率(Baud Rate)4800bps
; 3. 程式使用輪詢法(未使用 UART 中斷;All interrupt disabled)
; 4. 測試時，請先執行單板模組端之程式，之後請回到 PC 端進入 Command Mode 再執行 Txd.EXE。
; 此時所按下之按鍵 ASCII 碼將傳送給單板並顯示於七段顯示器。
; 5. 請使用 8 對 8 杜邦線連接單板之 PORT 1 接腳(JP9)以及七段顯示器輸入接腳(JP4)
; ; 6. ASCII 碼的範圍係由 0 至 255(亦即 8 位元)。因七段顯示器僅兩位數，故接收到 PC 端所傳送之
; ASCII 碼後會放棄百位數，僅顯示十位與個位數。 作業:將本程式之輪詢法(Polling)改為使用 UART 中斷以接收由 PC 端傳送至單板端之資料

    ORG 00H
    JMP Start
Start:    
    MOV SP,#30H;將堆疊指標初值置於位元定址區之上。 
    MOV IE,#00000000B ;禁止所有中斷。
    MOV PSW,#00000000B ;選擇使用 Register Bank 0。
    MOV SCON,#01000000B ;串列通訊模式 1，8-Bit UART, Baud Rate 可變。 
    MOV TMOD,#00100000B ;TIMER1 8-Bit Auto-Reload(模式 2)。
    ORL PCON,#10000000B ;將 SMOD(i.e., PCON.7)設為 1=>雙倍鮑率。    
    MOV TH1,#0F3H;Baud Rate=4800bps。
    SETB REN ;啟動串列通訊接收(若無此一指令則無法啟動接收) 
    SETB TR1 ;TIMER1 開始計時。
    MOV P1,#00H;七段顯示器初始化之後顯示 0
    



NEXT:JNB RI,$ ;串列接收完畢時 RI 旗標會被設定為 1。
    CLR RI  ;RI 旗標必須手動清除。
    MOV A,SBUF 
    MOV B,#100  ;取出十位數與個位數(亦即餘數，存在 B 暫存器)，百位數(亦即商)丟棄!
    DIV AB ;A 除以 B，其結果之商放在 A，餘數放在 B 暫存器
    MOV A,B 
    MOV B,#10 ;將餘數繼續除以十
    DIV AB ;將餘數繼續除以十
    PUSH A ;將 A 推入堆疊中
    MOV A,B ;準備將餘數之內容向左移動 4 位元
    RL A
    RL A 
    RL A 
    RL A 
    MOV R0,A ;將左移四位元後之餘數暫存於 R0 暫存器
    POP A ;將「商數」由堆疊取出後放置於 A 暫存器
    ORL A,R0 ;將餘數與商整合在 A 暫存器中(其中高 4 位元是餘數，低 4 位元是商;原希望商在高 4 位元，餘數在低 4 位元，但因硬體電路的設計問題而只得採用相反之規劃)
    MOV P1,A ;將 ASCII 碼輸出顯示於七段顯示器
    JMP NEXT ;等待並接收下一筆串列通訊資料
    END