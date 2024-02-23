@echo off
if %1. == . goto error
tasm %1 ,%1.obj /zi
if errorlevel 1 goto err1
tlink %1 /v
if errorlevel 1 goto err1
td %1
goto end
:error
echo Укажите имя программы по Alt+F2
goto end
:err1
Pause
:end
