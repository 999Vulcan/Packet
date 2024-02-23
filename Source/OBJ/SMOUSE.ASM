;⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∑;
;≥									    ∫;
;≥				Smooth Mouse				    ∫;
;≥									    ∫;
;≥   Universal real / protected mode driver for C++ / Pascal Turbo Vision   ∫;
;≥									    ∫;
;≥			 Copyright (c) 1994-1995 NVS			    ∫;
;≥									    ∫;
;‘ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº;

.model large, pascal
.data

mtype		equ	far

No		equ	0
Yes		equ	1

MONO		equ	0
CGA		equ	1
VEGAHI		equ	2
EGA		equ	3
VGA		equ	4
SVGA		equ	5

NoMouse 	equ	0
SmoothMouse	equ	1
TextMouse	equ	2

NormalCursor	equ	0
ClockCursor	equ	1

Sms1		equ	1
Sms2		equ	5

CountOfLines	dw	16
Matrix		dw	32 dup (0)
Buffer		dw	32 dup (0)
CursorAddres	dw	0
CursorType	dw	NormalCursor
ClockAddres	dw	0
OldCursor	dw	0
DelayTime	dw	6
ClockDelay	dw	6
SavedSymbs	db	Sms1 + 1, Sms1, Sms2 + 1, Sms2
Position	dw	0
MouseX		dw	0
MouseY		dw	0
PMouseX 	dw	0
PMouseY 	dw	0
bCursorVisible	dw	No
MaxX		db	-1
MaxY		db	-1
Xfont		dw	0

WhatMouse	dw	NoMouse
bExistOld	dw	No
OldMask 	dw	-1
bIWork		dw	No
WhatSet 	dw	0
bFirstCall	dw	Yes
HotPointX	dw	0
HotPointY	dw	0
RealX		dw	0
RealY		dw	0
bResident	dw	No
bVGA		dw	No
ShowCount	dw	10

IDT		df	0

include 	cursors.inc

.code
		LOCALS

public		EnableSmoothMouse, InstallSmoothMouse, UninstallSmoothMouse
public		DisableSmoothMouse, RefreshSmoothMouse
public		ChangeFont8to9, ChangeFont9to8
public		ClockToCursor, CursorToClock, CursorToClockDelay

;****************************************************************************;

Select0000	dw	0
SelectB800	dw	0B800h
CodeAlias	dw	?

;****************************************************************************;

OpenAccessToPlane	proc

		uses	ax, dx

		mov	dx, 3C4h
		mov	ax, 402h
		out	dx, ax
		mov	ax, 704h
		out	dx, ax
		mov	dx, 3CEh
		mov	ax, 0ff08h
		out	dx, ax
		mov	ax, 0c06h
		out	dx, ax
		mov	ax, 0204h
		out	dx, ax
		mov	ax, 5h
		out	dx, ax

		ret
endp
;****************************************************************************;

CloseAccessToPlane	proc

		uses	ax, dx

		mov	dx, 3C4h
		mov	ax, 0304h
		out	dx, ax
		mov	ax, 0302h
		out	dx, ax
		mov	dx, 3ceh
		mov	ax, 0e06h
		out	dx, ax
		mov	ax, 4
		out	dx, ax
		mov	ax, 1005h
		out	dx, ax

		ret
endp
;****************************************************************************;

StoreSymbols	proc				; bx - †§‡•· °„‰•‡†

		uses	ax, bx, cx, dx, si, di, ds, es

		push	@data
		pop	es
		push	cs : [SelectB800]
		pop	ds
		call	OpenAccessToPlane

		xor	ax, ax
		mov	al, es : [SavedSymbs + 1]
		mov	si, ax
		mov	cl, 5
		shl	si, cl
		mov	cx, es : [CountOfLines]
		mov	di, bx
@@lp:
		movsb
		inc	di
		loop	@@lp

		xor	ax, ax
		mov	al, es : [SavedSymbs]
		mov	si, ax
		mov	cl, 5
		shl	si, cl
		mov	cx, es : [CountOfLines]
		mov	di, bx
		inc	di
@@lp1:
		movsb
		inc	di
		loop	@@lp1

		xor	ax, ax
		mov	al, es : [SavedSymbs + 3]
		mov	si, ax
		mov	cl, 5
		shl	si, cl
		mov	cx, es : [CountOfLines]
		mov	di, bx
		mov	ax, cx
		shl	ax, 1
		add	di, ax
@@lp2:
		movsb
		inc	di
		loop	@@lp2

		xor	ax, ax
		mov	al, es : [SavedSymbs + 2]
		mov	si, ax
		mov	cl, 5
		shl	si, cl
		mov	cx, es : [CountOfLines]
		mov	di, bx
		inc	di
		mov	ax, cx
		shl	ax, 1
		add	di, ax
@@lp3:
		movsb
		inc	di
		loop	@@lp3

		ret
endp
;****************************************************************************;

RestoreSymbols	proc				; bx - †§‡•· °„‰•‡†

		uses	ax, bx, cx, dx, si, di, ds, es

		push	@data
		pop	ds
		push	cs : [SelectB800]
		pop	es

		mov	di, Sms1 * 32
		mov	cx, CountOfLines
		mov	si, bx
@@loadlp:
		lodsb
		mov	es : [di], al
		lodsb
		mov	es : [di + 32], al
		inc	di
		loop	@@loadlp
		mov	di, Sms2 * 32
		mov	cx, CountOfLines
@@loadlp1:
		lodsb
		mov	es : [di], al
		lodsb
		mov	es : [di + 32], al
		inc	di
		loop	@@loadlp1
		call	CloseAccessToPlane

		ret
endp
;****************************************************************************;

StoreChars	proc

		uses	ds

		cli
		push	@data
		pop	ds
		mov	SavedSymbs, Sms1 + 1
		mov	SavedSymbs[1], Sms1
		mov	SavedSymbs[2], Sms2 + 1
		mov	SavedSymbs[3], Sms2
		lea	bx, Buffer
		call	StoreSymbols
		call	CloseAccessToPlane
		sti

		ret
endp
;****************************************************************************;

RestoreChars	proc

		uses	ds

		cli
		push	@data
		pop	ds
		lea	bx, Buffer
		call	OpenAccessToPlane
		call	RestoreSymbols
		sti

		ret
endp
;****************************************************************************;

ChangeFont9to8	proc

		uses	ax, bx, cx, dx, ds

		push	@data
		pop	ds
		xor	bx, bx
		mov	ax, 1007h
		mov	bl, 0fh
		int	10h
		or	bh, bh
		jz	@@novga
		mov	dx, 3dah
		in	al, dx
		mov	dx, 3c0h
		mov	al, 30h
		out	dx, al
		inc	dx
		in	al, dx
		test	al, 4
		jz	@@novga
		mov	ax, 0f00h
		int	10h
		cmp	al, 3
		jne	@@novga
		mov	bVGA, Yes
		mov	Xfont, 1
		dec	dx
		mov	al, 8
		out	dx, al
		mov	dx, 3dah
		in	al, dx
		mov	dx, 3c0h
		mov	al, 33h
		out	dx, al
		mov	al, 0
		out	dx, al
		mov	dx, 3c2h
		in	al, dx
		mov	al, 01100011b
		out	dx, al
		mov	dx, 3c4h
		mov	ax, 101h
		out	dx, ax
@@novga:
		ret
endp
;****************************************************************************;

ChangeFont8to9	proc

		uses	ax, dx, ds

		push	@data
		pop	ds
		cmp	Xfont, 0
		je	@@novga
		mov	dx, 3dah
		in	al, dx
		mov	dx, 3c0h
		mov	al, 30h
		out	dx, al
		mov	al, 0ch
		out	dx, al
		mov	dx, 3dah
		in	al, dx
		mov	dx, 3c0h
		mov	al, 33h
		out	dx, al
		mov	al, 9
		out	dx, al
		mov	dx, 3c2h
		mov	al, 01100111b
		out	dx, al
		mov	dx, 3c4h
		mov	ax, 1h
		out	dx, ax
@@novga:
		ret
endp
;****************************************************************************;

StoreScreen	proc

		uses	di, ax, bx, dx, ds, cx, es

		push	@data
		pop	ds
		push	cs : [SelectB800]
		pop	es
		mov	ax, MouseY
		xor	bx, bx
		mov	bl, MaxX
		shl	bx, 1
		mul	bx
		mov	di, MouseX
		shl	di, 1
		add	di, ax
		mov	Position, di
		mov	al, es : [di]
		mov	SavedSymbs, al
		mov	al, es : [di + 2]
		mov	SavedSymbs[1], al
		mov	al, es : [di + bx]
		mov	SavedSymbs[2], al
		mov	al, es : [di + bx + 2]
		mov	SavedSymbs[3], al

		ret
endp
;****************************************************************************;

RestoreScreen	proc

		uses	ax, bx, di, es, ds

		push	@data
		pop	ds
		push	cs : [SelectB800]
		pop	es
		xor	bx, bx
		mov	bl, MaxX
		shl	bx, 1
		mov	di, Position
		mov	al, es : [di]
		cmp	al, Sms1 + 1
		jne	@@1
		mov	al, SavedSymbs
		mov	es : [di], al
@@1:
		mov	al, es : [di + 2]
		cmp	al, Sms1
		jne	@@2
		mov	al, SavedSymbs[1]
		mov	es : [di + 2], al
@@2:
		mov	al, es : [di + bx]
		cmp	al, Sms2 + 1
		jne	@@3
		mov	al, SavedSymbs[2]
		mov	es : [di + bx], al
@@3:
		mov	al, es : [di + bx + 2]
		cmp	al, Sms2
		jne	@@4
		mov	al, SavedSymbs[3]
		mov	es : [ di + bx + 2], al
@@4:
		ret
endp
;****************************************************************************;

SetMatrix	proc

		uses	ax, bx, cx, dx, si, di, ds, es

		cli
		push	@data
		pop	ds

		lea	bx, Matrix
		call	StoreSymbols

		mov	ax, PMouseX
		mov	dl, 8
		div	dl
		mov	cl, ah
		mov	ax, PMouseY
		div	byte ptr CountOfLines
		mov	ch, ah

		xor	ax, ax
		mov	al, ch
		mov	di, ax
		shl	di, 1
		add	di, offset Matrix
		mov	bx, CountOfLines
		mov	si, CursorAddres
		mov	dx, bx
@@matlp:
		mov	al, 0ffh
		mov	ah, [si + bx]
		ror	ax, cl
		and	[di], ax
		xor	ax, ax
		mov	ah, [si]
		ror	ax, cl
		or	[di], ax
		add	di, 2
		inc	si
		dec	dl
		jnz	@@matlp

		lea	bx, Matrix
		call	RestoreSymbols

		push	cs : [SelectB800]
		pop	es
		mov	di, Position
		xor	bx, bx
		mov	bl, MaxX
		shl	bx, 1
		mov	byte ptr es : [di], Sms1 + 1
		mov	byte ptr es : [di + bx], Sms2 + 1
		mov	al, MaxX
		dec	al
		cmp	byte ptr MouseX, al
		jae	@@noupdatex
		add	bx, 2
		mov	byte ptr es : [di + 2], Sms1
		mov	byte ptr es : [di + bx], Sms2
@@noupdatex:

		ret
endp
;****************************************************************************;

SetVector	proc

		push	cs : [Select0000]
		pop	es
		push	cs : [CodeAlias]
		pop	ds
		push	ax
		mov	ah, 35h
		int	21h
		mov	[si], bx
		mov	ax, es
		mov	[si + 2], ax
		pop	ax
		mov	ah, 25h
		push	cs
		pop	ds
		int	21h

		ret
endp
;****************************************************************************;

RestoreVector	proc

		uses	ds

		push	cs
		pop	ds
		push	word ptr [bx + 2]
		mov	dx, [bx]
		pop	ds
		mov	ah, 25h
		int	21h

		ret
endp
;****************************************************************************;

HideSmoothMouse proc

		uses	ds

		push	@data
		pop	ds
		cmp	WhatMouse, SmoothMouse
		jne	@@exit
		cmp	bCursorVisible, No
		je	@@exit
		mov	bCursorVisible, No
		call	RestoreScreen
@@exit:
		ret
endp
;****************************************************************************;

RefreshSmoothMouse	proc

		uses	di, ds, es

		cli
		push	@data
		pop	ds
		push	cs : [SelectB800]
		pop	es
		cmp	bResident, Yes
		jne	@@0
		call	mtype ptr EnableSmoothMouse
		mov	bResident, No
@@0:
		cmp	WhatMouse, SmoothMouse
		jne	@@exit
		xor	bx, bx
		mov	bl, MaxX
		shl	bx, 1
		mul	bx
		xor	cx, cx
		mov	di, Position
		mov	al, es : [di]
		cmp	al, Sms1 + 1
		je	@@1
		mov	SavedSymbs, al
		inc	cx
@@1:
		mov	al, es : [di + 2]
		cmp	al, Sms1
		je	@@2
		mov	SavedSymbs[1], al
		inc	cx
@@2:
		mov	al, es : [di + bx]
		cmp	al, Sms2 + 1
		je	@@3
		mov	SavedSymbs[2], al
		inc	cx
@@3:
		mov	al, es : [di + bx + 2]
		cmp	al, Sms2
		je	@@4
		mov	SavedSymbs[3], al
		inc	cx
@@4:
		or	cx, cx
		jz	@@exit
		call	SetMatrix
@@exit:
		sti

		ret
endp
;****************************************************************************;

RestoreHandler	proc

		uses	ax, cx, dx, es, ds

		push	@data
		pop	ds
		cmp	bExistOld, No
		je	@@exit
		push	bIWork
		mov	bIWork, Yes
		push	cs : [OldHandler + 2]
		pop	es
		mov	dx, cs : [OldHandler]
		mov	cx, OldMask
		mov	ax, 0Ch
		int	33h
		pop	bIWork
@@exit:
		ret
endp
;****************************************************************************;

SetMyHandler	proc

		uses	es

		push	cs
		pop	es
		lea	dx, NewHandler
		mov	cx, 0FFFFh
		mov	ax, 0Ch
		int	33h

		ret
endp
;****************************************************************************;

CsGraphToText	proc

		uses	ax

		shr	cx, 1
		shr	cx, 1
		shr	cx, 1
		mov	ax, dx
		div	byte ptr CountOfLines
		xor	ah, ah
		mov	dx, ax

		ret
endp
;****************************************************************************;

NewHandler	proc	far

		push	ds
		push	@data
		pop	ds
		cmp	WhatMouse, SmoothMouse
		jne	@@exit1
		shr	cx, 1
		shr	cx, 1
		shr	cx, 1
		shr	dx, 1
		shr	dx, 1
		shr	dx, 1
		mov	PMouseX, cx
		mov	PMouseY, dx
		call	CsGraphToText
		mov	MouseX, cx
		mov	MouseY, dx
		cmp	bCursorVisible, No
		je	@@exit
		call	RestoreScreen
		call	StoreScreen
		call	SetMatrix
@@exit:
		mov	cx, PMouseX
		mov	dx, PMouseY
		add	cx, HotPointX
		add	dx, HotPointY
		call	CsGraphToText
		shl	cx, 1
		shl	cx, 1
		shl	cx, 1
		shl	dx, 1
		shl	dx, 1
		shl	dx, 1
		mov	RealX, cx
		mov	RealY, dx
@@exit1:
		cmp	bExistOld, No
		mov	ax, OldMask
		pop	ds
		je	@@notexist
		cmp	bResident, Yes
		je	@@notexist

		db	9ah
OldHandler	dw	2 dup (0)
@@notexist:
		retf
endp
;****************************************************************************;

GetScreenMode	proc

		uses	bx, es

		mov	ax, cs : [Select0000]
		mov	es, ax
		xor	bx, bx
		mov	bl, [es : 449h]
		cmp	bl, 3
		jne	@@MayBeSVGA
		inc	ax
		mov	bl, [es : 484h]
		or	bl, bl
		jz	@@exit
		inc	ax
		cmp	bl, 24
		jne	@@exit
		inc	ax
		push	ax
		mov	ax, 1007h
		mov	bl, 0fh
		int	10h
		pop	ax
		or	bh, bh
		jz	@@exit
		inc	ax
		jmp	short @@exit
@@MayBeSVGA:
		cmp	bl, 13h
		jle	@@exit
		mov	ax, SVGA
@@exit:
		ret
endp
;****************************************************************************;

InstallSmoothMouse	proc

		uses	si, di, ds, es

		push	@data
		pop	ds

		mov	ax, 1686h
		int	2Fh
		or	ax, ax
		jz	@@dpmi
		mov	ax, cs
		mov	cs : [CodeAlias], ax
		jmp	short @@nodpmi
@@dpmi:
		mov	ax, 0Ah
		mov	bx, cs
		int	31h
		mov	es, ax
		mov	es : [CodeAlias], ax
		mov	ax, 2
		xor	bx, bx
		int	31h
		mov	es : [Select0000], ax
		mov	ax, 2
		mov	bx, 0B800h
		int	31h
		mov	es : [SelectB800], ax
@@nodpmi:
		call	GetScreenMode
		cmp	ax, VEGAHI
		jl	@@nomouse
		call	ChangeFont9to8
		cmp	WhatMouse, NoMouse
		jne	@@nomouse
		xor	ax, ax
		int	33h
		cmp	ax, -1
		jne	@@nomouse
		mov	WhatMouse, TextMouse
		mov	ax, 33h
		lea	si, Old33
		lea	dx, New33
		call	SetVector
		mov	ax, 16h
		lea	si, Old16
		lea	dx, New16
		call	SetVector
		mov	ax, 1Ch
		lea	si, Old1C
		lea	dx, New1C
		call	SetVector
@@nomouse:
		ret
endp
;****************************************************************************;

UninstallSmoothMouse	proc

		uses	ds, es

		push	@data
		pop	ds
		call	ChangeFont8to9
		cmp	WhatMouse, NoMouse
		je	@@exit
		cmp	WhatMouse, SmoothMouse
		jne	@@0
		call	mtype ptr DisableSmoothMouse
@@0:
		mov	ax, 1Ch
		lea	bx, Old1C
		call	RestoreVector
		mov	ax, 16h
		lea	bx, Old16
		call	RestoreVector
		mov	ax, 33h
		lea	bx, Old33
		call	RestoreVector
		call	RestoreHandler
		mov	bFirstCall, Yes
		mov	WhatMouse, NoMouse
		mov	ax, 2
		int	33h
@@exit:
		ret
endp
;****************************************************************************;

ShowSmoothMouse proc

		uses	es, ds, si, di

		push	@data
		pop	ds
		cmp	WhatMouse, SmoothMouse
		jne	@@exit
		cmp	bCursorVisible, Yes
		je	@@exit
		mov	bCursorVisible, Yes
		call	StoreScreen
		call	SetMatrix
@@exit:
		ret
endp
;****************************************************************************;

GetVideoParams	proc

		uses	ax, bx, cx, dx, es, ds

		push	cs : [Select0000]
		pop	es
		push	@data
		pop	ds
		mov	CursorType, NormalCursor
		push	bIWork
		mov	bIWork, Yes
		cmp	bFirstCall, Yes
		je	@@0
		cmp	WhatMouse, TextMouse
		je	@@nogo0
		xor	cx, cx
		xor	dx, dx
		mov	ax, 4
		int	33h
		mov	cx, ShowCount
		mov	ax, 1
@@rep:
		int	33h
		loop	@@rep
		inc	ax
		int	33h
@@nogo0:
		call	ChangeFont9to8
@@0:
		xor	ax, ax
		xor	bx, bx
		mov	ah, [es : 44ah]
		mov	al, [es : 484h]
		inc	al
		xor	cx, cx
		mov	cl, [es : 485h]
		cmp	ah, MaxX
		je	@@1
		mov	MaxX, ah
		inc	bx
@@1:
		cmp	al, MaxY
		je	@@2
		mov	MaxY, al
		inc	bx
@@2:
		cmp	cx, CountOfLines
		je	@@3
		mov	CountOfLines, cx
		inc	bx
@@3:
		or	bx, bx
		jz	@@chbounds
@@01:
		mov	ax, cx
@@nochcur:
		cmp	ax, 16
		jne	@@no16lines
		mov	ax, offset OR_16
		mov	ClockAddres, offset COR_16
		jmp	short @@4
@@no16lines:
		cmp	ax, 14
		jne	@@8lines
		mov	ax, offset OR_14
		mov	ClockAddres, offset COR_14
		jmp	short @@4
@@8lines:
		mov	ax, offset OR_8
		mov	ClockAddres, offset COR_8
@@4:
		mov	CursorAddres, ax
		mov	bx, ax
		mov	ax, [bx - 4]
		mov	HotPointX, ax
		mov	ax, [bx - 2]
		mov	HotPointY, ax
@@chbounds:
		xor	dx, dx
		mov	dl, MaxX
		mov	cx, 3
		shl	dx, cl
		sub	dx, 4
		shl	dx, cl
		xor	cx, cx
		mov	ax, 7
		int	33h
		xor	ax, ax
		mov	al, MaxY
		mul	CountOfLines
		mov	dx, ax
		sub	dx, CountOfLines
		add	dx, 3
		mov	cx, 3
		shl	dx, cl
		xor	cx, cx
		mov	ax, 8
		int	33h
		cmp	WhatMouse, TextMouse
		je	@@nogo
		mov	ax, PMouseX
		mov	dx, PMouseY
		mov	cx, 3
		shl	ax, cl
		shl	dx, cl
		mov	cx, ax
		mov	ax, 4
		int	33h
@@nogo:
		mov	bIWork, si
		call	StoreChars
		cmp	WhatMouse, SmoothMouse
		jne	@@noupdate
		mov	cx, PMouseX
		mov	dx, PMouseY
		shl	cx, 1
		shl	cx, 1
		shl	cx, 1
		shl	dx, 1
		shl	dx, 1
		shl	dx, 1
		xor	bx, bx
		call	NewHandler
@@noupdate:
		pop	bIWork

		ret
endp
;****************************************************************************;

EnableSmoothMouse	proc

		uses	ax, bx, cx, dx, si, di, es

		push	@data
		pop	ds
		cmp	WhatMouse, TextMouse
		JUMPS
		jne	@@exit
		NOJUMPS
		push	bIWork
		mov	bIWork, Yes
		mov	MaxY, -1
		call	GetVideoParams
		mov	ax, 2
		int	33h
		mov	ax, 0fh
		mov	cx, 1
		mov	dx, 1
		int	33h
		call	SetMyHandler
		xor	cx, cx
		xor	dx, dx
		cmp	bFirstCall, Yes
		je	@@fcall
		mov	ax, 3
		int	33h
		shr	cx, 1
		shr	cx, 1
		shr	cx, 1
		shr	dx, 1
		shr	dx, 1
		shr	dx, 1
		mov	MouseX, cx
		mov	MouseY, dx
		mov	bx, cx
		mov	cx, 6
		shl	bx, cl
		sub	cx, 3
		shl	dx, cl
		mov	cx, bx
		mov	ax, dx
		mul	CountOfLines
		mov	dx, ax
@@fcall:
		mov	ax, 4
		int	33h
		mov	WhatMouse, SmoothMouse
		xor	bx, bx
		call	NewHandler
		cmp	bFirstCall, Yes
		jne	@@nofcall
		call	mtype ptr CursorToClock
		mov	bFirstCall, No
@@nofcall:
		call	ShowSmoothMouse
		pop	bIWork
@@exit:
		ret
endp
;****************************************************************************;

DisableSmoothMouse	proc

		uses	ax, bx, cx, dx, si, di, ds

		push	@data
		pop	ds
		push	bIWork
		cmp	WhatMouse, SmoothMouse
		JUMPS
		jne	@@exit
		NOJUMPS
		mov	bIWork, Yes
		call	HideSmoothMouse
		call	RestoreChars
		call	RestoreHandler
		mov	WhatMouse, TextMouse
		xor	cx, cx
		xor	dx, dx
		mov	dl, MaxX
		dec	dx
		shl	dx, 1
		shl	dx, 1
		shl	dx, 1
		mov	ax, 7
		int	33h
		xor	cx, cx
		xor	dx, dx
		mov	dl, MaxY
		dec	dx
		shl	dx, 1
		shl	dx, 1
		shl	dx, 1
		mov	ax, 8
		int	33h
		mov	cx, 8
		mov	dx, 16
		mov	ax, 0fh
		int	33h
		mov	cx, RealX
		mov	dx, RealY
		mov	ax, 4
		int	33h
		mov	ax, 1
		mov	cx, ShowCount
@@rep:
		int	33h
		loop	@@rep
@@exit:
		pop	bIWork

		ret
endp
;****************************************************************************;

New33		proc	far

		push	ds
		push	@data
		pop	ds
		cmp	bIWork, Yes
		JUMPS
		je	@@notouch
		NOJUMPS
		cli
		cmp	WhatMouse, SmoothMouse
		je	@@0
		cmp	ax, 0Ch
		jne	@@noset
		mov	bExistOld, Yes
		mov	OldMask, cx
		mov	ax, es
		push	es
		push	cs : [CodeAlias]
		pop	es
		mov	es : OldHandler[0], dx
		mov	es : OldHandler[2], ax
		pop	es
		jmp	short @@exit
@@noset:
		cmp	ax, 7
		jne	@@notouch
		cmp	bFirstCall, Yes
		je	@@notouch
		call	ChangeFont9to8
		jmp	short @@notouch
@@0:
		or	ax, ax
		jz	@@01
		cmp	ax, 3
		je	@@01
		cmp	ax, 4
		jne	@@02
@@01:
		mov	bResident, Yes
		call	DisableSmoothMouse
		jmp	short @@notouch
@@02:
		cmp	ax, 1
		jne	@@1
		call	ShowSmoothMouse
		jmp	short @@exit
@@1:
		cmp	ax, 2
		jne	@@2
		call	HideSmoothMouse
		jmp	short @@exit
@@2:
		cmp	ax, 7
		jne	@@exit
		cmp	bFirstCall, Yes
		je	@@exit
		call	GetVideoParams
		jmp	short @@exit
@@notouch:
		pop	ds
		db	0eah
Old33		dd	0
@@exit:
		pop	ds

		iret
endp
;****************************************************************************;

CursorToClockDelay	proc

		arg	Time : word
		uses	ax

		push	ds
		push	@data
		pop	ds
		mov	ax, Time
		mov	DelayTime, ax
		pop	ds

		ret
endp
;****************************************************************************;

CursorToClock	proc

		uses	ax, ds, bx, si

		push	@data
		pop	ds
		cmp	WhatMouse, SmoothMouse
		jne	@@noclock
		cmp	CursorType, NormalCursor
		jne	@@noclock
		mov	ax, bCursorVisible
		call	HideSmoothMouse
		push	CursorAddres
		pop	OldCursor
		push	ClockAddres
		pop	CursorAddres
		mov	CursorType, ClockCursor
		cmp	ax, Yes
		jne	@@noclock
		call	ShowSmoothMouse
@@noclock:
		ret
endp
;****************************************************************************;

ClockToCursor	proc

		uses	ax, ds, bx, si, di

		push	@data
		pop	ds
		cmp	WhatMouse, SmoothMouse
		jne	@@noclock
		cmp	CursorType, NormalCursor
		je	@@noclock
		mov	ax, bCursorVisible
		call	HideSmoothMouse
		push	OldCursor
		pop	CursorAddres
		mov	CursorType, NormalCursor
		cmp	ax, Yes
		jne	@@noclock
		call	ShowSmoothMouse
@@noclock:
		ret
endp
;****************************************************************************;

New16		proc	far

		cmp	ah, 1
		jne	@@nofun
		cli
		push	ds
		push	@data
		pop	ds
		cmp	WhatMouse, SmoothMouse
		jne	@@noclock
		push	ax
		mov	ax, DelayTime
		mov	ClockDelay, ax
		pop	ax
		cmp	CursorType, NormalCursor
		je	@@noclock
		call	ClockToCursor
@@noclock:
		pop	ds
		sti
@@nofun:
		db	0eah
Old16		dd	0

endp
;****************************************************************************;

New1C		proc	far

		pushf
		db	9ah
Old1C		dd	0

		cli
		push	ds
		push	@data
		pop	ds
		cmp	WhatMouse, SmoothMouse
		jne	@@noclock
		cmp	CursorType, NormalCursor
		jne	@@noclock
		dec	ClockDelay
		jnz	@@noclock
		push	ax
		mov	ax, DelayTime
		mov	ClockDelay, ax
		pop	ax
		call	CursorToClock
@@noclock:
		sti
		push	ax
		mov	al, 20h
		out	20h, al
		pop	ax
		pop	ds

		iret
endp

;****************************************************************************;
end
