(**********************************************************)
(*                                                        *)
(* ��⥣��� "Packet"                                    *)
(*                                                        *)
(* ����� Blink                                           *)
(* ��楤��� ��⠭���� � ��� ��� �મ��              *)
(*                                                        *)
(* ���� : ����⠭⨭ �㫠�                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* ����         : 21.07.1994                             *)
(* ���४�஢�� : 21.07.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit Blink;

interface

  { ��⠭���� 8 梥⮢ ��� 䮭� }
  procedure SetBlink;

  { ��⠭���� 16 梥⮢ ��� 䮭� }
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
