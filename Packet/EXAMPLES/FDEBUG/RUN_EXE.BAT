@echo off
if %1. == . goto error
@%1
goto end
:error
echo Укажите имя программы по Alt+F2
:end
