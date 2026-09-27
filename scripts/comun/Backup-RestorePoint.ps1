<#
.SYNOPSIS
    OptiMax Pro — Crear Punto de Restauración del Sistema
.DESCRIPTION
    Crea un punto de restauración antes de aplicar cualquier optimización.
    Esto permite revertir todos los cambios si algo sale mal.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function New-OptiMaxRestorePoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Description = "OptiMax Pro - Backup antes de optimización"
    )

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   💾 OPTIMAX PRO — Punto de Restauración        ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    try {
        # Verificar que la protección del sistema está habilitada
        $systemDrive = $env:SystemDrive
        $protection = Get-ComputerRestorePoint -ErrorAction SilentlyContinue

        # Habilitar protección del sistema si no está activa
        Write-Host "[→] Verificando protección del sistema..." -ForegroundColor Cyan
        Enable-ComputerRestore -Drive "$systemDrive\" -ErrorAction SilentlyContinue

        # Crear el punto de restauración
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        $fullDescription = "$Description [$timestamp]"

        Write-Host "[→] Creando punto de restauración..." -ForegroundColor Cyan
        Checkpoint-Computer -Description $fullDescription -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop

        Write-Host "[✓] Punto de restauración creado exitosamente" -ForegroundColor Green
        Write-Host "    Descripción: $fullDescription" -ForegroundColor DarkGray
        Write-Host ""

        # Guardar registro del backup
        $logPath = Join-Path $PSScriptRoot "..\..\logs"
        if (-not (Test-Path $logPath)) {
            New-Item -ItemType Directory -Path $logPath -Force | Out-Null
        }
        $logFile = Join-Path $logPath "restore-points.log"
        "$timestamp | CREADO | $fullDescription" | Out-File -Append -FilePath $logFile

        return $true
    }
    catch {
        Write-Host "[✗] Error al crear punto de restauración: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Puedes crearlo manualmente desde Panel de Control > Sistema > Protección del sistema" -ForegroundColor Yellow
        Write-Host ""

        return $false
    }
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    $result = New-OptiMaxRestorePoint
    if (-not $result) {
        Write-Host "[!] ¿Deseas continuar sin punto de restauración? (S/N): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        if ($response -ne 'S' -and $response -ne 's') {
            Write-Host "[→] Operación cancelada por el usuario." -ForegroundColor Cyan
            exit 1
        }
    }
}
