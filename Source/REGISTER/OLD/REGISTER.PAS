{$A+,B-,D+,E-,F+,G-,I-,L+,N-,O+,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$M 10000,10000,10000}

{ Copyright (C) 1995 by VULCAN }
{ Изготовление ключей регистрации }

Program Register;

uses Crt, Registr, TextProc, Objects, StrServ;

var
  Name, Company, Num: String;
  KeyFile: TTextFile;
  s: String;
  i: byte;

begin
  writeln;
  writeln('Integrator "Packet"  v. 3.06');
  writeln('Copyright (C) 1995 by VULCAN (Constantine Vulakh)');
  writeln('Registration Unit  v. 1.1');
  writeln;
  write('User name : ');
  readln(Name);
  write('Company   : ');
  readln(Company);
  write('Reg. No   : ');
  readln(Num);
  writeln;

  KeyFile.Init(GetExeDir + 'packet.key', 0, stCreate, 1024);
  if KeyFile.Status <> stOk
    then begin
      writeln('Error creating key file');
      Halt(1);
    end;

  for i := 1 to CountHeadlines do
    KeyFile.WriteString(Headlines[i]);

  KeyFile.WriteString(Name);
  KeyFile.WriteString(Company);
  KeyFile.WriteString(Num);

  KeyFile.Done;

  writeln('Key file created');
end.
