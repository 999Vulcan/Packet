; Обычные курсоры

HP_16		dw	1, 1
OR_16		db  00h,040h,060h,070h,078h,07Ch,07Eh,07Eh,078h,04Ch,0Ch,04h
		db  06h,06h,00h,00h
AND_16		db  3fh,1fh,0fh,7h,3,1,0,0,0,1,0a1h,0f0h,0f0h,0f0h,0f8h,0ffh

HP_14		dw	1, 1
OR_14   	db  00h,040h,060h,070h,078h,07Ch,07Eh,078h,04Ch,04h,06h,00h
		db  00h,00h
AND_14  	db  03Fh,01Fh,0Fh,07h,03h,01h,00h,01h,03h,0B1h,0F0h,0F9h
		db  0FFh,0FFh

HP_8		dw	1, 0
OR_8	   	db  40h,60h,70h,78h,70h,50h,08h,08h
AND_8	  	db  1Fh,0Fh,07h,03h,07h,07h,0e3h,0e3h

; Курсоры - "Песочные часы"

CHP_16		dw	0, 0
COR_16		db  0,7fh,22h,2ah,3eh,3eh,1ch,8,14h,36h,22h,2ah,3eh,7fh,0,0
CAND_16		db  0,0,0,80h,80h,80h,80h,0c1h,80h,80h,80h,80h,0,0,0,0ffh

CHP_14		dw	0, 0
COR_14   	db  0,7fh,22h,2ah,3eh,1ch,8,14h,22h,2ah,3eh,7fh,0,0
CAND_14  	db  0,0,0,80h,80h,80h,0c1h,80h,80h,80h,0,0,0,0ffh

CHP_8		dw	0, 0
COR_8	  	db  0,7fh,22h,1ch,8,14h,2ah,7fh
CAND_8	   	db  0,0,0,80h,0c1h,80h,0,0
