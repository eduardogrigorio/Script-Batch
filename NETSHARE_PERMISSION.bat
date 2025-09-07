@echo off
setlocal

set FOLDER=B:\DADOS\GRAVACOES\KAINOS

echo Tomando posse da pasta e todos os arquivos...
takeown /f "%FOLDER%" /r /d y

echo Concedendo permissões completas aos Administradores...
icacls "%FOLDER%" /grant Administrators:F /t /c

echo Removendo permissões existentes e desabilitando herança...
icacls "%FOLDER%" /inheritance:r /t /c

echo Aplicando permissões de leitura para Everyone...
icacls "%FOLDER%" /grant "Everyone:(OI)(CI)R" /t /c

echo Negando permissões de gravação e exclusão para Everyone...
icacls "%FOLDER%" /deny "Everyone:(OI)(CI)(W,D,DC)" /t /c

echo Configurando permissões de compartilhamento...
rem Primeiro, remova o compartilhamento existente se houver
net share KAINOS /delete 2>NUL
rem Agora, crie o compartilhamento com permissões de leitura
net share KAINOS="%FOLDER%" /grant:Everyone,READ

echo Concluído!

endlocal