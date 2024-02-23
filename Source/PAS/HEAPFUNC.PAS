(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль HeapFunc                                        *)
(* Функция обработки ошибок кучи                          *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 03.03.1994                             *)
(* Корректирован : 12.09.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit HeapFunc;

interface

implementation

function HeapErrFunc(Size: Word): Integer; far;
begin
  HeapErrFunc := 1;
end;

begin
  HeapError := @HeapErrFunc;
end.

