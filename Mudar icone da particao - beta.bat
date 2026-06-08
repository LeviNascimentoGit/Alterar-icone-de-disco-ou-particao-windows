	@echo off

REM 	Altera a codificação do prompt para UTF-8 (corrige acentos)

	chcp 65001 > nul

	goto inicio

REM 	Verifica se o usuário está executando o arquivo como administrador

	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
	if not %errorlevel%==0 (
	color 4
	echo.
echo 	Atenção!	Este script precisa ser executado como Administrador.
	echo.
echo 	Clique neste arquivo com o botão direito do mouse e selecione a opção [Executar como administrador]

	timeout 10 >nul & exit
	)

:inicio

:letra

	cls & echo.
echo ----------- ----------------
echo       Letra Nome da Partição

REM 	Executa um comando PowerShell para listar as partições de forma limpa

	powershell -NoProfile -Command "Get-Volume | Where-Object {$_.DriveLetter} | Format-Table -Property DriveLetter, FileSystemLabel -AutoSize"

	echo.
	set /p letra=^>	Digite a letra da partição desejada e pressione [Enter]:

:numero

	pushd "%~dp0resources\icons"

	cls & echo.

REM 	Se nenhum arquivo for encontrado, encerra o script

if not exist *.ico (
	color e
echo 	O diretório '\resources\icons' não contém arquivos de ícone *.ico
	timeout 5 >nul & exit
	)

REM 	Sem usar 'setlocal enabledelayedexpansion' o valor da variável até muda internamente na memória, mas o comando echo vai mostrar 0 em todas as repetições, porque o Windows já substituiu a variavel %contador% por 0 antes do laço começar a rodar de verdade. Para avisar o Windows quais variáveis devem esperar a sua vez, nós trocamos as "%" por "!" . Sem essa linha, o Windows tentaria criar uma variável chamada literalmente arquivo_0 para todos os arquivos da lista, e o menu não funcionaria.

	setlocal enabledelayedexpansion

REM 	Lista os arquivos e cria a numeração dinamicamente

	set contador=0 
	for /f "delims=" %%i in ('dir /b *.ico') do (
	set /a contador+=1
	set "arquivo_!contador!=%%i"
echo 	!contador!. %%i
	) 

echo. 

REM 	Define a variável %arquivo% baseado na variável %numero%

	set /p numero=^>	Escolha um número da lista e pressione [Enter], para redefnir Padrão digite 0 :
	set "arquivo=!arquivo_%numero%!"

REM 	Verifica se uma opção foi digitada

	if "%arquivo%"=="" (
	color e

	cls & echo.
echo 	Selecione um número da lista

	timeout 2 >nul & goto numero 
	)	 

REM 	Limpa arquivos pré-existentes pra evitar o erro 'acesso negado' ao copiar sobrescrevendo.

	del /f /a "%letra%:/autorun.inf" "%letra%:/icone.ico"

REM 	Se o número for 0 , o script encerra aqui.

	if %numero%==0 (goto sucesso)

REM 	Copia, renomeia e oculta os arquivos 'autorun.inf' e 'icone.ico'.

	cls
	pushd %~dp0
	echo f | xcopy /y /h "resources\icons\%arquivo%" "%letra%:/icone.ico"
	if not %errorlevel%==0 (goto erro)
	attrib +h "%letra%:/icone.ico"
	echo f | xcopy /y /h "resources\autorun.inf" "%letra%:/autorun.inf"
	if not %errorlevel%==0 (goto erro)
	attrib +h "%letra%:/autorun.inf"

:sucesso

	cls & echo.
	color a0
echo   ;^)	Alterado com sucesso!
	timeout /t 3 >nul & exit

:erro

	cls & echo.
	color c7
echo   :^(	[Erro] Falha ao copiar!
	timeout /t 3 >nul & exit

