{ Copyright (C) 1995 by VULCAN }
{ Изготовление ключей регистрации }

Program MakeKey;

uses Crt, Registr;

var
  Name, Company, FileName: String;

begin
  writeln;
  writeln('Integrator "Packet"');
  writeln('Copyright (C) 1995 by VULCAN (Constantine Vulakh)');
  writeln('Key file maker');
  writeln;
  write('User name : ');
  readln(Name);
  write('Company   : ');
  readln(Company);

  FileName := ParamStr(1);
  if FileName = ''
    then FileName := 'packet.key';

  BuildKeyFile(Name, Company, FileName);
  writeln(#13#10, 'Key file created');
end.
