unit FileHist;
interface
 uses  Objects, Drivers, Dialogs;
 type
  PFileHistory = ^TFileHistory;
  TFileHistory = object(THistory)
   procedure HandleEvent(var Event: TEvent); virtual;
   procedure RecordHistory(const S: String); virtual;
  end;

 const
  RFileHistory: TStreamRec = (
     ObjType: 900;
     VmtLink: Ofs(TypeOf(THistory)^);
     Load:    @THistory.Load;
     Store:   @THistory.Store
  );

 procedure RegisterFileHist;

implementation

uses Dos, Views, HistList, StdDlg, StrServ;

{ TFileHistory }

procedure TFileHistory.HandleEvent(var Event: TEvent);
var
  HistoryWindow: PHistoryWindow;
  R,P: TRect;
  C: Word;
  Rslt: String;
  S,Wild : String;
begin
  TView.HandleEvent(Event);
  if (Event.What = evMouseDown) or
     ((Event.What = evKeyDown) and (CtrlToArrow(Event.KeyCode) = kbDown) and
      (Link^.State and sfFocused <> 0)) then
  begin
    if not Link^.Focus then
    begin
      ClearEvent(Event);
      Exit;
    end;
    RecordHistory(Link^.Data^);
    Link^.GetBounds(R);
    Dec(R.A.X); Inc(R.B.X); Inc(R.B.Y,7); Dec(R.A.Y,1);
    Owner^.GetExtent(P);
    R.Intersect(P);
    Dec(R.B.Y,1);
    HistoryWindow := InitHistoryWindow(R);
    if HistoryWindow <> nil then
    begin
      C := Owner^.ExecView(HistoryWindow);
      if C = cmOk then
      begin
        Rslt := HistoryWindow^.GetSelection;
        S := GetCurDir;
        if Rslt[1] = '\' then Rslt := Concat(Copy(S,1,2),Rslt)
        else if Rslt[2] <> ':' then Rslt := Concat(S,Rslt);
        if Length(Rslt) > Link^.MaxLen then Rslt[0] := Char(Link^.MaxLen);
        Link^.Data^ := Rslt;
        Link^.SelectAll(True);
        Link^.DrawView;
      end;
      Dispose(HistoryWindow, Done);
    end;
    ClearEvent(Event);
  end
  else if (Event.What = evBroadcast) then
    if ((Event.Command = cmReleasedFocus) and (Event.InfoPtr = Link))
      or (Event.Command = cmRecordHistory) then
    RecordHistory(Link^.Data^);
end;

procedure TFileHistory.RecordHistory(const S: String);
const
  CurWild = '*.*';
var
  Dir,CurDir : String;
  Wild : String;
  Rslt : String;
  D : DirStr;
  N : NameStr;
  E : ExtStr;
  I,J : Integer;
begin
  Rslt := S;
  Dir := PFileDialog(Owner)^.Directory^;
  CurDir := GetCurDir;
  Wild := FullTrim(PFileDialog(Owner)^.WildCard);
  if Length(Wild) = 0 then Wild := CurWild;
  if S[2] = ':' then
  begin
   FSplit(S, D, N, E);
   if (not IsWild(S)) and (Length(Concat(N, E)) = 0)
   then Rslt := Concat(S,Wild);
  end
  else
   if CurDir[1] = Dir[1] then
   begin
    if Copy(S,2,2) <> ':\' then
    begin
     FSplit(Dir, D, N, E);
     I := Length(D) - Length(CurDir);
     J := Pos(CurDir, Dir);
     if J > 0 then
     begin
      if I > 0 then Rslt := Concat(Copy(D,Length(D)-I+1,I),Rslt)
     end
     else Rslt := Concat(Copy(D,3,Length(D)-2),Rslt);
    end;
   end
   else
   begin
    if PathValid(S) then Rslt := Concat(Dir,Wild);
    if Copy(S,2,2) <> ':\' then Rslt := Concat(Dir,S);
   end;
  I := Pos('..', Rslt);
  if I > 1 then
  begin
   Delete(Rslt, I - 1, 255);
   Dec(I, 2);
   while (I > 0) and (Rslt[I] <> '\') do
   begin
    Delete(Rslt, I, 1);
    Dec(I);
   end;
   Rslt := Concat(Rslt, Wild);
  end;
  HistoryAdd(HistoryId, Rslt);
end;

procedure RegisterFileHist;
begin
  RegisterType(RFileHistory);
end;

end.
