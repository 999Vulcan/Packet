.model large, pascal
.data

No              equ     0
Yes             equ     1

NoMouse         equ     0
SmoothMouse     equ     1
TextMouse       equ     2

NormalCursor    equ     0
ClockCursor     equ     1

Sms1            equ     1
Sms2            equ     5

CountOfLines    dw      16
Matrix          dw      32 dup (0)
Buffer          dw      32 dup (0)
CursorAddres    dw      0
CursorType      dw      NormalCursor
ClockAddres     dw      0
OldCursor       dw      0
DelayTime       dw      5
ClockDelay      dw      5
SavedSymbs      db      Sms1 + 1, Sms1, Sms2 + 1, Sms2
Position        dw      0
MouseX          dw      0
MouseY          dw      0
PMouseX         dw      0
PMouseY         dw      0
bCursorVisible  dw      No
MaxX            db      -1
MaxY            db      -1
Xfont           dw      0

WhatMouse       dw      NoMouse
bExistOld       dw      No
OldMask         dw      -1
bIWork          dw      No
WhatSet         dw      0
bFirstCall      dw      Yes
HotPointX       dw      0
HotPointY       dw      0
RealX           dw      0
RealY           dw      0
bResident       dw      No
bVGA            dw      No
ShowCount       dw      10

include         cursors.inc

.code
                LOCALS

ideal

public          EnableSmoothMouse, InstallSmoothMouse, UninstallSmoothMouse
public          DisableSmoothMouse, RefreshSmoothMouse
public          ChangeFont8to9, ChangeFont9to8
public          ClockToCursor, CursorToClock, CursorToClockDelay

;****************************************************************************;

proc            OpenAccessToPlane

                uses    ax, dx

                mov     dx, 3C4h
                mov     ax, 402h
                out     dx, ax
                mov     ax, 704h
                out     dx, ax
                mov     dx, 3CEh
                mov     ax, 0ff08h
                out     dx, ax
                mov     ax, 0c06h
                out     dx, ax
                mov     ax, 0204h
                out     dx, ax
                mov     ax, 5h
                out     dx, ax

                ret
endp
;****************************************************************************;

proc            CloseAccessToPlane

                uses    ax, dx

                mov     dx, 3C4h
                mov     ax, 0304h
                out     dx, ax
                mov     ax, 0302h
                out     dx, ax
                mov     dx, 3ceh
                mov     ax, 0e06h
                out     dx, ax
                mov     ax, 4
                out     dx, ax
                mov     ax, 1005h
                out     dx, ax

                ret
endp
;****************************************************************************;

proc            StoreSymbols            ; bx - адрес буфера

                uses    ax, bx, cx, dx, si, di, ds, es

                push    @data
                pop     es
                push    0b800h
                pop     ds
                call    OpenAccessToPlane

                xor     ax, ax
                mov     al, es : [SavedSymbs + 1]
                mov     si, ax
                mov     cl, 5
                shl     si, cl
                mov     cx, es : [CountOfLines]
                mov     di, bx
@@lp:
                movsb
                inc     di
                loop    @@lp

                xor     ax, ax
                mov     al, es : [SavedSymbs]
                mov     si, ax
                mov     cl, 5
                shl     si, cl
                mov     cx, es : [CountOfLines]
                mov     di, bx
                inc     di
@@lp1:
                movsb
                inc     di
                loop    @@lp1

                xor     ax, ax
                mov     al, es : [SavedSymbs + 3]
                mov     si, ax
                mov     cl, 5
                shl     si, cl
                mov     cx, es : [CountOfLines]
                mov     di, bx
                mov     ax, cx
                shl     ax, 1
                add     di, ax
@@lp2:
                movsb
                inc     di
                loop    @@lp2

                xor     ax, ax
                mov     al, es : [SavedSymbs + 2]
                mov     si, ax
                mov     cl, 5
                shl     si, cl
                mov     cx, es : [CountOfLines]
                mov     di, bx
                inc     di
                mov     ax, cx
                shl     ax, 1
                add     di, ax
@@lp3:
                movsb
                inc     di
                loop    @@lp3

                ret
endp
;****************************************************************************;

proc            RestoreSymbols          ; bx - адрес буфера

                uses    ax, bx, cx, dx, si, di, ds, es

                push    @data
                pop     ds
                push    0b800h
                pop     es

                mov     di, Sms1 * 32
                mov     cx, CountOfLines
                mov     si, bx
@@loadlp:
                lodsb
                mov     [es : di], al
                lodsb
                mov     [es : di + 32], al
                inc     di
                loop    @@loadlp
                mov     di, Sms2 * 32
                mov     cx, CountOfLines
@@loadlp1:
                lodsb
                mov     [es : di], al
                lodsb
                mov     [es : di + 32], al
                inc     di
                loop    @@loadlp1
                call    CloseAccessToPlane

                ret
endp
;****************************************************************************;

proc            StoreChars

                uses    ds

                cli
                push    @data
                pop     ds
                mov     SavedSymbs, Sms1 + 1
                mov     SavedSymbs[1], Sms1
                mov     SavedSymbs[2], Sms2 + 1
                mov     SavedSymbs[3], Sms2
                lea     bx, Buffer
                call    StoreSymbols
                call    CloseAccessToPlane
                sti

                ret
endp
;****************************************************************************;

proc            RestoreChars

                uses    ds

                cli
                push    @data
                pop     ds
                lea     bx, Buffer
                call    OpenAccessToPlane
                call    RestoreSymbols
                sti

                ret
endp
;****************************************************************************;

proc            ChangeFont9to8

                uses    ax, bx, cx, dx, ds

                push    @data
                pop     ds
                xor     bx, bx
                mov     ax, 1007h
                mov     bl, 0fh
                int     10h
                or      bh, bh
                jz      @@novga
                mov     dx, 3dah
                in      al, dx
                mov     dx, 3c0h
                mov     al, 30h
                out     dx, al
                inc     dx
                in      al, dx
                test    al, 4
                jz      @@novga
                mov     ax, 0f00h
                int     10h
                cmp     al, 3
                jne     @@novga
                mov     bVGA, Yes
                mov     Xfont, 1
                dec     dx
                mov     al, 8
                out     dx, al
                mov     dx, 3dah
                in      al, dx
                mov     dx, 3c0h
                mov     al, 33h
                out     dx, al
                mov     al, 0
                out     dx, al
                mov     dx, 3c2h
                in      al, dx
                mov     al, 01100011b
                out     dx, al
                mov     dx, 3c4h
                mov     ax, 101h
                out     dx, ax
@@novga:
                ret
endp
;****************************************************************************;

proc            ChangeFont8to9

                uses    ax, dx, ds

                push    @data
                pop     ds
                cmp     Xfont, 0
                je      @@novga
                mov     dx, 3dah
                in      al, dx
                mov     dx, 3c0h
                mov     al, 30h
                out     dx, al
                mov     al, 0ch
                out     dx, al
                mov     dx, 3dah
                in      al, dx
                mov     dx, 3c0h
                mov     al, 33h
                out     dx, al
                mov     al, 9
                out     dx, al
                mov     dx, 3c2h
                mov     al, 01100111b
                out     dx, al
                mov     dx, 3c4h
                mov     ax, 1h
                out     dx, ax
@@novga:
                ret
endp
;****************************************************************************;

proc            StoreScreen

                uses    di, ax, bx, dx, ds, cx, es

                push    @data
                pop     ds
                push    0b800h
                pop     es
                mov     ax, MouseY
                xor     bx, bx
                mov     bl, MaxX
                shl     bx, 1
                mul     bx
                mov     di, MouseX
                shl     di, 1
                add     di, ax
                mov     Position, di
                mov     al, [es : di]
                mov     SavedSymbs, al
                mov     al, [es : di + 2]
                mov     SavedSymbs[1], al
                mov     al, [es : di + bx]
                mov     SavedSymbs[2], al
                mov     al, [es : di + bx + 2]
                mov     SavedSymbs[3], al

                ret
endp
;****************************************************************************;

proc            RestoreScreen

                uses    ax, bx, di, es, ds

                push    @data
                pop     ds
                push    0b800h
                pop     es
                xor     bx, bx
                mov     bl, MaxX
                shl     bx, 1
                mov     di, Position
                mov     al, [es : di]
                cmp     al, Sms1 + 1
                jne     @@1
                mov     al, SavedSymbs
                mov     [es : di], al
@@1:
                mov     al, [es : di + 2]
                cmp     al, Sms1
                jne     @@2
                mov     al, SavedSymbs[1]
                mov     [es : di + 2], al
@@2:
                mov     al, [es : di + bx]
                cmp     al, Sms2 + 1
                jne     @@3
                mov     al, SavedSymbs[2]
                mov     [es : di + bx], al
@@3:
                mov     al, [es : di + bx + 2]
                cmp     al, Sms2
                jne     @@4
                mov     al, SavedSymbs[3]
                mov     [es : di + bx + 2], al
@@4:
                ret
endp
;****************************************************************************;

proc            SetMatrix

                uses    ax, bx, cx, dx, si, di, ds, es

                push    @data
                pop     ds

                cli
                lea     bx, Matrix
                call    StoreSymbols

                mov     ax, PMouseX
                mov     dl, 8
                div     dl
                mov     cl, ah
                mov     ax, PMouseY
                div     byte ptr CountOfLines
                mov     ch, ah

                xor     ax, ax
                mov     al, ch
                mov     di, ax
                shl     di, 1
                add     di, offset Matrix
                mov     bx, CountOfLines
                mov     si, CursorAddres
                mov     dx, bx
@@matlp:
                mov     al, 0ffh
                mov     ah, [si + bx]
                ror     ax, cl
                and     [di], ax
                xor     ax, ax
                mov     ah, [si]
                ror     ax, cl
                or      [di], ax
                add     di, 2
                inc     si
                dec     dl
                jnz     @@matlp

                lea     bx, Matrix
                call    RestoreSymbols

                push    0b800h
                pop     es
                mov     di, Position
                xor     bx, bx
                mov     bl, MaxX
                shl     bx, 1
                mov     byte ptr [es : di], Sms1 + 1
                mov     byte ptr [es : di + bx], Sms2 + 1
                mov     al, MaxX
                dec     al
                cmp     byte ptr MouseX, al
                jae     @noupdatex
                add     bx, 2
                mov     byte ptr [es : di + 2], Sms1
                mov     byte ptr [es : di + bx], Sms2
@noupdatex:
                sti

                ret
endp
;****************************************************************************;

proc            SetVector

                uses    ax, es, bx

                push    0
                pop     es
                shl     bx, 1
                shl     bx, 1
                mov     ax, es : [bx]
                mov     cs : [si], ax
                mov     ax, es : [bx + 2]
                mov     cs : [si + 2], ax
                cli
                mov     es : [bx], di
                mov     es : [bx + 2], cs
                sti

                ret
endp
;****************************************************************************;

proc            RestoreVector

                uses    ax, es, bx

                push    0
                pop     es
                shl     bx, 1
                shl     bx, 1
                cli
                mov     ax, cs : [si]
                mov     es : [bx], ax
                mov     ax, cs : [si + 2]
                mov     es : [bx + 2], ax
                sti

                ret
endp
;****************************************************************************;

proc            HideSmoothMouse

                uses    ds

                push    @data
                pop     ds
                cmp     WhatMouse, SmoothMouse
                jne     @@exit
                cmp     bCursorVisible, No
                je      @@exit
                mov     bCursorVisible, No
                call    RestoreScreen
@@exit:
                ret
endp
;****************************************************************************;

proc            RefreshSmoothMouse

                uses    ax, bx, di, ds, es

                cli
                push    @data
                pop     ds
                push    0b800h
                pop     es
                cmp     bResident, Yes
                jne     @@0
                call    far ptr EnableSmoothMouse
                mov     bResident, No
@@0:
                cmp     WhatMouse, SmoothMouse
                jne     @@exit
                xor     bx, bx
                mov     bl, MaxX
                shl     bx, 1
                mul     bx
                mov     di, Position
                mov     al, [es : di]
                cmp     al, Sms1 + 1
                je      @@1
                mov     SavedSymbs, al
@@1:
                mov     al, [es : di + 2]
                cmp     al, Sms1
                je      @@2
                mov     SavedSymbs[1], al
@@2:
                mov     al, [es : di + bx]
                cmp     al, Sms2 + 1
                je      @@3
                mov     SavedSymbs[2], al
@@3:
                mov     al, [es : di + bx + 2]
                cmp     al, Sms2
                je      @@4
                mov     SavedSymbs[3], al
@@4:
                call    SetMatrix
@@exit:
                sti

                ret
endp
;****************************************************************************;

proc            RestoreHandler

                uses    ax, cx, dx, es, ds

                push    @data
                pop     ds
                cmp     bExistOld, No
                je      @@exit
                push    bIWork
                mov     bIWork, Yes
                push    cs : [OldHandler + 2]
                pop     es
                mov     dx, cs : [OldHandler]
                mov     cx, OldMask
                mov     ax, 0ch
                int     33h
                pop     bIWork
@@exit:
                ret
endp
;****************************************************************************;

proc            SetMyHandler

                uses    ax, bx, cx, dx, si, di, es, ds

                push    cs
                pop     es
                push    @data
                pop     ds
                lea     dx, NewHandler
                mov     cx, 7fh
                mov     ax, 14h
                int     33h
                cmp     bFirstCall, No
                je      @@exit
                or      dx, dx
                jnz     @@exist
@@1:
                mov     ax, es
                or      ax, ax
                jz      @@exit
@@exist:
                mov     bExistOld, Yes
                mov     cs : [OldHandler], dx
                mov     cs : [OldHandler + 2], es
                mov     OldMask, cx
@@exit:
                ret
endp
;****************************************************************************;

proc            CsGraphToText

                uses    ax

                shr     cx, 1
                shr     cx, 1
                shr     cx, 1
                mov     ax, dx
                div     byte ptr CountOfLines
                xor     ah, ah
                mov     dx, ax

                ret
endp
;****************************************************************************;

proc            NewHandler

                push    ds
                push    @data
                pop     ds
                cmp     WhatMouse, SmoothMouse
                jne     @@exit1
                shr     cx, 1
                shr     cx, 1
                shr     cx, 1
                shr     dx, 1
                shr     dx, 1
                shr     dx, 1
                mov     PMouseX, cx
                mov     PMouseY, dx
                call    CsGraphToText
                mov     MouseX, cx
                mov     MouseY, dx
                cmp     bCursorVisible, No
                je      @@exit
                call    RestoreScreen
                call    StoreScreen
                call    SetMatrix
@@exit:
                mov     cx, PMouseX
                mov     dx, PMouseY
                add     cx, HotPointX
                add     dx, HotPointY
                call    CsGraphToText
                shl     cx, 1
                shl     cx, 1
                shl     cx, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                mov     RealX, cx
                mov     RealY, dx
@@exit1:
                cmp     bExistOld, No
                mov     ax, OldMask
                pop     ds
                je      @@notexist
                cmp     bResident, Yes
                je      @@notexist

                db      9ah
OldHandler      dw      2 dup (0)
@@notexist:
                ret
endp
;****************************************************************************;

proc            InstallSmoothMouse

                uses    ax, bx, si, di, ds

                push    @data
                pop     ds
                call    ChangeFont9to8
                cmp     WhatMouse, NoMouse
                jne     @@nomouse
                xor     ax, ax
                int     33h
                cmp     ax, 0ffffh
                jne     @@nomouse
                mov     WhatMouse, TextMouse
                mov     bx, 33h
                lea     si, Old33
                lea     di, New33
                call    SetVector
                mov     bx, 16h
                lea     si, Old16
                lea     di, New16
                call    SetVector
                mov     bx, 1Ch
                lea     si, Old1C
                lea     di, New1C
                call    SetVector
@@nomouse:
                ret
endp
;****************************************************************************;

proc            UninstallSmoothMouse

                uses    es, dx, cx, ax, ds

                push    @data
                pop     ds
;               call    ChangeFont8to9
                cmp     WhatMouse, NoMouse
                je      @@exit
                cmp     WhatMouse, SmoothMouse
                jne     @@0
                call    far ptr DisableSmoothMouse
@@0:
                mov     bx, 1ch
                lea     si, Old1C
                call    RestoreVector
                mov     bx, 16h
                lea     si, Old16
                call    RestoreVector
                mov     bx, 33h
                lea     si, Old33
                call    RestoreVector
                call    RestoreHandler
                mov     bFirstCall, Yes
                mov     WhatMouse, NoMouse
@@exit:
                ret
endp
;****************************************************************************;

proc            ShowSmoothMouse

                uses    es, ds, si, di

                push    @data
                pop     ds
                cmp     WhatMouse, SmoothMouse
                jne     @@exit
                cmp     bCursorVisible, Yes
                je      @@exit
                mov     bCursorVisible, Yes
                call    StoreScreen
                call    SetMatrix
@@exit:
                ret
endp
;****************************************************************************;

proc            GetVideoParams

                uses    ax, bx, cx, dx, es, ds

                push    0
                pop     es
                push    @data
                pop     ds
                mov     CursorType, NormalCursor
                push    bIWork
                mov     bIWork, Yes
                cmp     bFirstCall, Yes
                je      @@0
                cmp     WhatMouse, TextMouse
                je      @@nogo0
                xor     cx, cx
                xor     dx, dx
                mov     ax, 4
                int     33h
                mov     cx, ShowCount
                mov     ax, 1
@@rep:
                int     33h
                loop    @@rep
                inc     ax
                int     33h
@@nogo0:
                call    ChangeFont9to8
@@0:
                xor     ax, ax
                xor     bx, bx
                mov     ah, [es : 44ah]
                mov     al, [es : 484h]
                inc     al
                xor     cx, cx
                mov     cl, [es : 485h]         ; Число байтов в символе
                cmp     ah, MaxX
                je      @@1
                mov     MaxX, ah
                inc     bx
@@1:
                cmp     al, MaxY
                je      @@2
                mov     MaxY, al
                inc     bx
@@2:
                cmp     cx, CountOfLines
                je      @@3
                mov     CountOfLines, cx
                inc     bx
@@3:
                or      bx, bx
                jz      @@chbounds
@@01:
                mov     ax, cx
@@nochcur:
                cmp     ax, 16
                jne     @@no16lines
                mov     ax, offset OR_16
                mov     ClockAddres, offset COR_16
                jmp     short @@4
@@no16lines:
                cmp     ax, 14
                jne     @@8lines
                mov     ax, offset OR_14
                mov     ClockAddres, offset COR_14
                jmp     short @@4
@@8lines:
                mov     ax, offset OR_8
                mov     ClockAddres, offset COR_8
@@4:
                mov     CursorAddres, ax
                mov     bx, ax
                mov     ax, [bx - 4]
                mov     HotPointX, ax
                mov     ax, [bx - 2]
                mov     HotPointY, ax
@@chbounds:
                xor     dx, dx
                mov     dl, MaxX
                mov     cx, 3
                shl     dx, cl
                sub     dx, 4
                shl     dx, cl
                xor     cx, cx
                mov     ax, 7
                int     33h                     ; Set hor bound
                xor     ax, ax
                mov     al, MaxY
                mul     CountOfLines
                mov     dx, ax
                sub     dx, CountOfLines
                add     dx, 3
                mov     cx, 3
                shl     dx, cl
                xor     cx, cx
                mov     ax, 8
                int     33h                     ; Set vert bound
                cmp     WhatMouse, TextMouse
                je      @@nogo
                mov     ax, PMouseX
                mov     dx, PMouseY
                mov     cx, 3
                shl     ax, cl
                shl     dx, cl
                mov     cx, ax
                mov     ax, 4
                int     33h
@@nogo:
                mov     bIWork, si
                call    StoreChars
                cmp     WhatMouse, SmoothMouse
                jne     @@noupdate
                mov     cx, PMouseX
                mov     dx, PMouseY
                shl     cx, 1
                shl     cx, 1
                shl     cx, 1
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                xor     bx, bx
                call    NewHandler
@@noupdate:
                pop     bIWork

                ret
endp
;****************************************************************************;

proc            EnableSmoothMouse

                uses    ax, bx, cx, dx, si, di, es

                push    @data
                pop     ds
                cmp     WhatMouse, TextMouse
                JUMPS
                jne     @@exit
                NOJUMPS
                push    bIWork
                mov     bIWork, Yes
                mov     MaxY, -1
                call    GetVideoParams
                mov     ax, 2
                int     33h
                mov     ax, 0fh
                mov     cx, 1
                mov     dx, 1
                int     33h
                call    SetMyHandler
                xor     cx, cx
                xor     dx, dx
                cmp     bFirstCall, Yes
                je      @@fcall
                mov     ax, 3
                int     33h
                shr     cx, 1
                shr     cx, 1
                shr     cx, 1
                shr     dx, 1
                shr     dx, 1
                shr     dx, 1
                mov     MouseX, cx
                mov     MouseY, dx
                mov     bx, cx
                mov     cx, 6
                shl     bx, cl
                sub     cx, 3
                shl     dx, cl
                mov     cx, bx
                mov     ax, dx
                mul     CountOfLines
                mov     dx, ax
@@fcall:
                mov     ax, 4
                int     33h
                mov     WhatMouse, SmoothMouse
                xor     bx, bx
                call    NewHandler
                cmp     bFirstCall, Yes
                jne     @@nofcall
                call    far ptr CursorToClock
                mov     bFirstCall, No
@@nofcall:
                call    ShowSmoothMouse
                pop     bIWork
@@exit:
                ret
endp
;****************************************************************************;

proc            DisableSmoothMouse

                uses    ax, bx, cx, dx, si, di, ds

                push    @data
                pop     ds
                push    bIWork
                cmp     WhatMouse, SmoothMouse
                jne     @@exit
                mov     bIWork, Yes
                call    HideSmoothMouse
                call    RestoreChars
                call    RestoreHandler
                mov     WhatMouse, TextMouse
                xor     cx, cx
                xor     dx, dx
                mov     dl, MaxX
                dec     dx
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                mov     ax, 7
                int     33h
                xor     cx, cx
                xor     dx, dx
                mov     dl, MaxY
                dec     dx
                shl     dx, 1
                shl     dx, 1
                shl     dx, 1
                mov     ax, 8
                int     33h
                mov     cx, 8
                mov     dx, 16
                mov     ax, 0fh
                int     33h
                mov     cx, RealX
                mov     dx, RealY
                mov     ax, 4
                int     33h
                mov     ax, 1
                mov     cx, ShowCount
@@rep:
                int     33h
                loop    @@rep
@@exit:
                pop     bIWork

                ret
endp
;****************************************************************************;

proc            New33

                push    ds
                push    @data
                pop     ds
                cmp     bIWork, Yes
                je      @@notouch
                cli
                cmp     WhatMouse, SmoothMouse
                je      @@0
                cmp     ax, 7
                jne     @@notouch
                cmp     bFirstCall, Yes
                je      @@notouch
                call    ChangeFont9to8
                jmp     short @@notouch
@@0:
                or      ax, ax
                jz      @@01
                cmp     ax, 3
                je      @@01
                cmp     ax, 4
                jne     @@02
@@01:
                mov     bResident, Yes
                call    DisableSmoothMouse
                jmp     short @@notouch
@@02:
                cmp     ax, 1
                jne     @@1
                call    ShowSmoothMouse
                jmp     short @@exit
@@1:
                cmp     ax, 2
                jne     @@2
                call    HideSmoothMouse
                jmp     short @@exit
@@2:
                cmp     ax, 7
                jne     @@exit
                cmp     bFirstCall, Yes
                je      @@exit
                call    GetVideoParams
                jmp     short @@exit
@@notouch:
                pop     ds
                db      0eah
Old33           dd      0
@@exit:
                sti
                pop     ds

                iret
endp
;****************************************************************************;

proc            CursorToClockDelay

                arg     Time : word
                uses    ax

                push    ds
                push    @data
                pop     ds
                mov     ax, Time
                mov     DelayTime, ax
                pop     ds

                ret
endp
;****************************************************************************;

proc            CursorToClock

                uses    ax, ds, bx, si

                push    @data
                pop     ds
                cmp     WhatMouse, SmoothMouse
                jne     @@noclock
                cmp     CursorType, NormalCursor
                jne     @@noclock
                mov     ax, bCursorVisible
                call    HideSmoothMouse
                push    CursorAddres
                pop     OldCursor
                push    ClockAddres
                pop     CursorAddres
                mov     CursorType, ClockCursor
                cmp     ax, Yes
                jne     @@noclock
                call    ShowSmoothMouse
@@noclock:

                ret
endp
;****************************************************************************;

proc            ClockToCursor

                uses    ax, ds, bx, si, di

                push    @data
                pop     ds
                cmp     WhatMouse, SmoothMouse
                jne     @@noclock
                cmp     CursorType, NormalCursor
                je      @@noclock
                mov     ax, bCursorVisible
                call    HideSmoothMouse
                push    OldCursor
                pop     CursorAddres
                mov     CursorType, NormalCursor
                cmp     ax, Yes
                jne     @@noclock
                call    ShowSmoothMouse
@@noclock:

                ret
endp
;****************************************************************************;

proc            New16

                cmp     ah, 1
                jne     @@nofun
                cli
                push    ds
                push    @data
                pop     ds
                cmp     WhatMouse, SmoothMouse
                jne     @@noclock
                push    ax
                mov     ax, DelayTime
                mov     ClockDelay, ax
                pop     ax
                cmp     CursorType, NormalCursor
                je      @@noclock
                call    ClockToCursor
@@noclock:
                pop     ds
                sti
@@nofun:
                db      0eah
Old16           dd      0

endp
;****************************************************************************;

proc            New1C

                pushf
                db      9ah
Old1C           dd      0

                cli
                push    ds
                push    @data
                pop     ds
                cmp     WhatMouse, SmoothMouse
                jne     @@noclock
                cmp     CursorType, NormalCursor
                jne     @@noclock
                dec     ClockDelay
                jnz     @@noclock
                push    ax
                mov     ax, DelayTime
                mov     ClockDelay, ax
                pop     ax
                call    CursorToClock
@@noclock:
                sti
                push    ax
                mov     al, 20h
                out     20h, al
                pop     ax
                pop     ds

                iret
endp
;****************************************************************************;
end
