; MCS-51 基礎實驗
; 實驗名稱：2 x 2 鍵盤掃瞄：（方式：使用軟體解彈跳）
; 日期：2014/12/10 程式設計：高立人
; 說明：
; 1. R0：只使用最低 2 位元，用以紀錄鍵盤編碼
; 2. 按鍵顯示結果（0~3）顯示於七段顯示器（需 4 位元控制七段顯示器）
; 3. 因 PORT 0、PORT 2 已作為 Address Bus，PORT 3 另有他用，因此僅 PORT 1 可使用。而 PORT
; 1 尚需預留 4 支腳位控制七段顯示器（低 4 位元），因此取捨之下，僅有 4 支腳位可以用於鍵
; 盤掃瞄（高 4 位元）。
; 4. 原擬掃瞄 X1、X2，但配合接（跳）線方便，改採掃瞄 X3 與 X4（請參閱電路圖；因為 X3X4
; 與 Y1Y2 緊密相鄰，因此只要一條 4 對 4 的杜邦線即可與 PORT1 的 P1.4~P1.7 連接）
; 5. PORT 1 的高 4 位元用於鍵盤掃瞄與按鍵偵測，低 4 位元則用於七段顯示器顯示值之控制。
; 6. 掃瞄過程一旦偵測到按鍵被按下，則停止後續掃瞄，並立即返回主程式加以顯示。

KeyDprd     REG 20H.0 ;旗標：設定是否有按鍵被按下
FirstRow    REG 20H.1 ;旗標：紀錄第一列是否有按鍵被按下
SecondRow   REG 20H.2 ;旗標：紀錄第二列是否有按鍵被按下
            ORG 00H
            JMP START
START:  MOV SP,#30H
        MOV IE,#00H
        MOV PSW,#00H
        CLR KeyDprd      ;設定旗標之初值
        CLR FirstRow     ;設定旗標之初值
        CLR SecondRow    ;設定旗標之初值
        MOV R0,#00H      ;設定七段顯示器所顯示之初值
Cont:   CALL KBScan      ;鍵盤掃瞄副程式
        JNB KeyDprd,Cont
        MOV A,R0         ;將 Port1 設定為 111100xxB 的形式；其中 xx 表示鍵盤碼
        ORL A,#11110000B ;而 Port1 的高 4 位元為 1111 表示掃瞄線不掃瞄
        MOV P1,A         ;低 4 位元控制七段顯示器，高 4 位元控制掃瞄線（暫不掃瞄）
        MOV R5,#10       ;延遲 200ms 再繼續掃瞄
        CALL DELAY
        JMP Cont
;------------------------------------------------------------------------;
; 以下為鍵盤掃瞄副程式；以 Column Major 方式掃瞄 ;
;------------------------------------------------------------------------;
KBScan: CLR KeyDprd               ;每次掃瞄前先清除按鍵被壓下之旗標（清除 KeyDprd 旗標）
        MOV A,R0                  ;掃瞄過程不可影響到顯示值，故透過 ORL 將高 4 位元以及低 4 位元整合
        ScanX3: ORL A,#11100000B  ;先掃瞄欄位 X3（或 X1），亦即第 3 欄（或第 1 欄）
        MOV P1,A
        CALL RowScan
        JNB KeyDprd,ScanX4        ;若欄位 X3 無按鍵被按下則掃瞄第 X4 欄位（亦即第 4 欄）
                                  ;以下表示第 3 欄有按鍵被壓下
        JNB FirstRow,K10Dpd
K00DPd: MOV R0,#00000000B
    JMP EofColScan
K10Dpd: MOV R0,#00000010B
    JMP EofColScan                  ;若第 3 欄無按鍵被按下，則掃瞄第 4 欄
ScanX4: MOV A,R0
    ORL A,#11010000B                ;掃瞄欄位 X4，亦即第 4 欄
    MOV P1,A
    CALL RowScan
    JNB KeyDprd,EofColScan          ;若欄位 X4 無按鍵被按下則結束所有欄位掃瞄（準備重掃一次）
                                    ;以下表示第 4 欄有按鍵被壓下
    JNB FirstRow,K11Dpd
K01Dpd: MOV R0,#00000001B
        JMP EofColScan
K11Dpd: MOV R0,#00000011B
EofColScan: RET                     ;所有欄位均已掃瞄完畢。
;--------------------------------------;
; 以下為掃瞄列之副程式 ;
;--------------------------------------;
RowScan: CLR FirstRow
         CLR SecondRow
         ScanY1: JB P1.6,ScanY2          ;掃瞄列 Y1，亦即第 1 列
         SETB KeyDprd
         SETB FirstRow
         JMP EofRowScan
ScanY2: JB P1.7,EofRowScan          ;掃瞄列 Y2，亦即第 2 列
        SETB KeyDprd
        SETB SecondRow
EofRowScan: RET
;┌─────────────┐
;│ 時間延遲副程式 │
;│ DELAY TIME= R5 * 20 ms │
;└─────────────┘
DELAY: MOV R6,#40
DEL: MOV R7,#248
     DJNZ R7,$
     DJNZ R6,DEL
     DJNZ R5,DELAY
     RET
     END 