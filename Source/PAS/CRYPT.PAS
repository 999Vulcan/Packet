(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Crypt                                           *)
(* Шифровка данных                                        *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 14.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

Unit Crypt;

interface

uses Objects, StrServ;

const

  Mask = 133;

procedure CryptMem(var Buf; Count: Word; RandMask: boolean);
function CryptStr(S: String): String;
procedure WriteString(var S: TStream; P: PString);
function ReadString(var S: TStream): PString;

implementation

procedure CryptMem(var Buf; Count: Word; RandMask: boolean);
var
  MemArea: array[1..65520] of byte absolute Buf;
  i: Word;
  OldSeed: LongInt;
begin
  OldSeed := RandSeed;
  if RandMask
    then begin
      RandSeed := Count + Count div 3;
      for i := 1 to Count do
        MemArea[i] := MemArea[i] xor Random(256);
    end
  else for i := 1 to Count do
         MemArea[i] := MemArea[i] xor Mask;
  RandSeed := OldSeed;
end;

function CryptStr(S: String): String;
var
  i: byte;
begin
  if S <> #0
    then CryptMem(S[1], Length(S), True);
  CryptStr := S;
  for i := 1 to Length(S) do
    S[i] := chr(Random(256));
end;

procedure WriteString(var S: TStream; P: PString);
var
  PP: PString;
begin
  PP := NewStr(CryptStr(GetStr(P)));
  S.WriteStr(PP);
  DispStr(PP);
end;

function ReadString(var S: TStream): PString;
var
  P: PString;
begin
  P := S.ReadStr;
  ReadString := NewStr(CryptStr(GetStr(P)));
  DispStr(P);
end;

end.

