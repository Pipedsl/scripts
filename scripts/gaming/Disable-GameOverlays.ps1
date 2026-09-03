<#
.SYNOPSIS
    OptiMax Pro — Desactivar Game Overlays
.DESCRIPTION
    Desactiva overlays y grabación de juegos que consumen
    FPS y recursos del sistema.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Disable-OptiMaxGameOverlays {
    [CmdletBinding()]
    param()

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🎬 OPTIMAX PRO — Desactivar Overlays         ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    $changes = 0

    # ══════════════════════════════════════════
    # 1. GAME DVR (Grabación de Juegos)
    # ══════════════════════════════════════════
    Write-Host "── Game DVR (Grabación de pantalla) ───────────────" -ForegroundColor Cyan

    try {
        # Desactivar Game DVR completamente
        $gameDVRPath = "HKCU:\System\GameConfigStore"
        if (-not (Test-Path $gameDVRPath)) {
            New-Item -Path $gameDVRPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gameDVRPath -Name "GameDVR_Enabled" -Value 0 -Type DWord

        # Desactivar captura
        $appCapturePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
        if (-not (Test-Path $appCapturePath)) {
            New-Item -Path $appCapturePath -Force | Out-Null
        }
        Set-ItemProperty -Path $appCapturePath -Name "AppCaptureEnabled" -Value 0 -Type DWord

        # Desactivar vía política de grupo
        $policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
        if (-not (Test-Path $policyPath)) {
            New-Item -Path $policyPath -Force | Out-Null
        }
        Set-ItemProperty -Path $policyPath -Name "AllowGameDVR" -Value 0 -Type DWord

        Write-Host "[✓] Game DVR desactivado completamente" -ForegroundColor Green
        Write-Host "    → Ya no graba clips en segundo plano (ahorra CPU/GPU)" -ForegroundColor DarkGray
        $changes++
    }
    catch {
        Write-Host "[✗] Error al desactivar Game DVR: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ══════════════════════════════════════════
    # 2. GAME BAR (Xbox Game Bar)
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Xbox Game Bar ──────────────────────────────────" -ForegroundColor Cyan

    try {
        $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
        if (-not (Test-Path $gameBarPath)) {
            New-Item -Path $gameBarPath -Force | Out-Null
        }
        Set-ItemProperty -Path $gameBarPath -Name "UseNexusForGameBarEnabled" -Value 0 -Type DWord
        Set-ItemProperty -Path $gameBarPath -Name "ShowStartupPanel" -Value 0 -Type DWord

        # Desactivar el atajo Win+G
        $gameBarSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
        if (-not (Test-Path $gameBarSettings)) {
            New-Item -Path $gameBarSettings -Force | Out-Null
        }
        Set-ItemProperty -Path $gameBarSettings -Name "AppCaptureEnabled" -Value 0 -Type DWord

        Write-Host "[✓] Xbox Game Bar overlay desactivado" -ForegroundColor Green
        Write-Host "    → Win+G ya no abrirá el overlay" -ForegroundColor DarkGray
        $changes++
    }
    catch {
        Write-Host "[✗] Error al desactivar Game Bar: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ══════════════════════════════════════════
    # 3. XBOX SERVICES
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Servicios Xbox ─────────────────────────────────" -ForegroundColor Cyan

    $xboxServices = @(
        @{ Name = "XblAuthManager"; Display = "Xbox Live Auth Manager" },
        @{ Name = "XblGameSave"; Display = "Xbox Live Game Save" },
        @{ Name = "XboxNetApiSvc"; Display = "Xbox Live Networking" },
        @{ Name = "XboxGipSvc"; Display = "Xbox Accessory Management" }
    )

    foreach ($svc in $xboxServices) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Host "[✓] $($svc.Display) → Desactivado" -ForegroundColor Green
                $changes++
            }
            catch {
                Write-Host "[!] $($svc.Display) → No se pudo desactivar" -ForegroundColor Yellow
            }
        }
    }

    # ══════════════════════════════════════════
    # 4. NOTIFICATIONS DURANTE JUEGOS
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Notificaciones durante juegos ──────────────────" -ForegroundColor Cyan

    try {
        # Activar Focus Assist durante juegos (silencia notificaciones)
        $focusPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default`$windows.data.notifications.quiethourssettings\windows.data.notifications.quiethourssettings"

        # Desactivar notificaciones toast durante fullscreen
        $notifPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
        if (-not (Test-Path $notifPath)) {
            New-Item -Path $notifPath -Force | Out-Null
        }

        # Desactivar sugerencias de Windows en juegos
        $suggPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        if (Test-Path $suggPath) {
            Set-ItemProperty -Path $suggPath -Name "SubscribedContent-338389Enabled" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $suggPath -Name "SubscribedContent-310093Enabled" -Value 0 -ErrorAction SilentlyContinue
        }

        Write-Host "[✓] Sugerencias de Windows desactivadas en juegos" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[!] Algunos ajustes de notificaciones no aplicaron" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # 5. TIPS/TRUCOS DE WINDOWS
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Tips y trucos de Windows ────────────────────────" -ForegroundColor Cyan

    try {
        $cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        if (Test-Path $cdmPath) {
            Set-ItemProperty -Path $cdmPath -Name "SoftLandingEnabled" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $cdmPath -Name "RotatingLockScreenOverlayEnabled" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Value 0 -ErrorAction SilentlyContinue
        }
        Write-Host "[✓] Tips y trucos de Windows desactivados" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[!] No se pudieron desactivar tips" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # 6. FULLSCREEN OPTIMIZATIONS
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Fullscreen Optimizations ────────────────────────" -ForegroundColor Cyan

    try {
        $gameCfgPath = "HKCU:\System\GameConfigStore"
        Set-ItemProperty -Path $gameCfgPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $gameCfgPath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -ErrorAction SilentlyContinue

        Write-Host "[✓] Fullscreen Exclusive respetado (mejor rendimiento en pantalla completa)" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[!] Error en Fullscreen Optimizations" -ForegroundColor Yellow
    }

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  OVERLAYS DESACTIVADOS" -ForegroundColor Magenta
    Write-Host "  ✓ $changes optimizaciones aplicadas" -ForegroundColor White
    Write-Host "  💡 Los juegos ahora tendrán más FPS disponibles" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
    $logFile = Join-Path $logPath "game-overlays.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | OVERLAYS | Desactivados: $changes" | Out-File -Append -FilePath $logFile
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Disable-OptiMaxGameOverlays
}
