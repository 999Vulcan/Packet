(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Enc_Stm                                         *)
(* Объект TEncStream ( поток с шифрованием )              *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 19.05.1994                             *)
(* Корректирован : 31.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit Enc_Stm;

interface

uses
  Objects, Crypt;

type

  PEncStream = ^TEncStream;
  TEncStream = object(TBufStream)
    procedure Write(var Buf; Count: Word); virtual;
    procedure Read(var Buf; Count: Word); virtual;
  end;

implementation

procedure TEncStream.Write(var Buf; Count: Word);
begin
  CryptMem(Buf, Count, False);
  inherited Write(Buf, Count);
  CryptMem(Buf, Count, False);
end;

procedure TEncStream.Read(var Buf; Count: Word);
begin
  inherited Read(Buf, Count);
  CryptMem(Buf, Count, False);
end;

end.
