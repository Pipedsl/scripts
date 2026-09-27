<#
.SYNOPSIS
    OptiMax Pro — Desactivar Bloatware
.DESCRIPTION
    Desactiva y/o desinstala software innecesario preinstalado:
    - McAfee WebAdvisor y componentes
    - SDXHelper.exe (Office SDK Helper)
    - Apps preinstaladas de Windows (juegos, redes sociales)
    NOTA: AnyDesk se PRESERVA ya que es herramienta de trabajo remoto.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Disable-OptiMaxBloatware {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Aggressive
    )

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🗑️ OPTIMAX PRO — Eliminar Bloatware           ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    $removed = 0
    $failed = 0

    # ══════════════════════════════════════════
    # LISTA DE APPS PROTEGIDAS (NO TOCAR)
    # ══════════════════════════════════════════
    $protectedApps = @(
        "*AnyDesk*",         # Herramienta de trabajo remoto
        "*Calculator*",       # Calculadora
        "*Photos*",          # Fotos
        "*WindowsStore*",    # Microsoft Store
        "*ScreenSketch*",    # Recortes
        "*SnippingTool*",    # Herramienta recortes
        "*MSPaint*",         # Paint
        "*Notepad*",         # Bloc de notas
        "*Terminal*",        # Windows Terminal
        "*WebExperience*"    # Widgets (puede ser útil)
    )

    Write-Host "[!] Apps PROTEGIDAS (no se tocarán):" -ForegroundColor Cyan
    Write-Host "    → AnyDesk (acceso remoto)" -ForegroundColor DarkGray
    Write-Host "    → Calculadora, Fotos, Paint, Notepad, Store" -ForegroundColor DarkGray
    Write-Host ""

    # ══════════════════════════════════════════
    # 1. DESINSTALAR McAFEE
    # ══════════════════════════════════════════
    Write-Host "── Eliminando McAfee ──────────────────────────────" -ForegroundColor Cyan

    # Buscar procesos McAfee y terminarlos
    $mcafeeProcesses = Get-Process -Name "*mcafee*", "*McShield*", "*McSvHost*", "*mfevtps*" -ErrorAction SilentlyContinue
    if ($mcafeeProcesses) {
        Write-Host "[→] Deteniendo procesos de McAfee..." -ForegroundColor Yellow
        $mcafeeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "[✓] Procesos de McAfee detenidos" -ForegroundColor Green
    }

    # Desinstalar McAfee vía WMI
    $mcafeeProducts = Get-CimInstance -ClassName Win32_Product -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*McAfee*" }

    if ($mcafeeProducts) {
        foreach ($product in $mcafeeProducts) {
            Write-Host "[→] Desinstalando: $($product.Name)..." -ForegroundColor Yellow
            try {
                $product | Invoke-CimMethod -MethodName Uninstall -ErrorAction Stop | Out-Null
                Write-Host "[✓] $($product.Name) desinstalado" -ForegroundColor Green
                $removed++
            }
            catch {
                Write-Host "[!] No se pudo desinstalar $($product.Name) automáticamente" -ForegroundColor Yellow
                Write-Host "    Intenta con la herramienta MCPR de McAfee: https://mcafee.com/consumer-support" -ForegroundColor DarkGray
                $failed++
            }
        }
    }

    # Desinstalar McAfee vía AppxPackage
    $mcafeeAppx = Get-AppxPackage -AllUsers -Name "*McAfee*" -ErrorAction SilentlyContinue
    if ($mcafeeAppx) {
        foreach ($app in $mcafeeAppx) {
            Write-Host "[→] Removiendo AppX: $($app.Name)..." -ForegroundColor Yellow
            Remove-AppxPackage -Package $app.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            Write-Host "[✓] $($app.Name) removido" -ForegroundColor Green
            $removed++
        }
    }

    # Desactivar servicios de McAfee que puedan quedar
    $mcafeeServices = Get-Service -Name "*mcafee*", "*McShield*", "*mfevtp*" -ErrorAction SilentlyContinue
    foreach ($svc in $mcafeeServices) {
        Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Servicio $($svc.Name) desactivado" -ForegroundColor Green
    }

    if (-not $mcafeeProducts -and -not $mcafeeAppx -and -not $mcafeeProcesses) {
        Write-Host "[✓] McAfee no detectado en el sistema" -ForegroundColor DarkGray
    }

    # ══════════════════════════════════════════
    # 2. DESACTIVAR SDXHELPER.EXE
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Desactivando SDXHelper.exe ─────────────────────" -ForegroundColor Cyan

    # Terminar proceso SDXHelper
    $sdxProcess = Get-Process -Name "SDXHelper" -ErrorAction SilentlyContinue
    if ($sdxProcess) {
        $sdxProcess | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Proceso SDXHelper detenido" -ForegroundColor Green
    }

    # Desactivar tareas programadas de Office Feature Updates
    $officeTasks = @(
        "\Microsoft\Office\Office Feature Updates",
        "\Microsoft\Office\Office Feature Updates Logon"
    )

    foreach ($task in $officeTasks) {
        try {
            $taskInfo = schtasks /Query /TN $task 2>$null
            if ($LASTEXITCODE -eq 0) {
                schtasks /Change /TN $task /Disable 2>$null
                Write-Host "[✓] Tarea desactivada: $task" -ForegroundColor Green
                $removed++
            }
        }
        catch {
            Write-Host "[→] Tarea no encontrada: $task" -ForegroundColor DarkGray
        }
    }

    # ══════════════════════════════════════════
    # 3. APPS PREINSTALADAS DE WINDOWS
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Eliminando Apps Preinstaladas Innecesarias ─────" -ForegroundColor Cyan

    # Lista de apps a remover (conservadoras para trabajo)
    $appsToRemove = @(
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.People",
        "Microsoft.PowerAutomateDesktop",
        "Microsoft.Todos",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Clipchamp.Clipchamp",
        "Microsoft.549981C3F5F10",
        "king.com.CandyCrushSaga",
        "king.com.CandyCrushSodaSaga",
        "SpotifyAB.SpotifyMusic",
        "BytedancePte.Ltd.TikTok",
        "Disney.37853FC22B2CE",
        "Facebook.Facebook",
        "Facebook.Instagram",
        "9E2F88E3.Twitter"
    )

    if ($Aggressive) {
        $appsToRemove += @(
            "Microsoft.WindowsAlarms",
            "Microsoft.WindowsCamera",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.MicrosoftStickyNotes"
        )
    }

    foreach ($appName in $appsToRemove) {
        # Puede devolver varios paquetes (distintas versiones/usuarios): hay que procesarlos uno a uno
        $packages = @(Get-AppxPackage -Name $appName -AllUsers -ErrorAction SilentlyContinue)
        $provisioned = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -eq $appName })
        if ($packages.Count -eq 0 -and $provisioned.Count -eq 0) { continue }

        # Verificar que no está en la lista de protegidos
        $isProtected = $false
        foreach ($protected in $protectedApps) {
            if ($appName -like $protected) {
                $isProtected = $true
                break
            }
        }
        if ($isProtected) { continue }

        $appErrors = @()
        foreach ($pkg in $packages) {
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            }
            catch {
                # En Windows 10 -AllUsers falla con algunas apps del sistema: reintentar para el usuario actual
                try {
                    Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                }
                catch {
                    $appErrors += $_.Exception.Message
                }
            }
        }

        # Quitar la copia aprovisionada para que no se reinstale en usuarios nuevos
        foreach ($prov in $provisioned) {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop | Out-Null
            }
            catch {
                $appErrors += $_.Exception.Message
            }
        }

        if ($appErrors.Count -eq 0) {
            Write-Host "[✓] Removido: $appName" -ForegroundColor Green
            $removed++
        }
        else {
            $reason = ($appErrors[0] -split "`r?`n")[0]
            Write-Host "[!] No se pudo remover: $appName" -ForegroundColor Yellow
            Write-Host "    Motivo: $reason" -ForegroundColor DarkGray
            $failed++
        }
    }

    # Prevenir reinstalación
    Write-Host ""
    Write-Host "── Previniendo reinstalación de bloatware ─────────" -ForegroundColor Cyan

    try {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord
        Set-ItemProperty -Path $regPath -Name "DisableCloudOptimizedContent" -Value 1 -Type DWord
        Write-Host "[✓] Reinstalación automática de bloatware bloqueada" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] No se pudo bloquear reinstalación automática" -ForegroundColor Yellow
    }

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  LIMPIEZA DE BLOATWARE COMPLETADA" -ForegroundColor Magenta
    Write-Host "  ✓ Removidos: $removed  |  ! Con errores: $failed" -ForegroundColor White
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
    $logFile = Join-Path $logPath "bloatware.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | BLOATWARE | Removidos: $removed | Errores: $failed" | Out-File -Append -FilePath $logFile
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Disable-OptiMaxBloatware
}
