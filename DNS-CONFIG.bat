Configurador de DNS - Script Batch
Script em lote (batch) para configuração simplificada de servidores DNS no Windows (nomes fictícios para fins didáticos).

Descrição
Este script permite alterar rapidamente as configurações de DNS entre diferentes provedores ou retornar para configuração automática via DHCP.

Opções Disponíveis
1. EMPRESA_ALFA
Servidor DNS: 192.168.1.100

Configura o servidor DNS primário para o endereço da Empresa Alfa

2. EMPRESA_BETA
Servidor DNS: 10.10.10.50

Configura o servidor DNS primário para o endereço da Empresa Beta

3. DNS Automático (DHCP)
Restaura as configurações automáticas de DNS

Obtém servidores DNS automaticamente do servidor DHCP

4. Ver configurações atuais
Exibe informações detalhadas das interfaces de rede

Mostra configurações IP e DNS atuais

5. Testar conectividade DNS
Testa conectividade com os servidores DNS configurados

Verifica resolução de nomes DNS

6. Sair
Encerra o aplicativo






Código Comentado:

@echo off
:: Configurar página de código para UTF-8 (suporte a caracteres especiais)
chcp 65001 >nul
:: Habilitar expansão atrasada de variáveis para manipulação em loops
setlocal enabledelayedexpansion

:INICIO
:: Limpar tela e exibir menu principal
cls
echo ========================================
echo        CONFIGURADOR DE DNS
echo ========================================
echo.
echo    1 - EMPRESA_ALFA (192.168.1.100)
echo    2 - EMPRESA_BETA (10.10.10.50) 
echo    3 - DNS Automatico (DHCP)
echo    4 - Ver configuracoes atuais
echo    5 - Testar conectividade DNS
echo    6 - Sair
echo.
echo ========================================
:: Capturar escolha do usuário sem exibir prompt
choice /c 123456 /n /m "Escolha uma opcao: "

:: Redirecionar para opção escolhida com base no errorlevel
if %errorlevel% equ 1 goto EMPRESA_ALFA
if %errorlevel% equ 2 goto EMPRESA_BETA
if %errorlevel% equ 3 goto DHCP
if %errorlevel% equ 4 goto VER_CONFIG
if %errorlevel% equ 5 goto TESTAR
if %errorlevel% equ 6 goto SAIR

:EMPRESA_ALFA
cls
echo ========================================
echo    CONFIGURANDO DNS EMPRESA_ALFA
echo    Primary: 192.168.1.100
echo ========================================
echo.
:: Verificar privilégios de administrador
call :CHECK_ADMIN
:: Selecionar interface de rede
call :SELECIONAR_INTERFACE_NUMERO
:: Se erro na seleção, retornar ao menu
if !error! equ 1 goto INICIO

echo Configurando DNS EMPRESA_ALFA na interface !interface!...
:: Comando netsh para configurar DNS estático
netsh interface ip set dns name="!interface!" static 192.168.1.100 primary
echo.
echo DNS configurado com sucesso!
:: Verificar e exibir configuração atual
call :VERIFICAR_CONFIG
pause
goto INICIO

:EMPRESA_BETA
cls
echo ========================================
echo      CONFIGURANDO DNS EMPRESA_BETA
echo    Primary: 10.10.10.50
echo ========================================
echo.
call :CHECK_ADMIN
call :SELECIONAR_INTERFACE_NUMERO
if !error! equ 1 goto INICIO

echo Configurando DNS EMPRESA_BETA na interface !interface!...
netsh interface ip set dns name="!interface!" static 10.10.10.50 primary
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
:: Comando netsh para restaur configuração DHCP
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
:: Exibir interfaces de rede disponíveis
netsh interface show interface
echo.
echo Configuracoes IP:
echo -----------------
:: Exibir configurações IP e DNS atuais
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
:: Testar conectividade com servidor EMPRESA_ALFA
ping 192.168.1.100 -n 2 >nul
if errorlevel 1 (
    echo ❌ EMPRESA_ALFA (192.168.1.100) - OFFLINE
) else (
    echo ✅ EMPRESA_ALFA (192.168.1.100) - ONLINE
)

:: Testar conectividade com servidor EMPRESA_BETA
ping 10.10.10.50 -n 2 >nul
if errorlevel 1 (
    echo ❌ EMPRESA_BETA (10.10.10.50) - OFFLINE
) else (
    echo ✅ EMPRESA_BETA (10.10.10.50) - ONLINE
)

echo.
echo Testando resolucao de nomes...
:: Testar resolução DNS básica
nslookup google.com 2>nul | findstr "Server"
echo.
pause
goto INICIO

:SAIR
cls
echo.
echo Obrigado por usar o Configurador de DNS!
echo.
:: Esperar 2 segundos antes de sair
timeout /t 2 /nobreak >nul
exit

:CHECK_ADMIN
:: Verificar se o script está sendo executado como administrador
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

:: Criar arquivo temporario com interfaces conectadas
netsh interface show interface | findstr "Conectado" > %temp%\interfaces.txt

set count=0
set "interfaces[0]="

:: Ler interfaces e numerar para seleção
for /f "tokens=4*" %%a in (%temp%\interfaces.txt) do (
    set /a count+=1
    set "interfaces[!count!]=%%a %%b"
    echo    !count! - %%a %%b
)

echo.
:: Verificar se há interfaces conectadas
if !count! equ 0 (
    echo Nenhuma interface conectada encontrada!
    pause
    set error=1
    del %temp%\interfaces.txt 2>nul
    exit /b
)

:ESCOLHER_INTERFACE
echo.
:: Capturar escolha do usuário
set /p opcao="Escolha o numero da interface (1-!count!): "

:: Validar entrada do usuário
if not defined opcao goto ESCOLHER_INTERFACE
if !opcao! lss 1 goto ESCOLHER_INTERFACE
if !opcao! gtr !count! goto ESCOLHER_INTERFACE

:: Extrair apenas o nome da interface (remover estado)
for /f "tokens=1" %%i in ("!interfaces[%opcao%]!") do (
    set interface=%%i
)

echo.
echo Interface selecionada: !interface!
echo.
:: Limpar arquivo temporário
del %temp%\interfaces.txt 2>nul
exit /b

:VERIFICAR_CONFIG
echo.
echo Verificando configuracoes atuais:
:: Exibir configurações DNS da interface selecionada
netsh interface ip show config name="!interface!" | findstr "DNS"
echo.
exit /b







Requisitos
Windows 7 ou superior

Privilégios de administrador

Interface de rede ativa

Como Executar
Método recomendado: Clique direito no arquivo e selecione "Executar como administrador"

Via linha de comando:

cmd
runas /user:Administrador "script.bat"
