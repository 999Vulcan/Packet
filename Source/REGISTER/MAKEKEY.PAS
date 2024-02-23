{ Copyright (C) 1995,96 by VULCAN }
{ Изготовление ключей регистрации }

Program MakeKey;

uses Crt, Registr;

var
  Name, Company, FileName: String;

begin
  writeln;
  writeln('Integrator "Packet" v 3.15');
  writeln('Copyright (C) 1990-96 by VULCAN (Constantine Vulakh)');
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
