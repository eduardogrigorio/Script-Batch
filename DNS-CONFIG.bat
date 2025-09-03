@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:INICIO
cls
echo ========================================
echo        CONFIGURADOR DE DNS
echo ========================================
echo.
echo    1 - CREDCESTA (172.16.1.202)
echo    2 - GTF (10.0.0.5)
echo    3 - DNS Automatico (DHCP)
echo    4 - Ver configuracoes atuais
echo    5 - Testar conectividade DNS
echo    6 - Sair
echo.
echo ========================================
choice /c 123456 /n /m "Escolha uma opcao: "

if %errorlevel% equ 1 goto CREDCESTA
if %errorlevel% equ 2 goto GTF
if %errorlevel% equ 3 goto DHCP
if %errorlevel% equ 4 goto VER_CONFIG
if %errorlevel% equ 5 goto TESTAR
if %errorlevel% equ 6 goto SAIR

:CREDCESTA
cls
echo ========================================
echo    CONFIGURANDO DNS CREDCESTA
echo    Primary: 172.16.1.202
echo ========================================
echo.
call :CHECK_ADMIN
call :SELECIONAR_INTERFACE_NUMERO
if !error! equ 1 goto INICIO

echo Configurando DNS CREDCESTA na interface !interface!...
netsh interface ip set dns name="!interface!" static 172.16.1.202 primary
echo.
echo DNS configurado com sucesso!
call :VERIFICAR_CONFIG
pause
goto INICIO

:GTF
cls
echo ========================================
echo      CONFIGURANDO DNS GTF
echo    Primary: 10.0.0.5
echo ========================================
echo.
call :CHECK_ADMIN
call :SELECIONAR_INTERFACE_NUMERO
if !error! equ 1 goto INICIO

echo Configurando DNS GTF na interface !interface!...
netsh interface ip set dns name="!interface!" static 10.0.0.5 primary
echo.
echo DNS configurado com sucesso!
call :VERIFICAR_CONFIG
pause
goto INICIO

:DHCP
cls
echo ========================================
echo    CONFIGURANDO DNS AUTOMATICO (DHCP)
echo ========================================
echo.
call :CHECK_ADMIN
call :SELECIONAR_INTERFACE_NUMERO
if !error! equ 1 goto INICIO

echo Retornando para configuracao automatica na interface !interface!...
netsh interface ip set dns name="!interface!" source=dhcp
echo.
echo Configuracao DHCP restaurada!
call :VERIFICAR_CONFIG
pause
goto INICIO

:VER_CONFIG
cls
echo ========================================
echo    CONFIGURACOES ATUAIS DE REDE
echo ========================================
echo.
echo Interfaces de rede:
echo -------------------
netsh interface show interface
echo.
echo Configuracoes IP:
echo -----------------
ipconfig /all | findstr /i "adaptador ethernet wi-fi ipv4 dns"
echo.
pause
goto INICIO

:TESTAR
cls
echo ========================================
echo        TESTE DE CONECTIVIDADE DNS
echo ========================================
echo.
echo Testando conectividade com DNS...
echo.
ping 172.16.1.202 -n 2 >nul
if errorlevel 1 (
    echo ❌ CREDCESTA (172.16.1.202) - OFFLINE
) else (
    echo ✅ CREDCESTA (172.16.1.202) - ONLINE
)

ping 10.0.0.5 -n 2 >nul
if errorlevel 1 (
    echo ❌ GTF (10.0.0.5) - OFFLINE
) else (
    echo ✅ GTF (10.0.0.5) - ONLINE
)

echo.
echo Testando resolucao de nomes...
nslookup google.com 2>nul | findstr "Server"
echo.
pause
goto INICIO

:SAIR
cls
echo.
echo Obrigado por usar o Configurador de DNS!
echo.
timeout /t 2 /nobreak >nul
exit

:CHECK_ADMIN
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERRO: Execute este script como Administrador!
    echo.
    echo Clique direito no arquivo e selecione
    echo "Executar como administrador"
    echo.
    pause
    set error=1
    exit /b
)
set error=0
exit /b

:SELECIONAR_INTERFACE_NUMERO
cls
echo ========================================
echo        SELECAO DE INTERFACE
echo ========================================
echo.
echo Interfaces disponiveis:
echo -----------------------

REM Criar arquivo temporario com interfaces
netsh interface show interface | findstr "Conectado" > %temp%\interfaces.txt

set count=0
set "interfaces[0]="

REM Ler interfaces e numerar
for /f "tokens=4*" %%a in (%temp%\interfaces.txt) do (
    set /a count+=1
    set "interfaces[!count!]=%%a %%b"
    echo    !count! - %%a %%b
)

echo.
if !count! equ 0 (
    echo Nenhuma interface conectada encontrada!
    pause
    set error=1
    del %temp%\interfaces.txt 2>nul
    exit /b
)

:ESCOLHER_INTERFACE
echo.
set /p opcao="Escolha o numero da interface (1-!count!): "

REM Validar escolha
if not defined opcao goto ESCOLHER_INTERFACE
if !opcao! lss 1 goto ESCOLHER_INTERFACE
if !opcao! gtr !count! goto ESCOLHER_INTERFACE

REM Extrair apenas o nome da interface (remover estado)
for /f "tokens=1" %%i in ("!interfaces[%opcao%]!") do (
    set interface=%%i
)

echo.
echo Interface selecionada: !interface!
echo.
del %temp%\interfaces.txt 2>nul
exit /b

:VERIFICAR_CONFIG
echo.
echo Verificando configuracoes atuais:
netsh interface ip show config name="!interface!" | findstr "DNS"
echo.
exit /b