procedure TDirectoryBox.Annotate;
var
  R, ZoomRect: TRect;
  Num: Word;
  AnnW: PAnnWindow;
  EdWin: PAnnEdWindow;
  DirWind: PDirWindow;
  Cur: PView;
  MemoData: TShortMemoData;
  ResName: TResIndex;
  Resource: PTextResource;
  Cmd: Word;
begin
  if CountItems = 0 then Exit;

  Desktop^.Lock;  {!}
  Message(Application, evCommand, cmUnlockDesktop, nil);

  Cur := Desktop^.Current;
  AnnW := SearchAnnWindow;
  if not Assigned(AnnW)
    then begin
      Desktop^.GetExtent(R);
      R.A.X := R.B.X div 2;
      Application^.InsertWindow(New(PAnnWindow, Init(R)));
      AnnW := SearchAnnWindow;
    end;
  if not Assigned(AnnW) then Exit;

  MemoData.Length := 0;
  Resource := nil;
  GetAnnIndex(GetFocusedItem, ResName);
  if GetStr(ResName.Name) <> ''
    then begin
      Resource := Pointer(GetDirPtr^.ReadObj(ResName.Name^));
      MemoData.Length := Resource^.Length;
      if MemoData.Length > MaxTextResSize
        then begin
          DisposeObj(Resource);
          DoneResIndex(ResName);
          MessageBox(^C + Ph(phCantEditAnn), nil, mfError + mfOkButton,
                        hcCantEditAnn);
          Exit;
        end;
      if MemoData.Length > 0
        then Move(Resource^.Text^, MemoData.Buffer, MemoData.Length);
      DisposeObj(Resource);
    end;

  AnnW^.GetBounds(R);
  Num := AnnW^.Number;
  ZoomRect := AnnW^.ZoomRect;
  if Cur = PView(AnnW)
    then Cur := nil;

  Message(AnnW, evCommand, cmClose, nil);

  EdWin := New(PAnnEdWindow, Init(R, Num));
  EdWin^.ZoomRect := ZoomRect;
  EdWin^.SetData(MemoData);
  Cmd := Desktop^.ExecView(EdWin); { <------| }
  EdWin^.GetData(MemoData);
  EdWin^.GetBounds(R);
  ZoomRect := EdWin^.ZoomRect;
  DisposeObj(EdWin);

  Case Cmd of
    cmCancel: DoneResIndex(ResName);
    cmDelRes: begin
                if (not ResName.InhFlag) and (Assigned(ResName.Name))
                  then GetDirPtr^.DelObj(ResName.Name^);
                DoneResIndex(ResName);
                ResName.Place := pfNowhere;
                ResName.InhFlag := False;
                SetAnnIndex(GetFocusedItem, ResName);
                GetDirPtr^.UpdateHotKey(GetFocusedItem);
              end;
        cmOk: begin
                New(Resource, Init(MemoData.Length, MemoData.Buffer));
                if not Assigned(ResName.Name)
                  then begin
                    ResName.Place := pfDirFile;
                    ResName.InhFlag := False;
                    ResName.Name := NewStr(GetDirPtr^.GetNewIndex(
                                           tsAnnIndex, IndLen));
                    SetAnnIndex(GetFocusedItem, ResName);
                    GetDirPtr^.UpdateHotKey(GetFocusedItem);
                  end;
                GetDirPtr^.WriteObj(Resource, ResName.Name^);
                DoneResIndex(ResName);
                DisposeObj(Resource);
              end;
  end;

  Application^.InsertWindow(New(PAnnWindow, Init(R)));

  AnnW := SearchAnnWindow;
  AnnW^.Number := Num;
  AnnW^.ChangeBounds(R);
  AnnW^.ZoomRect := ZoomRect;

  if Assigned(Cur)
    then Cur^.Select;
  Desktop^.Redraw;
  Message(Application, evCommand, cmUnlockDesktop, nil);
  GetDirPtr^.Flush;
  ChangeAnn;
end;
