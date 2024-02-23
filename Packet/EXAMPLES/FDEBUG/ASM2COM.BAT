@echo off
if %1. == . goto error
tasm %1 ,%1.obj
if errorlevel 1 goto err1
tlink %1 /t
if errorlevel 1 goto err1
echo OK
goto end
:error
echo Укажите имя программы по Alt+F2
goto end
:err1
Pause
:end
