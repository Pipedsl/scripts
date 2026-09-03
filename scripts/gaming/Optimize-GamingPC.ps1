<#
.SYNOPSIS
    OptiMax Pro — Optimización Completa para Gaming
.DESCRIPTION
    Script orquestador que ejecuta TODOS los módulos de optimización
    del perfil Gaming en el orden correcto.
    
    Orden de ejecución:
    1. Punto de restauración
    2. Limpieza de archivos temporales
    3. Desactivar bloatware
    4. Optimizar servicios (perfil gaming)
    5. Prioridad CPU/GPU
    6. Desactivar overlays y Game DVR
    7. Optimización de latencia de red
    8. Optimización visual (gaming)
    9. Plan de energía Ultimate Performance
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
Write-Host "  ║     🎮 OPTIMIZACIÓN COMPLETA — PERFIL GAMING           ║" -ForegroundColor Green
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Este script ejecutará las siguientes optimizaciones:" -ForegroundColor White
Write-Host ""
Write-Host "    1. 💾 Crear punto de restauración" -ForegroundColor DarkGray
Write-Host "    2. 🧹 Limpieza de archivos temporales" -ForegroundColor DarkGray
Write-Host "    3. 🗑️ Eliminación de bloatware" -ForegroundColor DarkGray
Write-Host "    4. ⚙️ Optimización de servicios (modo gaming)" -ForegroundColor DarkGray
Write-Host "    5. 🎯 Prioridad CPU/GPU para juegos" -ForegroundColor DarkGray
Write-Host "    6. 🎬 Desactivar overlays y Game DVR" -ForegroundColor DarkGray
Write-Host "    7. 🌐 Optimización de latencia de red" -ForegroundColor DarkGray
Write-Host "    8. 🎨 Optimización visual (máximo FPS)" -ForegroundColor DarkGray
Write-Host "    9. ⚡ Plan Ultimate Performance" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ¿Iniciar optimización gaming completa? (S/N): " -ForegroundColor Cyan -NoNewline
$confirm = Read-Host

if ($confirm -ne 'S' -and $confirm -ne 's') {
    Write-Host ""
    Write-Host "  [→] Operación cancelada." -ForegroundColor Cyan
    exit 0
}

$scriptRoot = $PSScriptRoot
$startTime = Get-Date
$totalSteps = 9
$currentStep = 0

function Show-Progress {
    param([int]$Step, [int]$Total, [string]$Message)
    $percent = [math]::Round(($Step / $Total) * 100)
    $barLength = 30
    $filled = [math]::Round(($Step / $Total) * $barLength)
    $empty = $barLength - $filled
    $bar = "█" * $filled + "░" * $empty
    Write-Host ""
    Write-Host "  [$bar] $percent% — $Message" -ForegroundColor Green
    Write-Host ""
}

# PASO 1: Punto de Restauración
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Creando punto de restauración..."
. "$scriptRoot\..\comun\Backup-RestorePoint.ps1"
$backupResult = New-OptiMaxRestorePoint -Description "OptiMax Pro - Perfil Gaming"
if (-not $backupResult) {
    Write-Host "  ¿Continuar sin backup? (S/N): " -ForegroundColor Yellow -NoNewline
    $c = Read-Host
    if ($c -ne 'S' -and $c -ne 's') { exit 1 }
}

# PASO 2: Limpieza
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Limpiando archivos temporales..."
. "$scriptRoot\..\trabajo\Clean-TempFiles.ps1"
$freedMB = Clear-OptiMaxTempFiles

# PASO 3: Bloatware
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Eliminando bloatware..."
. "$scriptRoot\..\trabajo\Disable-Bloatware.ps1"
Disable-OptiMaxBloatware

# PASO 4: Servicios Gaming
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Optimizando servicios (modo gaming)..."
. "$scriptRoot\..\trabajo\Optimize-Services.ps1"
$ramFreed = Optimize-OptiMaxServices -Perfil "Gaming"

# PASO 5: Prioridad CPU/GPU
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Configurando prioridad CPU/GPU..."
. "$scriptRoot\Set-GamingPriority.ps1"
Set-OptiMaxGamingPriority

# PASO 6: Overlays
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Desactivando overlays y Game DVR..."
. "$scriptRoot\Disable-GameOverlays.ps1"
Disable-OptiMaxGameOverlays

# PASO 7: Red
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Optimizando latencia de red..."
. "$scriptRoot\Optimize-NetworkLatency.ps1"
Optimize-OptiMaxNetworkLatency

# PASO 8: Visual Gaming
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Optimizando rendimiento visual..."
. "$scriptRoot\..\trabajo\Set-VisualPerformance.ps1"
Set-OptiMaxVisualPerformance -Perfil "Gaming"

# PASO 9: Plan de Energía
$currentStep++
Show-Progress -Step $currentStep -Total $totalSteps -Message "Activando Ultimate Performance..."
. "$scriptRoot\..\comun\Set-PowerPlan.ps1"
Set-OptiMaxPowerPlan -Perfil "Gaming"

# ══════════════════════════════════════════════════════════
# RESUMEN FINAL
# ══════════════════════════════════════════════════════════
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                        ║" -ForegroundColor Green
Write-Host "  ║   🎮 OPTIMIZACIÓN GAMING COMPLETADA CON ÉXITO          ║" -ForegroundColor Green
Write-Host "  ║                                                        ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  📊 Resumen:" -ForegroundColor White
Write-Host "     Disco liberado:        ~$([math]::Round($freedMB, 0)) MB" -ForegroundColor Cyan
Write-Host "     RAM estimada libre:    ~$ramFreed MB" -ForegroundColor Cyan
Write-Host "     Duración:              $($duration.Minutes)m $($duration.Seconds)s" -ForegroundColor Cyan
Write-Host ""
Write-Host "  🎮 Optimizaciones Gaming:" -ForegroundColor White
Write-Host "     ✓ CPU priorizada para primer plano" -ForegroundColor Green
Write-Host "     ✓ GPU Scheduling habilitado" -ForegroundColor Green
Write-Host "     ✓ Game DVR y overlays desactivados" -ForegroundColor Green
Write-Host "     ✓ Nagle's Algorithm desactivado" -ForegroundColor Green
Write-Host "     ✓ Core Parking desactivado" -ForegroundColor Green
Write-Host "     ✓ Ultimate Performance activo" -ForegroundColor Green
Write-Host ""
Write-Host "  📋 IMPORTANTE — Reiniciar para aplicar todo." -ForegroundColor Yellow
Write-Host ""
Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  OptiMax Pro — Servicio Profesional de Optimización" -ForegroundColor DarkGray
Write-Host "  $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor DarkGray
Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# Log
$logPath = Join-Path $scriptRoot "..\..\logs"
if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
$logFile = Join-Path $logPath "optimize-gaming.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
"$timestamp | GAMING COMPLETO | Disco: ~$([math]::Round($freedMB, 0))MB | RAM: ~${ramFreed}MB | Duración: $($duration.Minutes)m$($duration.Seconds)s" | Out-File -Append -FilePath $logFile
