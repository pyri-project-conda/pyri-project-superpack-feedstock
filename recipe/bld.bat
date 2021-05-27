@echo off

setlocal

where /q npm
IF ERRORLEVEL 1 (
    ECHO NodeJS npm command is not found. Install NodeJS before continuing
    EXIT /B 100
)

for %%x in (
    pyri-common
    pyri-variable-storage
    pyri-device-manager 
    pyri-devices-states
    pyri-sandbox
    pyri-program-master
    pyri-webui-server
    pyri-core
    pyri-robotics
    pyri-vision    
    ) do (
        %PYTHON% -m pip install --no-deps --ignore-installed .\%%x -vv
        if %errorlevel% neq 0 exit /b %errorlevel%
    )

pyri-sandbox-service --install-blockly-compiler --blockly-compiler-dir=%CONDA_PREFIX%\pyri-project\pyri-sandbox\blockly_compiler
if %errorlevel% neq 0 exit /b %errorlevel%

cd scripts
%PYTHON% install_webui_browser_wheels.py --static-data-dir=%CONDA_PREFIX%\pyri-project\pyri-webui-server
if %errorlevel% neq 0 exit /b %errorlevel%
%PYTHON% install_webui_browser_deps.py --static-data-dir=%CONDA_PREFIX%\pyri-project\pyri-webui-server
if %errorlevel% neq 0 exit /b %errorlevel%

setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: Copy unix shell activation scripts, needed by Windows Bash users
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
