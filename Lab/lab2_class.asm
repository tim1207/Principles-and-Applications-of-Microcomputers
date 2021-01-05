;   查表霹靂燈lab1	      ;
    ORG 00h
    JMP START
START: MOV SP,#30h
    MOV IE,#00H
    MOV PSW,#00H
    MOV DPTR,#TABLE
    ;MOVE DPTR 0138H
    MOV R0,#00H
NEXT: MOV A,R0
    MOVC A,@A+DPTR
    ;A <= A+TABLE(0111 1110)
    MOV P1,A
    MOV R5,#10
    CALL DELAY
    INC R0
    ; increase by 1
    CJNE R0,#6,NEXT
    ;不相等跳 next
    MOV R0,#00H
    JMP NEXT
;第二次會是1+TABLE 為 1011 1101
;┌─────────────┐
;│ 時間延遲副程式 │
;│ Delay Time = R5 * 20 ms |
;└─────────────┘
DELAY: MOV R6,#40
DEL: MOV R7,#248
     DJNZ R7,$
     DJNZ R6,DEL
     DJNZ R5,DELAY
     RET
;ORG 0138H (可不用)
TABLE: DB 07EH,0BDH,0DBH
       ;0111 1110 |1011 1101 |1101 1011
       DB 0E7H,0DBH,0BDH
       ;1110 0111 |1101 10011 |1011 1101
;DB :define bytes
END