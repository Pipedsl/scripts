<#
.SYNOPSIS
    OptiMax Pro — Gestión de Programas de Inicio
.DESCRIPTION
    Lista, analiza y permite deshabilitar programas que se ejecutan al inicio.
    Crea backup de la configuración actual antes de cambios.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Optimize-OptiMaxStartupApps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$AutoOptimize
    )

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🚀 OPTIMAX PRO — Programas de Inicio          ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    # Apps que SIEMPRE deben mantenerse
    $essentialApps = @(
        "*Windows Security*",
        "*SecurityHealth*",
        "*AnyDesk*",
        "*Defender*",
        "*Audio*",
        "*Realtek*",
        "*NVIDIA*",
        "*AMD*",
        "*Intel*"
    )

    # Apps que se recomienda desactivar
    $recommendedDisable = @(
        "*OneDrive*",
        "*Skype*",
        "*Teams*",
        "*Spotify*",
        "*Discord*",
        "*Steam*",
        "*Epic*",
        "*Origin*",
        "*iTunes*",
        "*Adobe*",
        "*Cortana*",
        "*Edge*",
        "*Chrome*",
        "*Java*",
        "*Update*"
    )

    # ══════════════════════════════════════════
    # OBTENER PROGRAMAS DE INICIO
    # ══════════════════════════════════════════
    Write-Host "── Analizando programas de inicio ─────────────────" -ForegroundColor Cyan
    Write-Host ""

    # Método 1: Registro del usuario
    $startupPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    )

    $allStartupApps = @()

    foreach ($path in $startupPaths) {
        if (Test-Path $path) {
            $items = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
            $properties = $items.PSObject.Properties | Where-Object {
                $_.Name -notlike "PS*" -and $_.Name -ne "(default)"
            }

            foreach ($prop in $properties) {
                $allStartupApps += @{
                    Name     = $prop.Name
                    Command  = $prop.Value
                    Location = $path
                    Source   = "Registry"
                }
            }
        }
    }

    # Método 2: Carpeta de inicio
    $startupFolder = [Environment]::GetFolderPath('Startup')
    $commonStartupFolder = [Environment]::GetFolderPath('CommonStartup')

    foreach ($folder in @($startupFolder, $commonStartupFolder)) {
        if (Test-Path $folder) {
            $shortcuts = Get-ChildItem -Path $folder -Filter "*.lnk" -ErrorAction SilentlyContinue
            foreach ($shortcut in $shortcuts) {
                $allStartupApps += @{
                    Name     = $shortcut.BaseName
                    Command  = $shortcut.FullName
                    Location = $folder
                    Source   = "Startup Folder"
                }
            }
        }
    }

    # Método 3: Task Scheduler (tareas al inicio)
    try {
        $scheduledTasks = Get-ScheduledTask -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Triggers | Where-Object { $_ -is [CimInstance] -and $_.CimClass.CimClassName -eq "MSFT_TaskLogonTrigger" }
            } |
            Where-Object { $_.State -eq "Ready" }

        foreach ($task in $scheduledTasks) {
            $allStartupApps += @{
                Name     = $task.TaskName
                Command  = ($task.Actions | Select-Object -First 1).Execute
                Location = $task.TaskPath
                Source   = "Task Scheduler"
            }
        }
    }
    catch {
        # Silenciar errores de Task Scheduler
    }

    # ══════════════════════════════════════════
    # CREAR BACKUP
    # ══════════════════════════════════════════
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }

    $backupFile = Join-Path $logPath "startup-backup-$(Get-Date -Format 'yyyyMMdd-HHmm').json"
    $allStartupApps | ConvertTo-Json -Depth 3 | Out-File -FilePath $backupFile
    Write-Host "[✓] Backup de inicio guardado: $backupFile" -ForegroundColor Green
    Write-Host ""

    # ══════════════════════════════════════════
    # MOSTRAR Y CLASIFICAR
    # ══════════════════════════════════════════
    Write-Host "  Total de programas al inicio: $($allStartupApps.Count)" -ForegroundColor White
    Write-Host ""

    $index = 1
    $toDisable = @()

    foreach ($app in $allStartupApps) {
        $isEssential = $false
        $isRecommendedDisable = $false

        foreach ($pattern in $essentialApps) {
            if ($app.Name -like $pattern) {
                $isEssential = $true
                break
            }
        }

        # Las tareas internas de Windows (\Microsoft\...) nunca se recomiendan desactivar
        # (ej: ClipESU gestiona la licencia de actualizaciones extendidas de Windows 10)
        $isWindowsTask = $app.Source -eq "Task Scheduler" -and $app.Location -like "\Microsoft\*"
        # RunOnce: tareas de limpieza que se ejecutan una sola vez y se borran solas (no afectan el arranque)
        $isRunOnce = $app.Source -eq "Registry" -and $app.Location -like "*\RunOnce"

        if (-not $isWindowsTask -and -not $isRunOnce) {
            foreach ($pattern in $recommendedDisable) {
                if ($app.Name -like $pattern -or $app.Command -like $pattern) {
                    $isRecommendedDisable = $true
                    break
                }
            }
        }

        if ($isEssential) {
            Write-Host "  $index. 🟢 $($app.Name)" -ForegroundColor Green
            Write-Host "       → ESENCIAL (no tocar)" -ForegroundColor DarkGray
        }
        elseif ($isRecommendedDisable) {
            Write-Host "  $index. 🔴 $($app.Name)" -ForegroundColor Red
            Write-Host "       → RECOMENDADO DESACTIVAR [$($app.Source)]" -ForegroundColor DarkGray
            $toDisable += $app
        }
        else {
            Write-Host "  $index. 🟡 $($app.Name)" -ForegroundColor Yellow
            Write-Host "       → Revisar manualmente [$($app.Source)]" -ForegroundColor DarkGray
        }

        $index++
    }

    # ══════════════════════════════════════════
    # DESACTIVAR (Auto o Manual)
    # ══════════════════════════════════════════
    if ($toDisable.Count -gt 0) {
        Write-Host ""
        Write-Host "── Programas recomendados para desactivar ─────────" -ForegroundColor Cyan
        Write-Host "  Se encontraron $($toDisable.Count) programas recomendados para desactivar." -ForegroundColor White

        if ($AutoOptimize) {
            $confirm = 'S'
        }
        else {
            Write-Host ""
            Write-Host "  ¿Desactivar los $($toDisable.Count) programas recomendados? (S/N): " -ForegroundColor Yellow -NoNewline
            $confirm = Read-Host
        }

        if ($confirm -eq 'S' -or $confirm -eq 's') {
            $disabled = 0
            foreach ($app in $toDisable) {
                try {
                    if ($app.Source -eq "Registry") {
                        Remove-ItemProperty -Path $app.Location -Name $app.Name -ErrorAction Stop
                        Write-Host "[✓] Desactivado: $($app.Name)" -ForegroundColor Green
                        $disabled++
                    }
                    elseif ($app.Source -eq "Startup Folder") {
                        Remove-Item -Path $app.Command -Force -ErrorAction Stop
                        Write-Host "[✓] Eliminado del inicio: $($app.Name)" -ForegroundColor Green
                        $disabled++
                    }
                    elseif ($app.Source -eq "Task Scheduler") {
                        Disable-ScheduledTask -TaskName $app.Name -TaskPath $app.Location -ErrorAction Stop | Out-Null
                        Write-Host "[✓] Tarea desactivada: $($app.Name)" -ForegroundColor Green
                        $disabled++
                    }
                }
                catch {
                    Write-Host "[!] No se pudo desactivar: $($app.Name)" -ForegroundColor Yellow
                    Write-Host "    Motivo: $(($_.Exception.Message -split "`r?`n")[0])" -ForegroundColor DarkGray
                }
            }

            Write-Host ""
            Write-Host "  ✓ $disabled programas desactivados del inicio" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  GESTIÓN DE INICIO COMPLETADA" -ForegroundColor Magenta
    Write-Host "  [!] Reiniciar para ver los cambios." -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Optimize-OptiMaxStartupApps
}
