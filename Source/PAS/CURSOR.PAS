{ 28.04.1994 }
{$A+,B-,E-,F+,N-,O-,V-,X+,I-}
unit cursor;
interface
uses dos;
  procedure kn;
  procedure ky;
  procedure SetCursorSize(Siz:word);
  procedure HalfCursor;
  procedure FullCursor;
  procedure NoCursor;
  procedure YesCursor;
  procedure SetCurPos(X, Y: byte);

implementation
var
  CursX, CursY, CursBegin, CursEnd: byte;

Procedure SetCursorSize(Siz:word);
  Var Regs:Registers;
  begin
    with Regs do
      begin
        AH:=$01;
        CH:=Hi(Siz);
        CL:=Lo(Siz)
      end;
    Intr($10,Regs)
  end;

{
  **********************************************************************
  ****                   procedure kn                               ****
  **** ************************************************************ ****
  ****                  Гашение курсора                             ****
  **********************************************************************
}
  procedure kn;
  begin
    SetCursorSize($2000)
  end;
{
  **********************************************************************
  ****                   procedure ky                               ****
  **** ************************************************************ ****
  ****                  Восстановление курсора                      ****
  **********************************************************************
}
  procedure ky;
  Var Siz:word;
  begin
    if mem[Seg0040:$49] = 7
      then Siz:=$0B0C
      else Siz:=$0607;
    SetCursorSize(Siz)
  end;

  procedure HalfCursor;
  Var Siz:word;
  begin
    if mem[Seg0040:$49] = 7
      then Siz:=$090C
      else Siz:=$0407;
    SetCursorSize(Siz)
  end;

  procedure FullCursor;
  Var Siz:word;
  begin
    if mem[Seg0040:$49] = 7
      then Siz:=$000C
      else Siz:=$0007;
    SetCursorSize(Siz)
  end;

  procedure NoCursor;
  begin
    asm
      mov  ah,03h
      mov  bh,00h
      int  10h
      mov  CursY,dh
      mov  CursX,dl
      mov  CursBegin,ch
      mov  CursEnd,cl
    end;
    kn
  end;

  procedure YesCursor; assembler;
  asm
      mov  ah,2
      mov  bh,0
      mov  dh,CursY
      mov  dl,CursX
      int  10h
      mov  ah,1
      mov  ch,CursBegin
      mov  cl,CursEnd
      int  10h
  end;

  procedure SetCurPos(X, Y: byte); assembler;
  asm
      mov  ah,2
      mov  bh,0
      mov  dh,Y
      mov  dl,X
      dec  dh
      dec  dl
      int  10h
  end;

end.
