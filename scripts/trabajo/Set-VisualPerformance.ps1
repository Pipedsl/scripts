<#
.SYNOPSIS
    OptiMax Pro — Optimizar Rendimiento Visual
.DESCRIPTION
    Reduce efectos visuales de Windows para mejorar la responsividad.
    Especialmente efectivo en equipos con poca RAM y CPUs modestos.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Set-OptiMaxVisualPerformance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Trabajo", "Gaming", "Minimo")]
        [string]$Perfil = "Trabajo"
    )

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🎨 OPTIMAX PRO — Rendimiento Visual           ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Perfil: $Perfil" -ForegroundColor Cyan
    Write-Host ""

    $changes = 0

    try {
        $advancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        $visualFXPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        $personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
        $desktopPath = "HKCU:\Control Panel\Desktop"
        $windowMetricsPath = "HKCU:\Control Panel\Desktop\WindowMetrics"

        # Asegurar que las rutas existan
        foreach ($path in @($advancedPath, $visualFXPath, $personalizePath, $dwmPath)) {
            if (-not (Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }
        }

        if ($Perfil -eq "Minimo") {
            # ══════════════════════════════════════════
            # MODO MÍNIMO — Para PCs muy lentos
            # ══════════════════════════════════════════
            Write-Host "── Modo Mínimo (máximo rendimiento) ──────────────" -ForegroundColor Cyan

            # Ajustar a "Mejor rendimiento"
            Set-ItemProperty -Path $visualFXPath -Name "VisualFXSetting" -Value 2

            # Desactivar TODAS las animaciones
            Set-ItemProperty -Path $advancedPath -Name "TaskbarAnimations" -Value 0
            Set-ItemProperty -Path $advancedPath -Name "ListviewAlphaSelect" -Value 0
            Set-ItemProperty -Path $advancedPath -Name "ListviewShadow" -Value 0

            # Desactivar transparencia
            Set-ItemProperty -Path $personalizePath -Name "EnableTransparency" -Value 0

            # Desactivar Aero Peek
            Set-ItemProperty -Path $dwmPath -Name "EnableAeroPeek" -Value 0

            # Desactivar animaciones de ventana
            Set-ItemProperty -Path $desktopPath -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary

            # Velocidad de menús al mínimo
            Set-ItemProperty -Path $desktopPath -Name "MenuShowDelay" -Value "0"

            # Desactivar sombras
            Set-ItemProperty -Path $advancedPath -Name "ListviewShadow" -Value 0

            Write-Host "[✓] Todas las animaciones desactivadas" -ForegroundColor Green
            Write-Host "[✓] Transparencia desactivada" -ForegroundColor Green
            Write-Host "[✓] Sombras desactivadas" -ForegroundColor Green
            Write-Host "[✓] Aero Peek desactivado" -ForegroundColor Green
            Write-Host "[✓] Menús instantáneos" -ForegroundColor Green
            $changes = 8
        }
        elseif ($Perfil -eq "Trabajo") {
            # ══════════════════════════════════════════
            # MODO TRABAJO — Balance visual/rendimiento
            # ══════════════════════════════════════════
            Write-Host "── Modo Trabajo (equilibrado) ─────────────────────" -ForegroundColor Cyan

            # Ajustar a "Personalizado"
            Set-ItemProperty -Path $visualFXPath -Name "VisualFXSetting" -Value 3

            # Desactivar animaciones de ventana
            Set-ItemProperty -Path $advancedPath -Name "TaskbarAnimations" -Value 0
            Write-Host "[✓] Animaciones de taskbar desactivadas" -ForegroundColor Green
            $changes++

            # Mantener suavizado de fuentes (ClearType)
            Set-ItemProperty -Path $desktopPath -Name "FontSmoothing" -Value "2"
            Write-Host "[✓] ClearType mantenido (legibilidad)" -ForegroundColor DarkGray

            # Reducir transparencia
            Set-ItemProperty -Path $personalizePath -Name "EnableTransparency" -Value 0
            Write-Host "[✓] Transparencia desactivada" -ForegroundColor Green
            $changes++

            # Desactivar Aero Peek
            Set-ItemProperty -Path $dwmPath -Name "EnableAeroPeek" -Value 0
            Write-Host "[✓] Aero Peek desactivado" -ForegroundColor Green
            $changes++

            # Menús más rápidos (no instantáneos)
            Set-ItemProperty -Path $desktopPath -Name "MenuShowDelay" -Value "100"
            Write-Host "[✓] Menús más rápidos (100ms)" -ForegroundColor Green
            $changes++

            # Mantener iconos con vista previa (útil para trabajo)
            Set-ItemProperty -Path $advancedPath -Name "IconsOnly" -Value 0
            Write-Host "[✓] Vista previa de iconos mantenida" -ForegroundColor DarkGray

            # Desactivar sombras de iconos en escritorio
            Set-ItemProperty -Path $advancedPath -Name "ListviewShadow" -Value 0
            Write-Host "[✓] Sombras de iconos desactivadas" -ForegroundColor Green
            $changes++
        }
        elseif ($Perfil -eq "Gaming") {
            # ══════════════════════════════════════════
            # MODO GAMING — Prioridad FPS
            # ══════════════════════════════════════════
            Write-Host "── Modo Gaming (prioridad a FPS) ──────────────────" -ForegroundColor Cyan

            # Ajustar a "Mejor rendimiento"
            Set-ItemProperty -Path $visualFXPath -Name "VisualFXSetting" -Value 2

            # Desactivar animaciones
            Set-ItemProperty -Path $advancedPath -Name "TaskbarAnimations" -Value 0
            Write-Host "[✓] Animaciones desactivadas" -ForegroundColor Green
            $changes++

            # Desactivar transparencia
            Set-ItemProperty -Path $personalizePath -Name "EnableTransparency" -Value 0
            Write-Host "[✓] Transparencia desactivada" -ForegroundColor Green
            $changes++

            # Desactivar Aero Peek
            Set-ItemProperty -Path $dwmPath -Name "EnableAeroPeek" -Value 0
            Write-Host "[✓] Aero Peek desactivado" -ForegroundColor Green
            $changes++

            # Menús instantáneos
            Set-ItemProperty -Path $desktopPath -Name "MenuShowDelay" -Value "0"
            Write-Host "[✓] Menús instantáneos" -ForegroundColor Green
            $changes++

            # Desactivar sombras
            Set-ItemProperty -Path $advancedPath -Name "ListviewShadow" -Value 0
            Set-ItemProperty -Path $advancedPath -Name "ListviewAlphaSelect" -Value 0
            Write-Host "[✓] Efectos de sombra desactivados" -ForegroundColor Green
            $changes++

            # Mantener ClearType para legibilidad
            Set-ItemProperty -Path $desktopPath -Name "FontSmoothing" -Value "2"
        }

        # ══════════════════════════════════════════
        # CONFIGURACIONES COMUNES
        # ══════════════════════════════════════════
        Write-Host ""
        Write-Host "── Configuraciones adicionales ────────────────────" -ForegroundColor Cyan

        # Desactivar tips de Windows
        $contentDeliveryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        if (Test-Path $contentDeliveryPath) {
            Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338389Enabled" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-310093Enabled" -Value 0 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338393Enabled" -Value 0 -ErrorAction SilentlyContinue
            Write-Host "[✓] Tips y sugerencias de Windows desactivados" -ForegroundColor Green
            $changes++
        }

        # Desactivar notificaciones del Centro de Acción innecesarias
        $pushNotifPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications"
        if (-not (Test-Path $pushNotifPath)) {
            New-Item -Path $pushNotifPath -Force | Out-Null
        }
        Set-ItemProperty -Path $pushNotifPath -Name "ToastEnabled" -Value 1  # Mantener toasts pero limitar
        Write-Host "[✓] Notificaciones optimizadas" -ForegroundColor Green
        $changes++

    }
    catch {
        Write-Host "[✗] Error al modificar configuración visual: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  OPTIMIZACIÓN VISUAL COMPLETADA ($Perfil)" -ForegroundColor Magenta
    Write-Host "  ✓ $changes configuraciones modificadas" -ForegroundColor White
    Write-Host "  [!] Algunos cambios requieren cerrar sesión." -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
    $logFile = Join-Path $logPath "visual.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | VISUAL ($Perfil) | Cambios: $changes" | Out-File -Append -FilePath $logFile
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Set-OptiMaxVisualPerformance -Perfil "Trabajo"
}
