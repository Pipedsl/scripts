<#
.SYNOPSIS
    OptiMax Pro — Restaurar Configuración Original
.DESCRIPTION
    Revierte TODOS los cambios realizados por los scripts de OptiMax Pro.
    Restaura servicios, configuración visual, plan de energía y más.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Restore-OptiMaxDefaults {
    [CmdletBinding()]
    param()

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🔄 OPTIMAX PRO — Restaurar Configuración      ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "[!] ADVERTENCIA: Esto revertirá TODOS los cambios de OptiMax Pro." -ForegroundColor Yellow
    Write-Host "    Se restaurarán servicios, efectos visuales y configuraciones." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "¿Continuar? (S/N): " -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host

    if ($confirm -ne 'S' -and $confirm -ne 's') {
        Write-Host "[→] Restauración cancelada." -ForegroundColor Cyan
        return
    }

    $errores = 0
    $exitosos = 0

    Write-Host ""
    Write-Host "── Restaurando Servicios ───────────────────────────" -ForegroundColor DarkGray

    # Servicios que pudieron ser deshabilitados
    $servicesToRestore = @(
        @{ Name = "SysMain"; DisplayName = "SysMain (Superfetch)"; StartType = "Automatic" },
        @{ Name = "WSearch"; DisplayName = "Windows Search"; StartType = "Automatic" },
        @{ Name = "DiagTrack"; DisplayName = "Telemetría (DiagTrack)"; StartType = "Automatic" },
        @{ Name = "dmwappushservice"; DisplayName = "dmwappushservice"; StartType = "Automatic" },
        @{ Name = "MapsBroker"; DisplayName = "Downloaded Maps Manager"; StartType = "Automatic" },
        @{ Name = "lfsvc"; DisplayName = "Geolocation Service"; StartType = "Manual" },
        @{ Name = "SharedAccess"; DisplayName = "Internet Connection Sharing"; StartType = "Manual" },
        @{ Name = "RemoteRegistry"; DisplayName = "Remote Registry"; StartType = "Manual" },
        @{ Name = "WMPNetworkSvc"; DisplayName = "Windows Media Player Network"; StartType = "Manual" },
        @{ Name = "TrkWks"; DisplayName = "Distributed Link Tracking"; StartType = "Automatic" }
    )

    foreach ($svc in $servicesToRestore) {
        try {
            $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($service) {
                Set-Service -Name $svc.Name -StartupType $svc.StartType -ErrorAction Stop
                if ($svc.StartType -eq "Automatic") {
                    Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
                }
                Write-Host "[✓] $($svc.DisplayName) → $($svc.StartType)" -ForegroundColor Green
                $exitosos++
            }
        }
        catch {
            Write-Host "[✗] Error restaurando $($svc.DisplayName): $($_.Exception.Message)" -ForegroundColor Red
            $errores++
        }
    }

    # ── Restaurar efectos visuales ──
    Write-Host ""
    Write-Host "── Restaurando Efectos Visuales ────────────────────" -ForegroundColor DarkGray

    try {
        # Restaurar a "Dejar que Windows elija la mejor configuración"
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Value 0 -ErrorAction SilentlyContinue

        # Restaurar animaciones
        $advancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $advancedPath -Name "TaskbarAnimations" -Value 1 -ErrorAction SilentlyContinue

        # Restaurar transparencia
        $personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        Set-ItemProperty -Path $personalizePath -Name "EnableTransparency" -Value 1 -ErrorAction SilentlyContinue

        # Restaurar efectos del sistema
        $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
        Set-ItemProperty -Path $dwmPath -Name "EnableAeroPeek" -Value 1 -ErrorAction SilentlyContinue

        Write-Host "[✓] Efectos visuales restaurados a configuración predeterminada" -ForegroundColor Green
        $exitosos++
    }
    catch {
        Write-Host "[✗] Error restaurando efectos visuales: $($_.Exception.Message)" -ForegroundColor Red
        $errores++
    }

    # ── Restaurar plan de energía ──
    Write-Host ""
    Write-Host "── Restaurando Plan de Energía ─────────────────────" -ForegroundColor DarkGray

    try {
        # Restaurar plan Equilibrado
        $balancedGUID = "381b4222-f694-41f0-9685-ff5bb260df2e"
        powercfg /setactive $balancedGUID
        powercfg /change monitor-timeout-ac 10
        powercfg /change standby-timeout-ac 30

        Write-Host "[✓] Plan de energía restaurado a 'Equilibrado'" -ForegroundColor Green
        $exitosos++
    }
    catch {
        Write-Host "[✗] Error restaurando plan de energía: $($_.Exception.Message)" -ForegroundColor Red
        $errores++
    }

    # ── Restaurar configuración de Gaming ──
    Write-Host ""
    Write-Host "── Restaurando Configuración de Gaming ─────────────" -ForegroundColor DarkGray

    try {
        # Restaurar Game DVR
        $gameDVRPath = "HKCU:\System\GameConfigStore"
        Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -Value 1 -ErrorAction SilentlyContinue

        $gameBarPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
        Set-ItemProperty -Path $gameBarPath -Name "AppCaptureEnabled" -Value 1 -ErrorAction SilentlyContinue

        # Restaurar Nagle's Algorithm
        $netAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $netAdapters) {
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($adapter.InterfaceGuid)"
            Remove-ItemProperty -Path $regPath -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $regPath -Name "TCPNoDelay" -ErrorAction SilentlyContinue
        }

        # Restaurar Win32PrioritySeparation
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2 -ErrorAction SilentlyContinue

        Write-Host "[✓] Configuración de gaming restaurada" -ForegroundColor Green
        $exitosos++
    }
    catch {
        Write-Host "[✗] Error restaurando config de gaming: $($_.Exception.Message)" -ForegroundColor Red
        $errores++
    }

    # ── Restaurar tareas programadas de Office ──
    Write-Host ""
    Write-Host "── Restaurando Tareas Programadas ──────────────────" -ForegroundColor DarkGray

    try {
        $officeTasks = @(
            "\Microsoft\Office\Office Feature Updates",
            "\Microsoft\Office\Office Feature Updates Logon"
        )
        foreach ($task in $officeTasks) {
            schtasks /Change /TN $task /Enable 2>$null
        }
        Write-Host "[✓] Tareas programadas de Office restauradas" -ForegroundColor Green
        $exitosos++
    }
    catch {
        Write-Host "[!] No se encontraron tareas de Office para restaurar" -ForegroundColor Yellow
    }

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  RESTAURACIÓN COMPLETADA" -ForegroundColor Magenta
    Write-Host "  ✓ Exitosos: $exitosos  |  ✗ Errores: $errores" -ForegroundColor White
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "[!] Se recomienda reiniciar el equipo para aplicar todos los cambios." -ForegroundColor Yellow
    Write-Host ""

    # Registrar en log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    }
    $logFile = Join-Path $logPath "restore-defaults.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | RESTAURACIÓN | Exitosos: $exitosos | Errores: $errores" | Out-File -Append -FilePath $logFile
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Restore-OptiMaxDefaults
}
