(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Blink                                           *)
(* Процедуры установки и сброса бита яркости              *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 21.07.1994                             *)
(* Корректирован : 21.07.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit Blink;

interface

  { установка 8 цветов для фона }
  procedure SetBlink;

  { установка 16 цветов для фона }
  procedure SetIntensity;

implementation

procedure SetBlink; assembler;
asm
  mov  ax, 1003h
  mov  bl, 1
  int  10h
end;

procedure SetIntensity; assembler;
asm
  mov  ax, 1003h
  xor  bl, bl
  int  10h
end;

end.
