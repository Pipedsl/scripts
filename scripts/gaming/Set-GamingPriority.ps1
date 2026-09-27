<#
.SYNOPSIS
    OptiMax Pro — Prioridad CPU/GPU para Gaming
.DESCRIPTION
    Ajusta la prioridad del sistema para que los juegos reciban
    la máxima atención del procesador y la GPU.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Set-OptiMaxGamingPriority {
    [CmdletBinding()]
    param()

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🎯 OPTIMAX PRO — Prioridad Gaming CPU/GPU    ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    $changes = 0

    # ══════════════════════════════════════════
    # 1. WIN32PRIORITYSEPARATION
    # ══════════════════════════════════════════
    Write-Host "── Prioridad de CPU para Primer Plano ─────────────" -ForegroundColor Cyan

    try {
        # Valor 26 (0x1A) = Short, Fixed, High foreground boost
        # Esto da máxima prioridad a la ventana activa (el juego)
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
        $currentValue = (Get-ItemProperty -Path $regPath -Name "Win32PrioritySeparation").Win32PrioritySeparation

        Set-ItemProperty -Path $regPath -Name "Win32PrioritySeparation" -Value 26
        Write-Host "[✓] Win32PrioritySeparation: $currentValue → 26 (prioridad máxima a primer plano)" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[✗] Error al configurar prioridad CPU: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ══════════════════════════════════════════
    # 2. GPU SCHEDULING (Windows 10 2004+)
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── GPU Scheduling ─────────────────────────────────" -ForegroundColor Cyan

    try {
        $gpuSchedPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        Set-ItemProperty -Path $gpuSchedPath -Name "HwSchMode" -Value 2 -Type DWord -ErrorAction SilentlyContinue
        Write-Host "[✓] Hardware-accelerated GPU scheduling habilitado" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[!] GPU Scheduling no disponible en este sistema" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # 3. GAME MODE
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Game Mode de Windows ───────────────────────────" -ForegroundColor Cyan

    try {
        $gameModePath = "HKCU:\Software\Microsoft\GameBar"
        if (-not (Test-Path $gameModePath)) {
            New-Item -Path $gameModePath -Force | Out-Null
        }

        # Activar Game Mode (asigna más recursos CPU/GPU a juegos)
        $gameCfgPath = "HKCU:\System\GameConfigStore"
        if (-not (Test-Path $gameCfgPath)) {
            New-Item -Path $gameCfgPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gameCfgPath -Name "GameDVR_Enabled" -Value 0 -Type DWord
        Set-ItemProperty -Path $gameCfgPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord
        Set-ItemProperty -Path $gameCfgPath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord
        Set-ItemProperty -Path $gameCfgPath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord
        Set-ItemProperty -Path $gameCfgPath -Name "GameDVR_EFSEFeatureFlags" -Value 0 -Type DWord

        Write-Host "[✓] Game Mode optimizado" -ForegroundColor Green
        Write-Host "[✓] Fullscreen Exclusive mejorado" -ForegroundColor Green
        $changes += 2
    }
    catch {
        Write-Host "[!] Error al configurar Game Mode" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # 4. PRIORIDAD MULTIMEDIA
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Prioridad Multimedia (MMCSS) ───────────────────" -ForegroundColor Cyan

    try {
        $mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"

        # Más recursos para tareas multimedia (juegos)
        Set-ItemProperty -Path $mmcssPath -Name "SystemResponsiveness" -Value 0 -Type DWord
        Write-Host "[✓] SystemResponsiveness: 0 (100% recursos para multimedia)" -ForegroundColor Green
        $changes++

        # Prioridad de red para gaming
        Set-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -Value 4294967295 -Type DWord
        Write-Host "[✓] Network throttling desactivado" -ForegroundColor Green
        $changes++

        # Configurar perfil de juegos
        $gamesPath = "$mmcssPath\Tasks\Games"
        if (-not (Test-Path $gamesPath)) {
            New-Item -Path $gamesPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gamesPath -Name "GPU Priority" -Value 8 -Type DWord
        Set-ItemProperty -Path $gamesPath -Name "Priority" -Value 6 -Type DWord
        Set-ItemProperty -Path $gamesPath -Name "Scheduling Category" -Value "High"
        Set-ItemProperty -Path $gamesPath -Name "SFIO Priority" -Value "High"
        Write-Host "[✓] Perfil MMCSS 'Games' configurado con máxima prioridad" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[✗] Error al configurar MMCSS: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ══════════════════════════════════════════
    # 5. DESHABILITAR CORE PARKING
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Core Parking (todos los núcleos activos) ───────" -ForegroundColor Cyan

    try {
        # Desactivar core parking - forzar todos los núcleos al 100%
        powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
        powercfg -setactive SCHEME_CURRENT
        Write-Host "[✓] Core parking desactivado (todos los núcleos disponibles)" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[!] No se pudo configurar core parking" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # 6. DESHABILITAR LARGE SYSTEM CACHE
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Memory Management ──────────────────────────────" -ForegroundColor Cyan

    try {
        $memMgmtPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
        Set-ItemProperty -Path $memMgmtPath -Name "LargeSystemCache" -Value 0 -Type DWord
        Write-Host "[✓] Large System Cache desactivado (más RAM para juegos)" -ForegroundColor Green
        $changes++

        # Deshabilitar paginación del kernel
        Set-ItemProperty -Path $memMgmtPath -Name "DisablePagingExecutive" -Value 1 -Type DWord
        Write-Host "[✓] Kernel en RAM (no se pagina a disco)" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[✗] Error en Memory Management: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  PRIORIDAD GAMING CONFIGURADA" -ForegroundColor Magenta
    Write-Host "  ✓ $changes optimizaciones aplicadas" -ForegroundColor White
    Write-Host "  [!] Reiniciar para aplicar todos los cambios." -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
    $logFile = Join-Path $logPath "gaming-priority.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | GAMING PRIORITY | Cambios: $changes" | Out-File -Append -FilePath $logFile
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Set-OptiMaxGamingPriority
}
