(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Video                                           *)
(* Работа с видеорежимами                                 *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 17.12.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit Video;

interface

procedure SetVM(Mode: Word);
procedure VideoInt;

implementation

uses Drivers;

var
  Equipment: Word absolute $40:$10;
  CrtRows: Byte absolute $40:$84;
  CrtInfo: Byte absolute $40:$87;

const

{ Screen modes }

  smBW80    = $0002;
  smCO80    = $0003;
  smMono    = $0007;
  smFont8x8 = $0100;

{ Save registers and call video interrupt }

{$F-}
procedure VideoInt; assembler;
asm
        PUSH    BP
        PUSH    ES
        INT     10H
        POP     ES
        POP     BP
end;
{$F+}

{ Set CRT mode to value in AX }

procedure SetCrtMode; near; assembler;
asm
        MOV     ES,Seg0040
        MOV     BL,20H
        CMP     AL,smMono
        JNE     @@1
        MOV     BL,30H
@@1:    AND     ES:Equipment.Byte,0CFH
        OR      ES:Equipment.Byte,BL
        AND     ES:CrtInfo,0FEH
        PUSH    AX
        MOV     AH,0
        CALL    VideoInt
        POP     AX
        OR      AH,AH
        JE      @@2
        MOV     AX,1112H
        MOV     BL,0
        CALL    VideoInt
        MOV     AX,1130H
        MOV     BH,0
        MOV     DL,0
        CALL    VideoInt
        CMP     DL,42
        JNE     @@2
        OR      ES:CrtInfo,1
        MOV     AH,1
        MOV     CX,600H
        CALL    VideoInt
        MOV     AH,12H
        MOV     BL,20H
        CALL    VideoInt
@@2:
end;

{ Return CRT mode in AX and dimensions in DX }

procedure GetCrtMode; near; assembler;
asm
        MOV     AH,0FH
        CALL    VideoInt
        PUSH    AX
        MOV     AX,1130H
        MOV     BH,0
        MOV     DL,0
        CALL    VideoInt
        POP     AX
        MOV     DH,AH
        CMP     DL,25
        SBB     AH,AH
        INC     AH
end;

{ Set CRT data areas and mouse range }

procedure SetCrtData; near; assembler;
asm
        CALL    GetCrtMode
        MOV     CL,1
        OR      DL,DL
        JNE     @@1
        MOV     CL,0
        MOV     DL,24
@@1:    INC     DL
        MOV     ScreenMode,AX
        MOV     ScreenWidth,DH
        MOV     ScreenHeight,DL
        MOV     HiResScreen,CL
        XOR     CL,1
        MOV     BX,SegB800
        CMP     AL,smMono
        JNE     @@2
        MOV     CL,0
        MOV     BX,SegB000
@@2:    MOV     CheckSnow,CL
        XOR     AX,AX
        MOV     ScreenBuffer.Word[0],AX
        MOV     ScreenBuffer.Word[2],BX
        MOV     AH,3
        MOV     BH,0
        CALL    VideoInt
        MOV     CursorLines,CX
        MOV     AH,1
        MOV     CX,2000H
        CALL    VideoInt
        CMP     ButtonCount,0
        JE      @@4
        MOV     AX,7
        MOV     DL,ScreenWidth
        CALL    @@3
        MOV     AX,8
        MOV     DL,ScreenHeight
@@3:    XOR     DH,DH
        MOV     CL,3
        SHL     DX,CL
        DEC     DX
        XOR     CX,CX
        INT     33H
@@4:
end;

procedure SetVM(Mode: Word); assembler;
asm
        MOV     AX,Mode
        CALL    SetCrtMode
        CALL    SetCrtData
end;

end.
