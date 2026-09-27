<#
.SYNOPSIS
    OptiMax Pro — Optimización Completa para Trabajo
.DESCRIPTION
    Script orquestador que ejecuta TODOS los módulos de optimización
    del perfil Trabajo en el orden correcto y seguro.
    
    Orden de ejecución:
    1. Punto de restauración
    2. Limpieza de archivos temporales
    3. Desactivar bloatware
    4. Optimizar servicios
    5. Gestión de programas de inicio
    6. Optimización visual
    7. Plan de energía
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

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
Write-Host "  ║     🏢 OPTIMIZACIÓN COMPLETA — PERFIL TRABAJO          ║" -ForegroundColor Cyan
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Este script ejecutará las siguientes optimizaciones:" -ForegroundColor White
Write-Host ""
Write-Host "    1. 💾 Crear punto de restauración (seguridad)" -ForegroundColor DarkGray
Write-Host "    2. 🧹 Limpieza de archivos temporales" -ForegroundColor DarkGray
Write-Host "    3. 🗑️ Eliminación de bloatware (McAfee, SDXHelper...)" -ForegroundColor DarkGray
Write-Host "    4. ⚙️ Optimización de servicios del sistema" -ForegroundColor DarkGray
Write-Host "    5. 🚀 Gestión de programas de inicio" -ForegroundColor DarkGray
Write-Host "    6. 🎨 Optimización visual (rendimiento)" -ForegroundColor DarkGray
Write-Host "    7. ⚡ Plan de energía Alto Rendimiento" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [!] IMPORTANTE:" -ForegroundColor Yellow
Write-Host "      → AnyDesk NO será tocado (herramienta de acceso remoto)" -ForegroundColor Yellow
Write-Host "      → Se creará un punto de restauración antes de comenzar" -ForegroundColor Yellow
Write-Host "      → Todos los cambios son reversibles" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ¿Iniciar optimización completa? (S/N): " -ForegroundColor Cyan -NoNewline
$confirm = Read-Host

if ($confirm -ne 'S' -and $confirm -ne 's') {
    Write-Host ""
    Write-Host "  [→] Operación cancelada por el usuario." -ForegroundColor Cyan
    exit 0
}

$scriptRoot = $PSScriptRoot
$startTime = Get-Date
$totalSteps = 7
$currentStep = 0

function Show-Progress {
    param([int]$Step, [int]$Total, [string]$Message)
    $percent = [math]::Round(($Step / $Total) * 100)
    $barLength = 30
    $filled = [math]::Round(($Step / $Total) * $barLength)
    $empty = $barLength - $filled
    $bar = "█" * $filled + "░" * $empty
    Write-Host ""
    Write-Host "  [$bar] $percent% — $Message" -ForegroundColor Cyan
    Write-Host ""
}

# ══════════════════════════════════════════════════════════
# PASO 1: Punto de Restauración
# ══════════════════════════════════════════════════════════
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Creando punto de restauración..."
. "$scriptRoot\..\comun\Backup-RestorePoint.ps1"
$backupResult = New-OptiMaxRestorePoint -Description "OptiMax Pro - Perfil Trabajo"

if (-not $backupResult) {
    Write-Host "  ¿Continuar sin backup? (S/N): " -ForegroundColor Yellow -NoNewline
    $continueWithout = Read-Host
    if ($continueWithout -ne 'S' -and $continueWithout -ne 's') {
        Write-Host "  [→] Operación cancelada." -ForegroundColor Cyan
        exit 1
    }
}

# ══════════════════════════════════════════════════════════
# PASO 2: Limpieza de Temporales
# ══════════════════════════════════════════════════════════
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Limpiando archivos temporales..."
. "$scriptRoot\Clean-TempFiles.ps1"
$freedMB = Clear-OptiMaxTempFiles

# ══════════════════════════════════════════════════════════
# PASO 3: Eliminar Bloatware
# ══════════════════════════════════════════════════════════
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Eliminando bloatware..."
. "$scriptRoot\Disable-Bloatware.ps1"
Disable-OptiMaxBloatware

# ══════════════════════════════════════════════════════════
# PASO 4: Optimizar Servicios
# ══════════════════════════════════════════════════════════
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Optimizando servicios del sistema..."
. "$scriptRoot\Optimize-Services.ps1"
$ramFreed = Optimize-OptiMaxServices -Perfil "Trabajo"

# ══════════════════════════════════════════════════════════
# PASO 5: Programas de Inicio
# ══════════════════════════════════════════════════════════
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Optimizando programas de inicio..."
. "$scriptRoot\Optimize-StartupApps.ps1"
Optimize-OptiMaxStartupApps -AutoOptimize

# ══════════════════════════════════════════════════════════
# PASO 6: Rendimiento Visual
# ══════════════════════════════════════════════════════════
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Optimizando rendimiento visual..."
. "$scriptRoot\Set-VisualPerformance.ps1"
Set-OptiMaxVisualPerformance -Perfil "Trabajo"

# ══════════════════════════════════════════════════════════
# PASO 7: Plan de Energía
# ══════════════════════════════════════════════════════════
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Configurando plan de energía..."
. "$scriptRoot\..\comun\Set-PowerPlan.ps1"
Set-OptiMaxPowerPlan -Perfil "Trabajo"

# ══════════════════════════════════════════════════════════
# RESUMEN FINAL
# ══════════════════════════════════════════════════════════
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                        ║" -ForegroundColor Green
Write-Host "  ║   ✅ OPTIMIZACIÓN TRABAJO COMPLETADA CON ÉXITO         ║" -ForegroundColor Green
Write-Host "  ║                                                        ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  📊 Resumen:" -ForegroundColor White
Write-Host "     Disco liberado:       ~$([math]::Round($freedMB, 0)) MB" -ForegroundColor Cyan
Write-Host "     RAM estimada libre:   ~$ramFreed MB" -ForegroundColor Cyan
Write-Host "     Duración:             $($duration.Minutes)m $($duration.Seconds)s" -ForegroundColor Cyan
Write-Host ""
Write-Host "  📋 Próximos pasos:" -ForegroundColor White
Write-Host "     1. Reiniciar el equipo para aplicar todos los cambios" -ForegroundColor DarkGray
Write-Host "     2. Verificar que AnyDesk sigue funcionando" -ForegroundColor DarkGray
Write-Host "     3. Comprobar mejora en el Monitor de Recursos" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ⚡ Si el equipo sigue lento después de reiniciar:" -ForegroundColor Yellow
Write-Host "     → Considerar ampliar RAM de 8GB a 16GB" -ForegroundColor Yellow
Write-Host "     → Verificar si el disco es HDD (cambiar a SSD)" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  OptiMax Pro — Servicio Profesional de Optimización" -ForegroundColor DarkGray
Write-Host "  $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor DarkGray
Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# Log final
$logPath = Join-Path $scriptRoot "..\..\logs"
if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
$logFile = Join-Path $logPath "optimize-work.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
"$timestamp | TRABAJO COMPLETO | Disco: ~$([math]::Round($freedMB, 0))MB | RAM: ~${ramFreed}MB | Duración: $($duration.Minutes)m$($duration.Seconds)s" | Out-File -Append -FilePath $logFile
