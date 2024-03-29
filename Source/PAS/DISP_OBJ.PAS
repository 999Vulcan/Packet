(**********************************************************)
(*                                                        *)
(* ��⥣��� "Packet"                                    *)
(*                                                        *)
(* ����� Disp_Obj                                        *)
(* ��楤�� 㤠����� ��ꥪ� �� �����                   *)
(*                                                        *)
(* ���� : ����⠭⨭ �㫠�                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* ����         : 12.09.1994                             *)
(* ���४�஢�� : 12.09.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X-,I-}

unit Disp_Obj;

interface

uses Objects;

procedure DisposeObj(var Ptr);

implementation

procedure DisposeObj(var Ptr);
var
  P: PObject absolute Ptr;
begin
  if Assigned(P)
    then begin
      Dispose(P, Done);
      P := nil;
    end;
end;

end.
