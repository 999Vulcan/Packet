(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль DskStack                                        *)
(* Объект DskStack - просмотр стека состояний             *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 08.11.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit DskStack;

interface

uses
  Objects, StrStack, Views, Dialogs, StrServ, PackLng, Language, Pack_Hlp,
  XListBox;

type

  PDskStackList = ^TDskStackList;
  TDskStackList = object(TXListBox)
    Stack: PStrStack;

    constructor Init(var Bounds: TRect; AVScrollBar: PScrollBar;
                     AStack: PStrStack);
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
  end;

  PDskStackDlg = ^TDskStackDlg;
  TDskStackDlg = object(TDialog)
    DskList: PDskStackList;

    constructor Init(Stack: PStrStack);
    procedure GetData(var Rec); virtual;
    function DataSize: Word; virtual;
  end;

implementation

constructor TDskStackDlg.Init(Stack: PStrStack);
var
  R: TRect;
  Control: PView;
begin
  R.Assign(0, 0, 61, 16);
  inherited Init(R, Ph(phDskStackDlgTitle));
  Options := Options or ofCentered;
  HelpCtx := hcDskListDlg;

  R.Assign(44, 4, 45, 14);
  Control:=New(PScrollBar,Init(R));
  Insert(Control);

  R.Assign(46, 4, 58, 6);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOK, bfDefault)));
  Inc(R.A.Y, 3); Inc(R.B.Y, 3);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  Inc(R.A.Y, 6); Inc(R.B.Y, 6);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));

  R.Assign(3, 4, 44, 14);
  New(DskList, Init(R, PScrollBar(Control), Stack));
  Insert(DskList);
  R.Assign(3, 2, 44, 3);
  Insert(New(PLabel, Init(R, Ph(phCDskStackList), DskList)));
end;

procedure TDskStackDlg.GetData(var Rec);
var
  Str: FNameStr absolute Rec;
begin
  Str := GetStr(DskList^.Stack^.At(DskList^.Focused));
end;

function TDskStackDlg.DataSize: Word;
begin
  DataSize := SizeOf(FNameStr);
end;

constructor TDskStackList.Init(var Bounds: TRect; AVScrollBar: PScrollBar;
                               AStack: PStrStack);
begin
  inherited Init(Bounds, nil, AVScrollBar);
  Stack := AStack;
  Range := Stack^.Count - 1;
  Options := Options or ofFramed;
  VScrollBar^.SetRange(0, Range - 1);
  FocusItem(Range - 1);
end;

function TDskStackList.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText := GetShortFName(GetStr(Stack^.At(Item)), MaxLen - 3);
end;

end.
