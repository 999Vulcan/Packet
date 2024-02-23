(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль EditServ                                        *)
(* Объекты хранения состояния закрытых окон редакторов    *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 16.04.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit EditServ;

interface

uses Objects, StrServ, PackText, StreamID;

type

  PClosedFile = ^TClosedFile;
  TClosedFile = object(TObject)
    Name: PString;
    CurPtr: Word;
    constructor Init(AName: String; ACurPtr: Word);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

  PClosedFilesColl = ^TClosedFilesColl;
  TClosedFilesColl = object(TCollection)
    constructor Init;
    procedure AddFile(Name: String; CurPtr: Word);
    function GetFileInfo(Name: String; var CurPtr: Word): boolean;
  end;

const
  RClosedFile: TStreamRec = (
     ObjType: idClosedFile;
     VmtLink: Ofs(TypeOf(TClosedFile)^);
     Load:    @TClosedFile.Load;
     Store:   @TClosedFile.Store
  );

  RClosedFilesColl: TStreamRec = (
     ObjType: idClosedFilesColl;
     VmtLink: Ofs(TypeOf(TClosedFilesColl)^);
     Load:    @TClosedFilesColl.Load;
     Store:   @TClosedFilesColl.Store
  );

function GetClosedFileName(CFColl: PClosedFilesColl; Num: Integer): FNameStr;

implementation

uses Views, App, Editors;

constructor TClosedFile.Init(AName: String; ACurPtr: Word);
begin
  inherited Init;
  Name := NewStr(AName);
  CurPtr := ACurPtr;
end;

destructor TClosedFile.Done;
begin
  DispStr(Name);
  inherited Done;
end;

constructor TClosedFile.Load(var S: TStream);
begin
  Name := S.ReadStr;
  S.Read(CurPtr, SizeOf(CurPtr));
end;

procedure TClosedFile.Store(var S: TStream);
begin
  S.WriteStr(Name);
  S.Write(CurPtr, SizeOf(CurPtr));
end;

constructor TClosedFilesColl.Init;
begin
  inherited Init(ClosedFilesCount, 0);
end;

procedure TClosedFilesColl.AddFile(Name: String; CurPtr: Word);

  function FileMatch(P: PClosedFile): boolean; far;
  begin
    FileMatch := GetStr(P^.Name) = Name;
  end;

var
  P: PClosedFile;
begin
  repeat
    P := FirstThat(@FileMatch);
    if Assigned(P)
      then Free(P);
  until not Assigned(P);

  if Count = ClosedFilesCount
    then AtFree(0);

  Insert(New(PClosedFile, Init(Name, CurPtr)));
end;

function TClosedFilesColl.GetFileInfo(Name: String;
                 var CurPtr: Word): boolean;

  function FileMatch(P: PClosedFile): boolean; far;
  begin
    FileMatch := GetStr(P^.Name) = Name;
  end;

var
  P: PClosedFile;
begin
  GetFileInfo := False;
  if Count = 0 then Exit;
  P := FirstThat(@FileMatch);
  if Assigned(P)
    then begin
      GetFileInfo := True;
      CurPtr := P^.CurPtr;
    end;
end;

function GetClosedFileName(CFColl: PClosedFilesColl; Num: Integer): FNameStr;
var
  FileName: FNameStr;
  N: String;
  AllCount, i, k: byte;

function FindWin(P: PView): boolean;
begin
  FindWin := (TypeOf(TEditWindow) = TypeOf(P^)) and
    FNamesEqual(PEditWindow(P)^.GetTitle(SizeOf(FNameStr)-1), FileName)
end;

begin
  i := 0; k := 0;
  AllCount := CFColl^.Count;
  GetClosedFileName := '';

  while i < AllCount do
  begin
    FileName := GetStr(PClosedFile(CFColl^.At(AllCount - i - 1))^.Name);
    while (Desktop^.FirstThat(@FindWin) <> nil) and (i < AllCount) do
    begin
      Inc(i);
      if i < AllCount then
        FileName := GetStr(PClosedFile(CFColl^.At(AllCount - i - 1))^.Name);
    end;
    Inc(i);
    Inc(k);
    if (i <= AllCount) and (k = Num)
      then begin
        GetClosedFileName := FileName;
        Exit;
      end;
  end;
end;

end.
