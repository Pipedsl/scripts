<#
.SYNOPSIS
    OptiMax Pro — Diagnóstico Completo del Sistema
.DESCRIPTION
    Genera un reporte detallado del estado del PC incluyendo:
    - Información del hardware (CPU, RAM, Disco, GPU)
    - Top procesos por consumo de RAM y CPU
    - Servicios innecesarios activos
    - Programas de inicio
    - Espacio en disco
    - Recomendaciones de hardware y software
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Get-OptiMaxSystemReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$ExportHTML
    )

    Clear-Host

    # ══════════════════════════════════════════════════════════
    # HEADER
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "  ║                                                        ║" -ForegroundColor Magenta
    Write-Host "  ║    ██████  ██████  ████████ ██ ███    ███  █████  ██   ║" -ForegroundColor Magenta
    Write-Host "  ║   ██    ██ ██   ██    ██    ██ ████  ████ ██   ██  ██  ║" -ForegroundColor Magenta
    Write-Host "  ║   ██    ██ ██████     ██    ██ ██ ████ ██ ███████   ██ ║" -ForegroundColor Magenta
    Write-Host "  ║   ██    ██ ██         ██    ██ ██  ██  ██ ██   ██  ██  ║" -ForegroundColor Magenta
    Write-Host "  ║    ██████  ██         ██    ██ ██      ██ ██   ██ ██   ║" -ForegroundColor Magenta
    Write-Host "  ║                        P R O                           ║" -ForegroundColor Magenta
    Write-Host "  ║           Diagnóstico Completo del Sistema             ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    $reportData = @{}
    $recommendations = @()

    # ══════════════════════════════════════════════════════════
    # 1. INFORMACIÓN DEL SISTEMA
    # ══════════════════════════════════════════════════════════
    Write-Host "  ── 📋 Información del Sistema ────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem
        $bios = Get-CimInstance -ClassName Win32_BIOS

        $osName = $os.Caption
        $osBuild = $os.BuildNumber
        $osArch = $os.OSArchitecture
        $pcName = $cs.Name
        $pcManufacturer = $cs.Manufacturer
        $pcModel = $cs.Model
        $lastBoot = $os.LastBootUpTime
        $uptime = (Get-Date) - $lastBoot

        Write-Host "    Equipo:         $pcManufacturer $pcModel" -ForegroundColor White
        Write-Host "    Nombre PC:      $pcName" -ForegroundColor White
        Write-Host "    SO:             $osName" -ForegroundColor White
        Write-Host "    Build:          $osBuild ($osArch)" -ForegroundColor White
        Write-Host "    Último inicio:  $($lastBoot.ToString('dd/MM/yyyy HH:mm'))" -ForegroundColor White
        Write-Host "    Tiempo activo:  $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor White

        if ($uptime.Days -gt 7) {
            Write-Host "    [!] El equipo lleva $($uptime.Days) días sin reiniciar" -ForegroundColor Yellow
            $recommendations += "🔄 Reiniciar el equipo (lleva $($uptime.Days) días encendido)"
        }
    }
    catch {
        Write-Host "    [✗] Error obteniendo info del sistema" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # 2. PROCESADOR (CPU)
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🧠 Procesador (CPU) ──────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor
        $cpuLoad = $cpu.LoadPercentage
        $cpuName = $cpu.Name.Trim()
        $cpuCores = $cpu.NumberOfCores
        $cpuThreads = $cpu.NumberOfLogicalProcessors
        $cpuSpeed = [math]::Round($cpu.MaxClockSpeed / 1000, 2)

        Write-Host "    Modelo:     $cpuName" -ForegroundColor White
        Write-Host "    Núcleos:    $cpuCores físicos / $cpuThreads lógicos" -ForegroundColor White
        Write-Host "    Velocidad:  $cpuSpeed GHz (máx)" -ForegroundColor White

        if ($cpuLoad -gt 80) {
            Write-Host "    Uso actual: $cpuLoad%" -ForegroundColor Red
            $recommendations += "⚠️ CPU al $cpuLoad% - Revisar procesos que consumen CPU"
        }
        elseif ($cpuLoad -gt 50) {
            Write-Host "    Uso actual: $cpuLoad%" -ForegroundColor Yellow
        }
        else {
            Write-Host "    Uso actual: $cpuLoad%" -ForegroundColor Green
        }

        $reportData["CPU"] = @{ Name = $cpuName; Cores = $cpuCores; Load = $cpuLoad }
    }
    catch {
        Write-Host "    [✗] Error obteniendo info de CPU" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # 3. MEMORIA RAM
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🧮 Memoria RAM ───────────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
        $usedRAM = [math]::Round($totalRAM - $freeRAM, 1)
        $ramPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 0)

        # Barra visual de uso de RAM
        $barLength = 30
        $filledLength = [math]::Round(($ramPercent / 100) * $barLength)
        $emptyLength = $barLength - $filledLength
        $bar = "█" * $filledLength + "░" * $emptyLength

        Write-Host "    Total:      $totalRAM GB" -ForegroundColor White
        Write-Host "    En uso:     $usedRAM GB ($ramPercent%)" -ForegroundColor White
        Write-Host "    Disponible: $freeRAM GB" -ForegroundColor White
        Write-Host ""

        if ($ramPercent -gt 85) {
            Write-Host "    [$bar] $ramPercent%" -ForegroundColor Red
            $recommendations += "🔴 RAM CRÍTICA al $ramPercent% - Considerar ampliar RAM o cerrar procesos"
        }
        elseif ($ramPercent -gt 70) {
            Write-Host "    [$bar] $ramPercent%" -ForegroundColor Yellow
            $recommendations += "🟡 RAM al $ramPercent% - Optimización de procesos recomendada"
        }
        else {
            Write-Host "    [$bar] $ramPercent%" -ForegroundColor Green
        }

        # Detalle de módulos de RAM
        Write-Host ""
        $ramModules = Get-CimInstance -ClassName Win32_PhysicalMemory
        Write-Host "    Módulos instalados:" -ForegroundColor DarkGray
        foreach ($module in $ramModules) {
            $moduleSize = [math]::Round($module.Capacity / 1GB, 0)
            $moduleSpeed = $module.Speed
            $moduleSlot = $module.DeviceLocator
            Write-Host "      $moduleSlot : $moduleSize GB @ $moduleSpeed MHz" -ForegroundColor DarkGray
        }

        # Slots vacíos
        $totalSlots = (Get-CimInstance -ClassName Win32_PhysicalMemoryArray).MemoryDevices
        $usedSlots = $ramModules.Count
        $freeSlots = $totalSlots - $usedSlots

        if ($freeSlots -gt 0 -and $ramPercent -gt 70) {
            Write-Host "      Slots disponibles: $freeSlots de $totalSlots" -ForegroundColor Yellow
            $recommendations += "💡 Hay $freeSlots slots de RAM libres - Se puede ampliar memoria"
        }

        if ($totalRAM -le 8.5 -and $totalRAM -ge 7.5) {
            $recommendations += "💰 RECOMENDACIÓN: Ampliar de 8GB a 16GB de RAM (~\$25.000-35.000 CLP)"
        }

        $reportData["RAM"] = @{ Total = $totalRAM; Used = $usedRAM; Percent = $ramPercent; FreeSlots = $freeSlots }
    }
    catch {
        Write-Host "    [✗] Error obteniendo info de RAM" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # 4. DISCOS
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 💾 Almacenamiento ────────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $disks = Get-CimInstance -ClassName Win32_DiskDrive
        foreach ($disk in $disks) {
            $sizeGB = [math]::Round($disk.Size / 1GB, 0)
            $diskType = if ($disk.MediaType -match "SSD" -or $disk.Model -match "SSD|NVMe") { "SSD" } else { "HDD" }

            # Intentar detectar tipo más preciso
            $physicalDisk = Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -eq $disk.Model }
            if ($physicalDisk) {
                $diskType = $physicalDisk.MediaType
            }

            Write-Host "    $($disk.Model)" -ForegroundColor White
            Write-Host "      Tipo: $diskType | Tamaño: $sizeGB GB" -ForegroundColor DarkGray

            if ($diskType -eq "HDD" -or $diskType -eq "Unspecified") {
                $recommendations += "🐌 Disco '$($disk.Model)' parece ser HDD - Cambiar a SSD mejora DRÁSTICAMENTE el rendimiento"
            }
        }

        # Espacio en particiones
        Write-Host ""
        $volumes = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
        foreach ($vol in $volumes) {
            $totalGB = [math]::Round($vol.Size / 1GB, 1)
            $freeGB = [math]::Round($vol.FreeSpace / 1GB, 1)
            $usedPercent = [math]::Round((($totalGB - $freeGB) / $totalGB) * 100, 0)

            $barLength = 20
            $filledLength = [math]::Round(($usedPercent / 100) * $barLength)
            $emptyLength = $barLength - $filledLength
            $bar = "█" * $filledLength + "░" * $emptyLength

            $color = if ($usedPercent -gt 90) { "Red" } elseif ($usedPercent -gt 75) { "Yellow" } else { "Green" }

            Write-Host "    $($vol.DeviceID)\ [$bar] $usedPercent% usado ($freeGB GB libres de $totalGB GB)" -ForegroundColor $color

            if ($freeGB -lt 10) {
                $recommendations += "⚠️ Disco $($vol.DeviceID) tiene solo $freeGB GB libres"
            }
        }
    }
    catch {
        Write-Host "    [✗] Error obteniendo info de discos" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # 5. GPU
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🎮 Tarjeta Gráfica (GPU) ────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $gpus = Get-CimInstance -ClassName Win32_VideoController
        foreach ($gpu in $gpus) {
            $gpuRAM = [math]::Round($gpu.AdapterRAM / 1GB, 1)
            Write-Host "    $($gpu.Name)" -ForegroundColor White
            Write-Host "      VRAM: $gpuRAM GB | Driver: $($gpu.DriverVersion)" -ForegroundColor DarkGray
            Write-Host "      Resolución: $($gpu.CurrentHorizontalResolution)x$($gpu.CurrentVerticalResolution)" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "    [✗] Error obteniendo info de GPU" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # 6. TOP 10 PROCESOS POR RAM
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 📊 Top 10 Procesos por Consumo de RAM ───────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $topRAM = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10
        Write-Host "    {0,-30} {1,10} {2,10}" -f "PROCESO", "RAM (MB)", "CPU (s)" -ForegroundColor DarkGray
        Write-Host "    $("-" * 52)" -ForegroundColor DarkGray

        foreach ($proc in $topRAM) {
            $ramMB = [math]::Round($proc.WorkingSet64 / 1MB, 0)
            $cpuSec = [math]::Round($proc.CPU, 1)

            $color = if ($ramMB -gt 500) { "Red" } elseif ($ramMB -gt 200) { "Yellow" } else { "White" }
            Write-Host ("    {0,-30} {1,10} {2,10}" -f $proc.ProcessName, "$ramMB MB", "$cpuSec s") -ForegroundColor $color
        }
    }
    catch {
        Write-Host "    [✗] Error obteniendo procesos" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # 7. PROGRAMAS DE INICIO
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🚀 Programas de Inicio ───────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $startupApps = Get-CimInstance -ClassName Win32_StartupCommand | Select-Object Name, Command, Location
        $startupCount = ($startupApps | Measure-Object).Count

        if ($startupCount -gt 0) {
            Write-Host "    Total de programas al inicio: $startupCount" -ForegroundColor White
            Write-Host ""

            foreach ($app in $startupApps) {
                $name = if ($app.Name.Length -gt 35) { $app.Name.Substring(0, 32) + "..." } else { $app.Name }
                Write-Host "    → $name" -ForegroundColor DarkGray
            }

            if ($startupCount -gt 5) {
                $recommendations += "🚀 Hay $startupCount programas al inicio - Reducir para mejorar tiempo de arranque"
            }
        }
        else {
            Write-Host "    No se detectaron programas de inicio (requiere revisión manual)" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "    [✗] Error obteniendo programas de inicio" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # 8. SERVICIOS PROBLEMÁTICOS
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🔍 Servicios Potencialmente Innecesarios ─────────────" -ForegroundColor Cyan
    Write-Host ""

    $problematicServices = @(
        @{ Name = "SysMain"; Desc = "SysMain/Superfetch (alto uso de disco en HDDs)" },
        @{ Name = "DiagTrack"; Desc = "Telemetría de Windows (envía datos a Microsoft)" },
        @{ Name = "WSearch"; Desc = "Windows Search Indexer (alto uso de disco)" },
        @{ Name = "dmwappushservice"; Desc = "Push de telemetría WAP" },
        @{ Name = "MapsBroker"; Desc = "Gestor de mapas descargados" },
        @{ Name = "lfsvc"; Desc = "Servicio de geolocalización" },
        @{ Name = "RemoteRegistry"; Desc = "Registro remoto (riesgo de seguridad)" },
        @{ Name = "WMPNetworkSvc"; Desc = "Streaming de Windows Media Player" },
        @{ Name = "XblAuthManager"; Desc = "Xbox Live Auth Manager" },
        @{ Name = "XblGameSave"; Desc = "Xbox Live Game Save" }
    )

    $activeUnnecessary = 0
    foreach ($svc in $problematicServices) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq "Running") {
            Write-Host "    [ACTIVO] $($svc.Desc)" -ForegroundColor Yellow
            $activeUnnecessary++
        }
    }

    if ($activeUnnecessary -eq 0) {
        Write-Host "    [✓] No se detectaron servicios innecesarios activos" -ForegroundColor Green
    }
    else {
        $recommendations += "🔧 $activeUnnecessary servicios innecesarios están activos y consumiendo recursos"
    }

    # ══════════════════════════════════════════════════════════
    # 9. SOFTWARE BLOATWARE DETECTADO
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🗑️ Bloatware Detectado ────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    $bloatwareList = @(
        "McAfee*", "Norton*", "Avast*", "AVG*",
        "*Candy*", "*BubbleWitch*", "*Solitaire*",
        "*Disney*", "*Spotify*", "*TikTok*",
        "*Facebook*", "*Instagram*", "*Twitter*",
        "*Clipchamp*"
    )

    $bloatwareFound = @()
    foreach ($pattern in $bloatwareList) {
        $found = Get-AppxPackage -Name $pattern -ErrorAction SilentlyContinue
        if ($found) {
            foreach ($app in $found) {
                $bloatwareFound += $app.Name
                Write-Host "    [ENCONTRADO] $($app.Name)" -ForegroundColor Yellow
            }
        }
    }

    # Buscar McAfee específicamente en programas instalados
    $mcafee = Get-CimInstance -ClassName Win32_Product -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*McAfee*" }
    if ($mcafee) {
        foreach ($m in $mcafee) {
            Write-Host "    [ENCONTRADO] $($m.Name) (programa instalado)" -ForegroundColor Red
            $bloatwareFound += $m.Name
        }
        $recommendations += "🗑️ McAfee detectado - Desinstalarlo liberará RAM y CPU significativamente"
    }

    # Buscar proceso SDXHelper
    $sdxHelper = Get-Process -Name "SDXHelper" -ErrorAction SilentlyContinue
    if ($sdxHelper) {
        Write-Host "    [ACTIVO] SDXHelper.exe (Office SDK Helper - alto uso de disco)" -ForegroundColor Red
        $recommendations += "🗑️ SDXHelper.exe activo - Desactivar tareas de Office Feature Updates"
    }

    if ($bloatwareFound.Count -eq 0 -and -not $mcafee -and -not $sdxHelper) {
        Write-Host "    [✓] No se detectó bloatware significativo" -ForegroundColor Green
    }

    # ══════════════════════════════════════════════════════════
    # 10. TEMPERATURA (si disponible)
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🌡️ Temperatura del Sistema ───────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $temp = Get-CimInstance -Namespace "root\WMI" -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue
        if ($temp) {
            foreach ($t in $temp) {
                $celsius = [math]::Round(($t.CurrentTemperature / 10) - 273.15, 1)
                $color = if ($celsius -gt 80) { "Red" } elseif ($celsius -gt 65) { "Yellow" } else { "Green" }
                Write-Host "    Zona térmica: $celsius °C" -ForegroundColor $color

                if ($celsius -gt 80) {
                    $recommendations += "🔥 Temperatura ALTA ($celsius°C) - Revisar ventilación/pasta térmica"
                }
            }
        }
        else {
            Write-Host "    [?] Sensores de temperatura no accesibles vía WMI" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "    [?] No se pudo leer temperatura del sistema" -ForegroundColor DarkGray
    }

    # ══════════════════════════════════════════════════════════
    # 11. RED
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ── 🌐 Conectividad de Red ───────────────────────────────" -ForegroundColor Cyan
    Write-Host ""

    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            $speed = if ($adapter.LinkSpeed) { $adapter.LinkSpeed } else { "Desconocida" }
            Write-Host "    $($adapter.Name): $($adapter.InterfaceDescription)" -ForegroundColor White
            Write-Host "      Estado: Conectado | Velocidad: $speed" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "    [✗] Error obteniendo info de red" -ForegroundColor Red
    }

    # ══════════════════════════════════════════════════════════
    # RECOMENDACIONES FINALES
    # ══════════════════════════════════════════════════════════
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "  ║          📋 RECOMENDACIONES DE OPTIMAX PRO              ║" -ForegroundColor Magenta
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    if ($recommendations.Count -eq 0) {
        Write-Host "  ✨ El sistema se encuentra en buen estado general." -ForegroundColor Green
        Write-Host "     Se recomienda mantenimiento preventivo periódico." -ForegroundColor DarkGray
    }
    else {
        $priority = 1
        foreach ($rec in $recommendations) {
            Write-Host "  $priority. $rec" -ForegroundColor White
            $priority++
        }
    }

    # Perfil sugerido
    Write-Host ""
    Write-Host "  ── Perfil de Optimización Sugerido ──────────────────────" -ForegroundColor Cyan

    $hasGPU = ($gpus | Where-Object { $_.Name -notmatch "Intel|Basic|Microsoft" }).Count -gt 0
    if ($hasGPU) {
        Write-Host "  🎮 GPU dedicada detectada → Perfil Gaming disponible" -ForegroundColor Green
    }
    Write-Host "  🏢 Perfil Trabajo → Recomendado para este equipo" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  Reporte generado: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor DarkGray
    Write-Host "  OptiMax Pro — Servicio Profesional de Optimización" -ForegroundColor DarkGray
    Write-Host "  ════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Guardar reporte en log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    }
    $logFile = Join-Path $logPath "diagnostico-$(Get-Date -Format 'yyyyMMdd-HHmm').log"

    # Exportar a archivo de texto
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    @"
=== REPORTE OPTIMAX PRO ===
Fecha: $timestamp
PC: $pcName ($pcManufacturer $pcModel)
SO: $osName (Build $osBuild)
CPU: $cpuName ($cpuCores cores, $cpuLoad% uso)
RAM: $usedRAM GB / $totalRAM GB ($ramPercent%)
Recomendaciones:
$($recommendations | ForEach-Object { "  - $_" } | Out-String)
"@ | Out-File -FilePath $logFile

    Write-Host "  [✓] Reporte guardado en: $logFile" -ForegroundColor Green
    Write-Host ""
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Get-OptiMaxSystemReport
}
