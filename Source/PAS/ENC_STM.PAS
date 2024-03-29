(**********************************************************)
(*                                                        *)
(* ��⥣��� "Packet"                                    *)
(*                                                        *)
(* ����� Enc_Stm                                         *)
(* ��ꥪ� TEncStream ( ��⮪ � ��஢����� )              *)
(*                                                        *)
(* ���� : ����⠭⨭ �㫠�                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* ����         : 19.05.1994                             *)
(* ���४�஢�� : 31.05.1994                             *)
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
