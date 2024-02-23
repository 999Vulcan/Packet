{ Copyrignt (C) 1996 by VULCAN }

unit PackApi;

interface

procedure RegisterPacket;

implementation

uses
  Objects, Items, SubDirs, Dirs, Dir_Wind, PathStk, DirConf, Ann_Wind,
  HotKeys, StrStack;

procedure RegisterPacket;
begin
  RegisterType(RFileItem);
  RegisterType(RArchItem);
  RegisterType(RSubDirItem);
  RegisterType(RUpDirItem);
  RegisterType(RTextResource);
  RegisterType(RSubDir);
  RegisterType(RItemsCollection);
  RegisterType(RDirHandler);
  RegisterType(RPathStack);
  RegisterType(RPathItem);
  RegisterType(RDirConfig);
  RegisterType(RDirWindow);
  RegisterType(RDirectoryBox);
  RegisterType(RAnnViewer);
  RegisterType(RAnnWindow);
  RegisterType(RDirWinIndicator);

  RegisterType(RHotKeyRef);
  RegisterType(RStrStack);
end;

end.
