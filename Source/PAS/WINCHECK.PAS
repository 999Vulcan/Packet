(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль WinCheck                                        *)
(* Взаимодействие с MS Windows и OS/2                     *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 28.08.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit WinCheck;

interface

function OS2Active: boolean;
function WindowsActive: boolean;
procedure GetWindowsVer(var Lo, Hi: byte);
procedure ReleaseTimeSlice;

implementation

uses dos;


procedure ReleaseTimeSlice; assembler;
asm
  mov   ax, 1680h
  int   2Fh
end;

function OS2Active: boolean;
var
  Regs: Registers;
begin
  with Regs do
  begin
    AX := $4010;
    Intr($2F, Regs);
    OS2Active := AX <> $4010;
  end;
end;

function WindowsActive: boolean;
var
  Lo, Hi: byte;
begin
  GetWindowsVer(Lo, Hi);
  WindowsActive := Hi <> 0;
end;

procedure GetWindowsVer(var Lo, Hi: byte);
var
  Regs: Registers;
begin
  with Regs do
  begin
    AX := $1600;
    Intr($2F, Regs);
    Lo := AH;
    Hi := AL;
  end;
end;

end.
