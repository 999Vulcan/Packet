(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль SysError                                        *)
(* Подпрограмма реакции на системную ошибку               *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 16.11.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit SysError;

interface

function PackSystemError(ErrorCode: Integer; Drive: Byte): Integer;

implementation

uses Objects, Drivers, Pack_Cmd, Video;

const

{ System error messages }

  SCriticalError:  string[31] = 'Critical disk error on drive %c';
  SWriteProtected: string[35] = 'Disk is write-protected in drive %c';
  SDiskNotReady:   string[29] = 'Disk is not ready in drive %c';
  SDataIntegrity:  string[32] = 'Data integrity error on drive %c';
  SSeekError:      string[22] = 'Seek error on drive %c';
  SUnknownMedia:   string[30] = 'Unknown media type in drive %c';
  SSectorNotFound: string[28] = 'Sector not found on drive %c';
  SOutOfPaper:     string[20] = 'Printer out of paper';
  SWriteFault:     string[23] = 'Write fault on drive %c';
  SReadFault:      string[22] = 'Read fault on drive %c';
  SGeneralFailure: string[28] = 'Hardware failure on drive %c';
  SBadImageOfFAT:  string[32] = 'Bad memory image of FAT detected';
  SDeviceError:    string[19] = 'Device access error';
  SInsertDisk:     string[27] = 'Insert diskette in drive %c';
  SRetryOrCancel:  string[27] = '~Enter~ Retry  ~Esc~ Cancel';

{ Critical error message translation table }

  ErrorString: array[0..15] of Word = (
    Ofs(SWriteProtected),
    Ofs(SCriticalError),
    Ofs(SDiskNotReady),
    Ofs(SCriticalError),
    Ofs(SDataIntegrity),
    Ofs(SCriticalError),
    Ofs(SSeekError),
    Ofs(SUnknownMedia),
    Ofs(SSectorNotFound),
    Ofs(SOutOfPaper),
    Ofs(SWriteFault),
    Ofs(SReadFault),
    Ofs(SGeneralFailure),
    Ofs(SBadImageOfFAT),
    Ofs(SDeviceError),
    Ofs(SInsertDisk));

procedure SwapStatusLine(var Buffer); near; assembler;
asm
        MOV     CL,ScreenWidth
        XOR     CH,CH
        MOV     AL,ScreenHeight
        DEC     AL
        MUL     CL
        SHL     AX,1
        LES     DI,ScreenBuffer
        ADD     DI,AX
        PUSH    DS
        LDS     SI,Buffer
@@1:    MOV     AX,ES:[DI]
        MOVSW
        MOV     DS:[SI-2],AX
        LOOP    @@1
        POP     DS
end;

function SelectKey: Integer; near; assembler;
asm
        MOV     AH,3
        MOV     BH,0
        CALL    VideoInt
        PUSH    CX
        MOV     AH,1
        MOV     CX,2000H
        CALL    VideoInt
@@1:    MOV     AH,1
        INT     16H
        PUSHF
        MOV     AH,0
        INT     16H
        POPF
        JNE     @@1
        XOR     DX,DX
        CMP     AL,13
        JE      @@2
        INC     DX
        CMP     AL,27
        JNE     @@1
@@2:    POP     CX
        PUSH    DX
        MOV     AH,1
        CALL    VideoInt
        POP     AX
end;

function SystemError(ErrorCode: Integer; Drive: Byte): Integer;
var
  C: Word;
  P: Pointer;
  S: string[63];
  B: array[0..132] of Word;
begin
  if FailSysErrors then
  begin
    SystemError := 1;
    Exit;
  end;

  if Lo(ScreenMode) = smMono then
    C := SysMonoAttr else
    C := SysColorAttr;
  P := Pointer(Drive + Ord('A'));
  FormatStr(S, PString(Ptr(DSeg, ErrorString[ErrorCode]))^, P);
  MoveChar(B, ' ', Byte(C), 132);
  MoveCStr(B[1], S, C);
  MoveCStr(B[ScreenWidth - CStrLen(SRetryOrCancel) - 1], SRetryOrCancel, C);
  SwapStatusLine(B);
  SystemError := SelectKey;
  SwapStatusLine(B);
end;

function PackSystemError(ErrorCode: Integer; Drive: Byte): Integer;
var
  Code: Word;
begin
  Code := SystemError(ErrorCode, Drive);
  if Drive in [0,1]
    then PackSystemError := 0
    else PackSystemError := Code;
end;

end.
