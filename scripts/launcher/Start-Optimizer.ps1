<#
.SYNOPSIS
    OptiMax Pro — Launcher Interactivo Principal
.DESCRIPTION
    Menú principal del kit de optimización OptiMax Pro.
    Punto de entrada único para todos los módulos del sistema.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
    Uso: Clic derecho → "Ejecutar con PowerShell" como Admin
          O desde PowerShell Admin: .\Start-Optimizer.ps1
#>

#Requires -RunAsAdministrator

# Configurar encoding para caracteres especiales
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "OptiMax Pro — Servicio de Optimización"

function Show-MainMenu {
    Clear-Host

    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "  ║                                                        ║" -ForegroundColor Magenta
    Write-Host "  ║    ██████  ██████  ████████ ██ ███    ███  █████  ██   ║" -ForegroundColor Magenta
    Write-Host "  ║   ██    ██ ██   ██    ██    ██ ████  ████ ██   ██  ██  ║" -ForegroundColor Magenta
    Write-Host "  ║   ██    ██ ██████     ██    ██ ██ ████ ██ ███████   ██ ║" -ForegroundColor Magenta
    Write-Host "  ║   ██    ██ ██         ██    ██ ██  ██  ██ ██   ██  ██  ║" -ForegroundColor Magenta
    Write-Host "  ║    ██████  ██         ██    ██ ██      ██ ██   ██ ██   ║" -ForegroundColor Magenta
    Write-Host "  ║                        P R O                           ║" -ForegroundColor Magenta
    Write-Host "  ║                                                        ║" -ForegroundColor Magenta
    Write-Host "  ║     Servicio Profesional de Optimizacion Windows       ║" -ForegroundColor Cyan
    Write-Host "  ║                    v1.0.0                              ║" -ForegroundColor DarkGray
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    # Info rápida del sistema
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $ramPercent = [math]::Round((($totalRAM - $freeRAM) / $totalRAM) * 100, 0)
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue
        $cpuLoad = $cpu.LoadPercentage

        $ramColor = if ($ramPercent -gt 85) { "Red" } elseif ($ramPercent -gt 70) { "Yellow" } else { "Green" }
        $cpuColor = if ($cpuLoad -gt 80) { "Red" } elseif ($cpuLoad -gt 50) { "Yellow" } else { "Green" }

        Write-Host "  ── Estado Actual ────────────────────────────────────────" -ForegroundColor DarkGray
        Write-Host "   CPU: $cpuLoad%  " -ForegroundColor $cpuColor -NoNewline
        Write-Host "│  RAM: $ramPercent% ($freeRAM GB libres de $totalRAM GB)  " -ForegroundColor $ramColor -NoNewline
        Write-Host "│  $($env:COMPUTERNAME)" -ForegroundColor White
        Write-Host "  ─────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    }
    catch {
        # Si falla, no mostramos el estado rápido
    }

    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────┐" -ForegroundColor White
    Write-Host "  │                    MENU PRINCIPAL                       │" -ForegroundColor White
    Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor White
    Write-Host "  │                                                        │" -ForegroundColor White
    Write-Host "  │   1.  📋  Diagnostico Completo del Sistema             │" -ForegroundColor Cyan
    Write-Host "  │                                                        │" -ForegroundColor White
    Write-Host "  │   ── PERFILES DE OPTIMIZACION ─────────────────────    │" -ForegroundColor DarkGray
    Write-Host "  │   2.  🏢  Optimizacion TRABAJO (completa)              │" -ForegroundColor White
    Write-Host "  │   3.  🎮  Optimizacion GAMING (completa)               │" -ForegroundColor Green
    Write-Host "  │                                                        │" -ForegroundColor White
    Write-Host "  │   ── MODULOS INDIVIDUALES ─────────────────────────    │" -ForegroundColor DarkGray
    Write-Host "  │   4.  🧹  Limpieza de Archivos Temporales             │" -ForegroundColor White
    Write-Host "  │   5.  🗑️   Eliminar Bloatware                          │" -ForegroundColor White
    Write-Host "  │   6.  ⚙️   Optimizar Servicios del Sistema             │" -ForegroundColor White
    Write-Host "  │   7.  🚀  Gestionar Programas de Inicio               │" -ForegroundColor White
    Write-Host "  │   8.  🎨  Optimizacion Visual                          │" -ForegroundColor White
    Write-Host "  │   9.  ⚡  Configurar Plan de Energia                   │" -ForegroundColor White
    Write-Host "  │  10.  🎯  Prioridad CPU/GPU (Gaming)                   │" -ForegroundColor White
    Write-Host "  │  11.  🌐  Optimizar Latencia de Red                    │" -ForegroundColor White
    Write-Host "  │  12.  🎬  Desactivar Overlays de Juegos               │" -ForegroundColor White
    Write-Host "  │                                                        │" -ForegroundColor White
    Write-Host "  │   ── SEGURIDAD ────────────────────────────────────    │" -ForegroundColor DarkGray
    Write-Host "  │  13.  💾  Crear Punto de Restauracion                  │" -ForegroundColor Yellow
    Write-Host "  │  14.  🔄  Restaurar Configuracion Original             │" -ForegroundColor Yellow
    Write-Host "  │                                                        │" -ForegroundColor White
    Write-Host "  │   0.  ❌  Salir                                        │" -ForegroundColor Red
    Write-Host "  │                                                        │" -ForegroundColor White
    Write-Host "  └─────────────────────────────────────────────────────────┘" -ForegroundColor White
    Write-Host ""
    Write-Host "  Selecciona una opcion (0-14): " -ForegroundColor Cyan -NoNewline
}

function Wait-ForKeypress {
    Write-Host ""
    Write-Host "  Presiona ENTER para volver al menu..." -ForegroundColor DarkGray -NoNewline
    Read-Host
}

# ══════════════════════════════════════════════════════════
# LOOP PRINCIPAL
# ══════════════════════════════════════════════════════════
$scriptRoot = Split-Path -Parent $PSScriptRoot
# Si se ejecuta desde launcher/, el scriptRoot debería apuntar a scripts/
$scriptsBase = Split-Path -Parent $PSScriptRoot

do {
    Show-MainMenu
    $option = Read-Host

    switch ($option) {
        "1" {
            # Diagnóstico
            . "$scriptsBase\diagnostico\Get-SystemReport.ps1"
            Get-OptiMaxSystemReport
            Wait-ForKeypress
        }
        "2" {
            # Optimización Trabajo Completa
            & "$scriptsBase\trabajo\Optimize-WorkPC.ps1"
            Wait-ForKeypress
        }
        "3" {
            # Optimización Gaming Completa
            & "$scriptsBase\gaming\Optimize-GamingPC.ps1"
            Wait-ForKeypress
        }
        "4" {
            # Limpieza de temporales
            . "$scriptsBase\trabajo\Clean-TempFiles.ps1"
            Clear-OptiMaxTempFiles
            Wait-ForKeypress
        }
        "5" {
            # Eliminar Bloatware
            . "$scriptsBase\trabajo\Disable-Bloatware.ps1"
            Disable-OptiMaxBloatware
            Wait-ForKeypress
        }
        "6" {
            # Optimizar Servicios
            Write-Host ""
            Write-Host "  Perfil de servicios:" -ForegroundColor Cyan
            Write-Host "    1. Trabajo" -ForegroundColor White
            Write-Host "    2. Gaming" -ForegroundColor White
            Write-Host "  Opcion: " -ForegroundColor Cyan -NoNewline
            $svcOption = Read-Host
            $perfil = if ($svcOption -eq "2") { "Gaming" } else { "Trabajo" }

            . "$scriptsBase\trabajo\Optimize-Services.ps1"
            Optimize-OptiMaxServices -Perfil $perfil
            Wait-ForKeypress
        }
        "7" {
            # Programas de inicio
            . "$scriptsBase\trabajo\Optimize-StartupApps.ps1"
            Optimize-OptiMaxStartupApps
            Wait-ForKeypress
        }
        "8" {
            # Optimización visual
            Write-Host ""
            Write-Host "  Perfil visual:" -ForegroundColor Cyan
            Write-Host "    1. Trabajo (equilibrado)" -ForegroundColor White
            Write-Host "    2. Gaming (máximo rendimiento)" -ForegroundColor White
            Write-Host "    3. Mínimo (PCs muy lentos)" -ForegroundColor White
            Write-Host "  Opcion: " -ForegroundColor Cyan -NoNewline
            $visOption = Read-Host
            $visPerfil = switch ($visOption) {
                "2" { "Gaming" }
                "3" { "Minimo" }
                default { "Trabajo" }
            }

            . "$scriptsBase\trabajo\Set-VisualPerformance.ps1"
            Set-OptiMaxVisualPerformance -Perfil $visPerfil
            Wait-ForKeypress
        }
        "9" {
            # Plan de energía
            . "$scriptsBase\comun\Set-PowerPlan.ps1"
            Write-Host ""
            Write-Host "  Perfil de energia:" -ForegroundColor Cyan
            Write-Host "    1. Trabajo (Alto Rendimiento)" -ForegroundColor White
            Write-Host "    2. Gaming (Ultimate Performance)" -ForegroundColor White
            Write-Host "  Opcion: " -ForegroundColor Cyan -NoNewline
            $pwrOption = Read-Host
            $pwrPerfil = if ($pwrOption -eq "2") { "Gaming" } else { "Trabajo" }

            Set-OptiMaxPowerPlan -Perfil $pwrPerfil
            Wait-ForKeypress
        }
        "10" {
            # Prioridad Gaming
            . "$scriptsBase\gaming\Set-GamingPriority.ps1"
            Set-OptiMaxGamingPriority
            Wait-ForKeypress
        }
        "11" {
            # Latencia de red
            . "$scriptsBase\gaming\Optimize-NetworkLatency.ps1"
            Optimize-OptiMaxNetworkLatency
            Wait-ForKeypress
        }
        "12" {
            # Overlays
            . "$scriptsBase\gaming\Disable-GameOverlays.ps1"
            Disable-OptiMaxGameOverlays
            Wait-ForKeypress
        }
        "13" {
            # Punto de restauración
            . "$scriptsBase\comun\Backup-RestorePoint.ps1"
            New-OptiMaxRestorePoint
            Wait-ForKeypress
        }
        "14" {
            # Restaurar defaults
            . "$scriptsBase\comun\Restore-Defaults.ps1"
            Restore-OptiMaxDefaults
            Wait-ForKeypress
        }
        "0" {
            Clear-Host
            Write-Host ""
            Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
            Write-Host "  ║   Gracias por usar OptiMax Pro                  ║" -ForegroundColor Magenta
            Write-Host "  ║   Servicio Profesional de Optimizacion          ║" -ForegroundColor Cyan
            Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
            Write-Host ""
            break
        }
        default {
            Write-Host ""
            Write-Host "  [✗] Opcion no valida. Intenta de nuevo." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($option -ne "0")
