{  Описывает глобальшную переменную -        }
{  признак чтения временного файла состояния }

unit TempFlag;

interface

uses Objects;

var
  ReadingTmpDsk: boolean;
  CurrentDskName: FNameStr;
  DiskTypes: array['A'..'Z'] of byte;

implementation

end.
