(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Disp_Obj                                        *)
(* Процедура удаления объекта из памяти                   *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 12.09.1994                             *)
(* Корректирован : 12.09.1994                             *)
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
