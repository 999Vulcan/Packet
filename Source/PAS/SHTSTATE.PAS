(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль ShtState                                        *)
(* Переменная BIOS - shift state                          *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 13.11.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,D+,E-,F+,G-,I-,L+,N-,O-,P-,Q-,T-,V-,X+,Y+}

unit ShtState;

interface

uses Drivers;

function AltDown: boolean;
function CtrlDown: boolean;
function ShiftDown: boolean;
function RightShiftDown: boolean;
function LeftShiftDown: boolean;

implementation

function AltDown: boolean;
begin
  AltDown := GetShiftState and kbAltShift <> 0;
end;

function CtrlDown: boolean;
begin
  CtrlDown := GetShiftState and kbCtrlShift <> 0;
end;

function ShiftDown: boolean;
begin
  ShiftDown := GetShiftState and (kbLeftShift + kbRightShift) <> 0;
end;

function LeftShiftDown: boolean;
begin
  LeftShiftDown := GetShiftState and kbLeftShift <> 0;
end;

function RightShiftDown: boolean;
begin
  RightShiftDown := GetShiftState and kbRightShift <> 0;
end;

end.
