{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit OS2Lnch;

interface

uses Dos, Strings;

function LaunchOS2Session(InWin: boolean; ProgName: PathStr;
                          Params: ComStr; ProgTitle: String): boolean;

implementation

function LaunchOS2Session(InWin: boolean; ProgName: PathStr;
                          Params: ComStr; ProgTitle: String): boolean;
var
  VDMData: record
    Length: Word;
    IndepFlag: Word;
    ForegrFlag: Word;
    TraceFlag: Word;
    Title: PChar;
    Name: PChar;
    Args: PChar;
    TermQ: LongInt;
    EnvPtr: Pointer;
    Inheritance: Word;
    SessionType: Word;
  end;
  PrName: array[0..79] of Char;
  PrArgs: array[0..127] of Char;
  PrTitle: array[0..62] of Char;
  Segm, Offs: Word;
begin
  LaunchOS2Session := True;
  with VDMData do
  begin
    Length := $20;
    IndepFlag := 0;  { Независимый процесс }
    ForegrFlag := 0; { Нефоновый режим }
    TraceFlag := 0;  { Нет трассировки }
    Title := StrPCopy(PrTitle, Copy(ProgTitle, 1, 62));
    Name := StrPCopy(PrName, Copy(ProgName, 1, 127));
    Args := StrPCopy(PrArgs, Copy(Params, 1, 127));
    TermQ := 0;      { Зарезервировано }
    EnvPtr := nil;
    Inheritance := 0; { Не знаю, что это такое }
    if InWin
      then SessionType := 3
    else SessionType := 3;
  end;
  Segm := Seg(VDMData);
  Offs := Ofs(VDMData);

  asm
    mov   ah, 64h
    mov   bx, 25h
    mov   cx, 636Ch
    mov   ds, Segm
    mov   si, Offs
    int   21h
    cmp   ax, 0
    jne   @@1
    mov   ax, 1
@@1:
  end;
end;

end.
