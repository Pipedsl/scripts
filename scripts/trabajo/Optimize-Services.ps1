<#
.SYNOPSIS
    OptiMax Pro — Optimizar Servicios de Windows
.DESCRIPTION
    Desactiva servicios innecesarios para liberar RAM y CPU.
    Enfocado en telemetría, indexación y servicios no esenciales.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Optimize-OptiMaxServices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Trabajo", "Gaming")]
        [string]$Perfil = "Trabajo"
    )

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   ⚙️ OPTIMAX PRO — Optimizar Servicios          ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Perfil: $Perfil" -ForegroundColor Cyan
    Write-Host ""

    $optimized = 0
    $skipped = 0
    $ramFreedEstimate = 0

    # ══════════════════════════════════════════
    # SERVICIOS A DESACTIVAR (Comunes)
    # ══════════════════════════════════════════
    $commonServices = @(
        @{
            Name = "DiagTrack"
            Display = "Telemetría de Windows"
            Action = "Disabled"
            RAMEstimate = 15
            Reason = "Envía datos de uso a Microsoft. No afecta funcionalidad."
        },
        @{
            Name = "dmwappushservice"
            Display = "WAP Push Message Routing"
            Action = "Disabled"
            RAMEstimate = 5
            Reason = "Servicio auxiliar de telemetría."
        },
        @{
            Name = "MapsBroker"
            Display = "Downloaded Maps Manager"
            Action = "Disabled"
            RAMEstimate = 10
            Reason = "Descarga mapas offline. No necesario si usas Google Maps."
        },
        @{
            Name = "lfsvc"
            Display = "Geolocalización"
            Action = "Disabled"
            RAMEstimate = 5
            Reason = "Servicio de ubicación. No necesario en PCs de escritorio."
        },
        @{
            Name = "RemoteRegistry"
            Display = "Registro Remoto"
            Action = "Disabled"
            RAMEstimate = 3
            Reason = "Riesgo de seguridad. Permite editar registro remotamente."
        },
        @{
            Name = "WMPNetworkSvc"
            Display = "Windows Media Player Network"
            Action = "Disabled"
            RAMEstimate = 5
            Reason = "Streaming de WMP. Nadie lo usa."
        },
        @{
            Name = "TrkWks"
            Display = "Distributed Link Tracking"
            Action = "Disabled"
            RAMEstimate = 3
            Reason = "Seguimiento de archivos NTFS en red. No necesario si no usas red corporativa."
        },
        @{
            Name = "RetailDemo"
            Display = "Retail Demo Service"
            Action = "Disabled"
            RAMEstimate = 2
            Reason = "Modo demostración de tienda. Totalmente innecesario."
        },
        @{
            Name = "wisvc"
            Display = "Windows Insider Service"
            Action = "Disabled"
            RAMEstimate = 3
            Reason = "Solo para beta testers de Windows."
        },
        @{
            Name = "WerSvc"
            Display = "Windows Error Reporting"
            Action = "Manual"
            RAMEstimate = 5
            Reason = "Reportes de errores a Microsoft. Se puede poner manual."
        },
        @{
            Name = "Fax"
            Display = "Servicio de Fax"
            Action = "Disabled"
            RAMEstimate = 2
            Reason = "¿Fax en 2026? 😄"
        }
    )

    # Servicios específicos para perfil Trabajo
    $workServices = @(
        @{
            Name = "SysMain"
            Display = "SysMain (Superfetch)"
            Action = "Disabled"
            RAMEstimate = 50
            Reason = "Pre-carga apps en RAM. Contraproducente con poca RAM (8GB o menos)."
        },
        @{
            Name = "WSearch"
            Display = "Windows Search Indexer"
            Action = "Manual"
            RAMEstimate = 30
            Reason = "Indexa archivos constantemente. Consume disco. Se pone en manual."
        }
    )

    # Servicios adicionales para Gaming
    $gamingServices = @(
        @{
            Name = "SysMain"
            Display = "SysMain (Superfetch)"
            Action = "Disabled"
            RAMEstimate = 50
            Reason = "Compite con juegos por la RAM."
        },
        @{
            Name = "WSearch"
            Display = "Windows Search Indexer"
            Action = "Disabled"
            RAMEstimate = 30
            Reason = "Causa micro-stuttering durante juegos."
        },
        @{
            Name = "XblAuthManager"
            Display = "Xbox Live Auth Manager"
            Action = "Disabled"
            RAMEstimate = 8
            Reason = "Solo necesario para juegos de Xbox Live."
        },
        @{
            Name = "XblGameSave"
            Display = "Xbox Live Game Save"
            Action = "Disabled"
            RAMEstimate = 5
            Reason = "Guardado en la nube de Xbox. No necesario para Steam/Epic."
        },
        @{
            Name = "XboxNetApiSvc"
            Display = "Xbox Live Networking Service"
            Action = "Disabled"
            RAMEstimate = 8
            Reason = "Networking de Xbox Live."
        }
    )

    # Seleccionar servicios según perfil
    $servicesToOptimize = $commonServices
    if ($Perfil -eq "Trabajo") {
        $servicesToOptimize += $workServices
    }
    else {
        $servicesToOptimize += $gamingServices
    }

    # ══════════════════════════════════════════
    # APLICAR CAMBIOS
    # ══════════════════════════════════════════
    Write-Host "── Optimizando servicios ──────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    foreach ($svc in $servicesToOptimize) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                # Solo cambiar si no está ya en el estado deseado
                if ($service.StartType -ne $svc.Action) {
                    # Detener si está corriendo y queremos desactivarlo
                    if ($service.Status -eq "Running" -and $svc.Action -eq "Disabled") {
                        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
                    }

                    Set-Service -Name $svc.Name -StartupType $svc.Action -ErrorAction Stop

                    $statusIcon = if ($svc.Action -eq "Disabled") { "⛔" } else { "⏸️" }
                    Write-Host "[✓] $statusIcon $($svc.Display) → $($svc.Action)" -ForegroundColor Green
                    Write-Host "    Razón: $($svc.Reason)" -ForegroundColor DarkGray

                    $optimized++
                    $ramFreedEstimate += $svc.RAMEstimate
                }
                else {
                    Write-Host "[→] $($svc.Display) → Ya optimizado" -ForegroundColor DarkGray
                    $skipped++
                }
            }
            catch {
                Write-Host "[✗] No se pudo modificar: $($svc.Display)" -ForegroundColor Red
            }
        }
        else {
            $skipped++
        }
    }

    # ══════════════════════════════════════════
    # OPTIMIZAR TELEMETRÍA VÍA REGISTRO
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Desactivando Telemetría vía Registro ───────────" -ForegroundColor Cyan

    try {
        # Nivel de telemetría al mínimo (Security)
        $telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (-not (Test-Path $telemetryPath)) {
            New-Item -Path $telemetryPath -Force | Out-Null
        }
        Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord

        # Desactivar ID de publicidad
        $adPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        if (-not (Test-Path $adPath)) {
            New-Item -Path $adPath -Force | Out-Null
        }
        Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -Type DWord

        # Desactivar feedback automático
        $feedbackPath = "HKCU:\Software\Microsoft\Siuf\Rules"
        if (-not (Test-Path $feedbackPath)) {
            New-Item -Path $feedbackPath -Force | Out-Null
        }
        Set-ItemProperty -Path $feedbackPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord

        Write-Host "[✓] Telemetría reducida al mínimo" -ForegroundColor Green
        Write-Host "[✓] ID de publicidad desactivado" -ForegroundColor Green
        Write-Host "[✓] Feedback automático desactivado" -ForegroundColor Green
        $optimized += 3
    }
    catch {
        Write-Host "[✗] Error al modificar telemetría en registro" -ForegroundColor Red
    }

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  OPTIMIZACIÓN DE SERVICIOS COMPLETADA" -ForegroundColor Magenta
    Write-Host "  ✓ Optimizados: $optimized  |  → Omitidos: $skipped" -ForegroundColor White
    Write-Host "  📊 RAM estimada liberada: ~$ramFreedEstimate MB" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
    $logFile = Join-Path $logPath "services.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | SERVICIOS ($Perfil) | Optimizados: $optimized | RAM ~$ramFreedEstimate MB" | Out-File -Append -FilePath $logFile

    return $ramFreedEstimate
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Optimize-OptiMaxServices -Perfil "Trabajo"
}
