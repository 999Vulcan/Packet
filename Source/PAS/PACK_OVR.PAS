(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Pack_Ovr                                        *)
(* Работа с оверлеями                                     *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 03.03.1993                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit Pack_Ovr;

interface

uses

  Overlay, Views, App, MyMsgBox, Language, PackLng, PackText, Dos, StrServ;

  function InitPackOvr: boolean;

implementation

uses PMApp;

const

  { Размер буфера оверлеев }
  OvrBufSize = 100 * 1024;

  OvrFileName = 'PackMain.Ovr';

var

  SaveOvrRead: OvrReadFunc;

function PackOvrRead(OvrSeg: Word): Integer;
begin
  if SaveOvrRead(OvrSeg) <> 0
    then begin
      CriticalArea := True;
      MessageBox(^M^C + Ph(phOvrReadError), nil,
        mfError + mfOkButton + mfInsertInApp, hcNoContext);
      Application^.Done;
      Halt;
    end;
  PackOvrRead := 0;
end;

function CalcOvrName: PathStr;
begin
  CalcOvrName := GetExeDir + OvrFileName;
end;

function InitPackOvr: boolean;
begin
  OvrInit(GetExeName);
  if OvrResult <> OvrOk
    then OvrInit(CalcOvrName);

  OvrSetBuf(OvrBufSize);

  OvrSetRetry(OvrGetBuf div 3);

  SaveOvrRead := OvrReadBuf;
  OvrReadBuf := PackOvrRead;

  InitPackOvr := OvrResult = OvrOk;
end;


end.

