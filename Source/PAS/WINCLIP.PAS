{$A+,B-,D+,E-,F+,G-,I-,L+,N-,O+,P-,Q-,T-,V-,X+,Y+}
unit WinClip;

interface

uses Dos;

  function ClipFnsAvail: boolean;
  procedure PutInClip(P: PChar; Len: Word);
  function GetFromClip(var P: PChar; var Len: Word): boolean;

implementation

procedure ExecClipFn(var AX: Integer);
var
  Regs: Registers;
begin
  Regs.AX := AX;
  Intr($2F, Regs);
  AX := Regs.AX;
end;

function ClipFnsAvail: boolean;
var
  AX: integer;
begin
  AX := $1700;
  ExecClipFn(AX);
  ClipFnsAvail := AX <> $1700;
end;

function GainClip: boolean;
var
  AX: integer;
begin
  AX := $1701;
  ExecClipFn(AX);
  GainClip := AX <> 0;
end;

function ReleaseClip: boolean;
var
  AX: integer;
begin
  AX := $1708;
  ExecClipFn(AX);
  ReleaseClip := AX <> 0;
end;

function ClearClip: boolean;
var
  AX: integer;
begin
  AX := $1702;
  ExecClipFn(AX);
  ClearClip := AX <> 0;
end;

procedure PutInClip(P: PChar; Len: Word);
var
  Regs: Registers;
begin
  if not ClipFnsAvail then Exit;
  if not GainClip then Exit;
  if ClearClip
    then begin
      Regs.AX := $1709;
      Regs.SI := 0;
      Regs.CX := Len;
      Intr($2F, Regs);
      if (Regs.AX = 0) and (Regs.DX = 0) then Exit;  {No memory}
      Regs.AX := $1703;
      Regs.DX := $1;  {Text}
      Regs.SI := 0;
      Regs.CX := Len;
      Regs.ES := Seg(P^);
      Regs.BX := Ofs(P^);
      Intr($2F, Regs);  {Copy}
    end;
  ReleaseClip;
end;

function GetFromClip(var P: PChar; var Len: Word): boolean;
var
  Regs: Registers;
begin
  GetFromClip := False;
  Len := 0;
  if not ClipFnsAvail then Exit;
  if not GainClip then Exit;
  Regs.AX := $1704;
  Regs.DX := $1;  {text}
  Intr($2F, Regs);
  if (Regs.DX = 0) and (Regs.AX > 0)
    then begin
      Len := Regs.AX;
      GetMem(P, Len);
      Regs.AX := $1705;
      Regs.DX := $1;  {text}
      Regs.ES := Seg(P^);
      Regs.BX := Ofs(P^);
      Intr($2F, Regs);
    end;
  if not ReleaseClip then Exit;
  GetFromClip := True;
end;

end.
