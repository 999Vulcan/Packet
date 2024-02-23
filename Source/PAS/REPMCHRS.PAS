{*********************************************************************}
{                                                                     }
{       Turbo Pascal Version 7.0                                      }
{       Замена символов мыши                                          }
{                                                                     }
{       Copyright (c) 1995 by VULCAN ( Constantine Vulakh )           }
{                                                                     }
{       Начат : 11.01.95                                              }
{                                                                     }
{*********************************************************************}
{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit RepMChrs;

interface

const

  MouseCharsSet: set of char = [#1, #2, #5, #6];

procedure ReplCharsInStr(var S: String);

implementation

uses PackText;

procedure ReplCharsInStr(var S: String);
var
  i: byte;
begin
  for i := 1 to Length(S) do
    if S[i] in MouseCharsSet
      then S[i] := chr(tsReplCharNo);
end;

end.
