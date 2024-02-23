@Echo off
cd ..\bin
if exist packmain.ovr goto continue
rem goto continue
echo ú
echo PackMain is already compressed
goto end
:continue
pklite -e packmain.exe
copy /b packmain.exe + packmain.ovr + russian.lng > nul
rem copy /b packmain.exe + packmain.ovr + english.lng > nul
del packmain.ovr
:end
dir *.exe
cd ..\work
