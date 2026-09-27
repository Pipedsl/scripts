@echo off
REM ============================================================
REM  OptiMax Pro - Lanzador (doble clic)
REM  - Pide permisos de Administrador automaticamente
REM  - Desbloquea los scripts descargados de internet (ZIP)
REM  - Ejecuta el menu sin cambiar la politica del sistema
REM ============================================================
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando permisos de Administrador...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Desbloqueando scripts...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%~dp0scripts' -Recurse -Filter *.ps1 | Unblock-File"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\launcher\Start-Optimizer.ps1"

echo.
pause
