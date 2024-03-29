(**********************************************************)
(*                                                        *)
(* ����� Language                                        *)
(*                                                        *)
(* ���� : ����⠭⨭ �㫠�                               *)
(* Copyright (C) 1993-95 by VULCAN                        *)
(*                                                        *)
(* ����         : 15.11.1993                             *)
(*                                                        *)
(**********************************************************)

(**********************************************************)
(*   �ᯮ�짮��� ID ��ꥪ� 65000                         *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

Unit Language;

interface

uses Objects, LineColl,
{$ifdef ForPacket}
     Crypt,
{$endif}
     Disp_Obj;

type

  PPhraseList = ^TPhraseList;
  TPhraseList = object(TLineCollection)
    ChkSum: Word;
    constructor Init(ALimit, ADelta: Integer);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream); virtual;
    procedure PutItem(var S: TStream; Item: Pointer); virtual;
    function GetItem(var S: TStream): Pointer; virtual;
    function CalcChkSum: Word;
    procedure SetChkSum;
    function ChkIntegrity: boolean;
  end;

const

  { ���� �⥭�� ᯨ᪠ ��ப ��楤�ன ReadLanguage : }
  rtFile      = 0; { ����� �� 䠩�� � 㪠����� ������ }
  rtExe       = 1; { ����� �� EXE-䠩��, 㪠������ ��� �����஢��� }
  rtFile_Exe  = 2; { ����� ᯮᮡ�� rtFile, � � ��砥 �訡�� -
                     ������� ᯮᮡ�� rtExe }

  { �ਧ��� �訡�� "����� �� ������" ( ������ 䠩� ᮮ�饭�� ) }
  stResourceNotFound = -10;
  stCheckSumError    = -11;

  PhraseList: PPhraseList = nil;
  LngReadError: Integer = stOk;


  RPhraseList: TStreamRec = (
     ObjType: 65000;
     VmtLink: Ofs(TypeOf(TPhraseList)^);
     Load:    @TPhraseList.Load;
     Store:   @TPhraseList.Store
  );


function Ph(Index: Integer): String;
function PhPtr(Index: Integer): PString;
procedure ReadPhraseList(FileName, SignStr: String);
procedure ReadLanguage(FileName, SignStr: String; ReadType: byte);
procedure FreePhraseList;

implementation

{ TPhraseList }

constructor TPhraseList.Init(ALimit, ADelta: Integer);
begin
  inherited Init(ALimit, ADelta);
  ChkSum := 0;
end;

constructor TPhraseList.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(ChkSum, SizeOf(ChkSum));
end;

procedure TPhraseList.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(ChkSum, SizeOf(ChkSum));
end;

procedure TPhraseList.PutItem(var S: TStream; Item: Pointer);
begin
{$ifdef ForPacket}
  PString(Item)^ := CryptStr(PString(Item)^);
{$endif}
  inherited PutItem(S, Item);
{$ifdef ForPacket}
  PString(Item)^ := CryptStr(PString(Item)^);
{$endif}
end;

function TPhraseList.GetItem(var S: TStream): Pointer;
var
  Item: PString;
begin
  Item := inherited GetItem(S);
{$ifdef ForPacket}
  Item^ := CryptStr(Item^);
{$endif}
  GetItem := Item;
end;

function TPhraseList.CalcChkSum: Word;
var
  i, j: Integer;
  st: String;
  S: Word;
begin
  S := 0;
  for i := 0 to Count - 1 do
    begin
      st := AtStr(i);
      for j := 1 to Length(st) do
        Inc(S, ord(st[j]) xor j);
    end;
  CalcChkSum := S;
end;

procedure TPhraseList.SetChkSum;
begin
  ChkSum := CalcChkSum;
end;

function TPhraseList.ChkIntegrity: boolean;
begin
  ChkIntegrity := ChkSum = CalcChkSum;
end;

function Ph(Index: Integer): String;
var
  P: PString;
begin
  P := PhPtr(Index);
  if Assigned(P)
    then Ph := P^
    else Ph := '';
end;

function PhPtr(Index: Integer): PString;
begin
  if (LngReadError = 0) and (Index >= 0) and Assigned(PhraseList)
    and (Index < PhraseList^.Count)
      then PhPtr := PhraseList^.At(Index)
      else PhPtr := nil;
end;

procedure ReadPhraseList(FileName, SignStr: String);
var
  P: PResourceFile;
  tmpP: PPhraseList;
begin
  New(P, Init(New(PBufStream, Init(FileName, stOpenRead, 1024))));
  if not Assigned(P)
    then begin
      LngReadError := stResourceNotFound;
      Exit;
    end;

  tmpP := PPhraseList(P^.Get(SignStr));
  LngReadError := P^.Stream^.Status;

  if (not Assigned(tmpP)) and (LngReadError = stOk)
    then LngReadError := stResourceNotFound;
  if (LngReadError = stOk) and (not tmpP^.ChkIntegrity)
    then LngReadError := stCheckSumError;

  if Assigned(tmpP) and (LngReadError = stOk)
    then begin
      FreePhraseList;
      PhraseList := tmpP;
    end
  else DisposeObj(tmpP);
  DisposeObj(P);
end;

procedure ReadLanguage(FileName, SignStr: String; ReadType: byte);
begin
  Case ReadType of
        rtFile: ReadPhraseList(FileName, SignStr);
         rtExe: ReadPhraseList(ParamStr(0), SignStr);
    rtFile_Exe: begin
                  ReadPhraseList(FileName, SignStr);
                  if LngReadError <> 0 then
                    ReadPhraseList(ParamStr(0), SignStr);
                end;
  end;
end;

procedure FreePhraseList;
begin
  DisposeObj(PhraseList)
end;

begin
  RegisterType(RPhraseList);
end.

