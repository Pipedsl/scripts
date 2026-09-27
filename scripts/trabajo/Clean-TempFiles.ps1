<#
.SYNOPSIS
    OptiMax Pro — Limpieza de Archivos Temporales
.DESCRIPTION
    Limpia archivos temporales del sistema, usuarios y navegadores.
    Libera espacio en disco y mejora el rendimiento.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Clear-OptiMaxTempFiles {
    [CmdletBinding()]
    param()

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🧹 OPTIMAX PRO — Limpieza de Temporales      ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    $totalFreed = 0
    $errors = 0

    # Función auxiliar para limpiar carpeta y calcular espacio liberado
    function Remove-TempFolder {
        param(
            [string]$Path,
            [string]$Description
        )

        if (Test-Path $Path) {
            $sizeBefore = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum

            try {
                Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

                $sizeAfter = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
                    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum

                $freed = [math]::Round(($sizeBefore - $sizeAfter) / 1MB, 1)

                if ($freed -gt 0) {
                    Write-Host "[✓] $Description → $freed MB liberados" -ForegroundColor Green
                }
                else {
                    Write-Host "[✓] $Description → Limpio" -ForegroundColor DarkGray
                }

                return $freed
            }
            catch {
                Write-Host "[!] $Description → Algunos archivos en uso" -ForegroundColor Yellow
                return 0
            }
        }
        else {
            Write-Host "[→] $Description → No encontrado" -ForegroundColor DarkGray
            return 0
        }
    }

    # ── 1. Carpeta TEMP del usuario ──
    Write-Host "── Archivos Temporales del Usuario ────────────────" -ForegroundColor Cyan
    $totalFreed += Remove-TempFolder -Path $env:TEMP -Description "Carpeta %TEMP% del usuario"

    # ── 2. Carpeta TEMP del sistema ──
    Write-Host ""
    Write-Host "── Archivos Temporales del Sistema ────────────────" -ForegroundColor Cyan
    $totalFreed += Remove-TempFolder -Path "C:\Windows\Temp" -Description "C:\Windows\Temp"

    # ── 3. Prefetch ──
    $totalFreed += Remove-TempFolder -Path "C:\Windows\Prefetch" -Description "Windows Prefetch"

    # ── 4. Caché de Windows Update ──
    Write-Host ""
    Write-Host "── Caché de Windows Update ────────────────────────" -ForegroundColor Cyan
    try {
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        $totalFreed += Remove-TempFolder -Path "C:\Windows\SoftwareDistribution\Download" -Description "Caché de Windows Update"
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "[!] No se pudo limpiar caché de Windows Update" -ForegroundColor Yellow
    }

    # ── 5. Caché de navegadores ──
    Write-Host ""
    Write-Host "── Caché de Navegadores ───────────────────────────" -ForegroundColor Cyan

    $userProfile = $env:USERPROFILE

    # Chrome
    $chromeCachePath = "$userProfile\AppData\Local\Google\Chrome\User Data\Default\Cache"
    $totalFreed += Remove-TempFolder -Path $chromeCachePath -Description "Google Chrome Cache"

    $chromeCodeCachePath = "$userProfile\AppData\Local\Google\Chrome\User Data\Default\Code Cache"
    $totalFreed += Remove-TempFolder -Path $chromeCodeCachePath -Description "Google Chrome Code Cache"

    # Edge
    $edgeCachePath = "$userProfile\AppData\Local\Microsoft\Edge\User Data\Default\Cache"
    $totalFreed += Remove-TempFolder -Path $edgeCachePath -Description "Microsoft Edge Cache"

    # Firefox
    $firefoxProfiles = "$userProfile\AppData\Local\Mozilla\Firefox\Profiles"
    if (Test-Path $firefoxProfiles) {
        $profiles = Get-ChildItem -Path $firefoxProfiles -Directory -ErrorAction SilentlyContinue
        foreach ($profile in $profiles) {
            $ffCache = Join-Path $profile.FullName "cache2"
            $totalFreed += Remove-TempFolder -Path $ffCache -Description "Firefox Cache ($($profile.Name))"
        }
    }

    # ── 6. Papelera de reciclaje ──
    Write-Host ""
    Write-Host "── Papelera de Reciclaje ──────────────────────────" -ForegroundColor Cyan
    try {
        $shell = New-Object -ComObject Shell.Application
        $recycleBin = $shell.Namespace(0xA)
        $itemCount = $recycleBin.Items().Count

        if ($itemCount -gt 0) {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "[✓] Papelera vaciada ($itemCount elementos)" -ForegroundColor Green
        }
        else {
            Write-Host "[✓] Papelera ya estaba vacía" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "[!] No se pudo vaciar la papelera" -ForegroundColor Yellow
    }

    # ── 7. Thumbnails cache ──
    Write-Host ""
    Write-Host "── Caché de Miniaturas ────────────────────────────" -ForegroundColor Cyan
    $thumbPath = "$userProfile\AppData\Local\Microsoft\Windows\Explorer"
    $thumbFiles = Get-ChildItem -Path $thumbPath -Filter "thumbcache_*" -ErrorAction SilentlyContinue
    if ($thumbFiles) {
        $thumbSize = ($thumbFiles | Measure-Object -Property Length -Sum).Sum
        $thumbMB = [math]::Round($thumbSize / 1MB, 1)
        Remove-Item -Path "$thumbPath\thumbcache_*" -Force -ErrorAction SilentlyContinue
        $totalFreed += $thumbMB
        Write-Host "[✓] Caché de miniaturas → $thumbMB MB liberados" -ForegroundColor Green
    }

    # ── 8. Archivos de error de Windows ──
    $totalFreed += Remove-TempFolder -Path "C:\Windows\LiveKernelReports" -Description "LiveKernelReports"
    $totalFreed += Remove-TempFolder -Path "C:\Windows\Minidump" -Description "Minidump"

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  LIMPIEZA COMPLETADA" -ForegroundColor Magenta
    Write-Host "  📦 Total liberado: $([math]::Round($totalFreed, 1)) MB ($([math]::Round($totalFreed / 1024, 2)) GB)" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
    $logFile = Join-Path $logPath "cleanup.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | LIMPIEZA | Liberados: $([math]::Round($totalFreed, 1)) MB" | Out-File -Append -FilePath $logFile

    return $totalFreed
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Clear-OptiMaxTempFiles
}
