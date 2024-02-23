@Echo off
echo  
echo Компиляция файлов помощи к Интегратору "Packet"
echo  
echo Русский файл помощи
packethc packhelp.txt ..\bin\packet.hlp ..\pas\pack_hlp.pas
echo  
echo Английский файл помощи
packethc p_hlp_en.txt ..\bin\p_hlp_en.hlp nul
