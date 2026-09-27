<#
.SYNOPSIS
    OptiMax Pro — Configurar Plan de Energía
.DESCRIPTION
    Configura el plan de energía según el perfil seleccionado:
    - Trabajo: Alto Rendimiento
    - Gaming: Ultimate Performance
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Set-OptiMaxPowerPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Trabajo", "Gaming")]
        [string]$Perfil
    )

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   ⚡ OPTIMAX PRO — Plan de Energía              ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    # GUIDs de planes de energía estándar de Windows
    $plans = @{
        "Balanced"           = "381b4222-f694-41f0-9685-ff5bb260df2e"
        "HighPerformance"    = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        "UltimatePerformance" = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    }

    try {
        if ($Perfil -eq "Trabajo") {
            Write-Host "[→] Configurando plan: Alto Rendimiento..." -ForegroundColor Cyan

            # Activar plan de Alto Rendimiento
            powercfg /setactive $plans["HighPerformance"]

            # Configurar tiempos de suspensión razonables para trabajo
            # Apagar pantalla después de 15 minutos (AC) / 10 minutos (DC)
            powercfg /change monitor-timeout-ac 15
            powercfg /change monitor-timeout-dc 10

            # Suspender después de 30 minutos (AC) / 20 minutos (DC)
            powercfg /change standby-timeout-ac 30
            powercfg /change standby-timeout-dc 20

            # Desactivar hibernación (libera espacio en disco)
            powercfg /hibernate off

            Write-Host "[✓] Plan 'Alto Rendimiento' activado" -ForegroundColor Green
            Write-Host "    Monitor se apaga: 15 min (AC) / 10 min (batería)" -ForegroundColor DarkGray
            Write-Host "    Suspensión: 30 min (AC) / 20 min (batería)" -ForegroundColor DarkGray
            Write-Host "    Hibernación: Desactivada (libera espacio en disco)" -ForegroundColor DarkGray
        }
        elseif ($Perfil -eq "Gaming") {
            Write-Host "[→] Verificando disponibilidad de Ultimate Performance..." -ForegroundColor Cyan

            # Intentar activar Ultimate Performance (puede no estar disponible en todos los Windows)
            $ultimateExists = powercfg /list | Select-String "Ultimate"

            if (-not $ultimateExists) {
                Write-Host "[→] Ultimate Performance no encontrado. Creándolo..." -ForegroundColor Yellow
                powercfg /duplicatescheme $plans["UltimatePerformance"] 2>$null

                if ($LASTEXITCODE -ne 0) {
                    # Si no se puede duplicar, usar Alto Rendimiento como fallback
                    Write-Host "[!] No se pudo crear Ultimate Performance. Usando Alto Rendimiento." -ForegroundColor Yellow
                    powercfg /setactive $plans["HighPerformance"]
                }
                else {
                    powercfg /setactive $plans["UltimatePerformance"]
                }
            }
            else {
                powercfg /setactive $plans["UltimatePerformance"]
            }

            # Configurar para máximo rendimiento gaming
            # Nunca apagar pantalla ni suspender mientras se juega
            powercfg /change monitor-timeout-ac 0
            powercfg /change standby-timeout-ac 0
            powercfg /change hibernate-timeout-ac 0

            # Desactivar hibernación
            powercfg /hibernate off

            # Desactivar USB selective suspend (evita desconexiones de periféricos)
            powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
            powercfg /setactive SCHEME_CURRENT

            Write-Host "[✓] Plan 'Ultimate Performance / Gaming' activado" -ForegroundColor Green
            Write-Host "    Monitor: Nunca se apaga" -ForegroundColor DarkGray
            Write-Host "    Suspensión: Desactivada" -ForegroundColor DarkGray
            Write-Host "    USB Selective Suspend: Desactivado" -ForegroundColor DarkGray
            Write-Host "    Hibernación: Desactivada" -ForegroundColor DarkGray
        }

        # Mostrar plan activo actual
        Write-Host ""
        Write-Host "── Plan de energía activo ──────────────────────" -ForegroundColor DarkGray
        $activePlan = powercfg /getactivescheme
        Write-Host "    $activePlan" -ForegroundColor White
        Write-Host ""

        return $true
    }
    catch {
        Write-Host "[✗] Error al configurar plan de energía: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "Selecciona el perfil:" -ForegroundColor Cyan
    Write-Host "  1. Trabajo (Alto Rendimiento)" -ForegroundColor White
    Write-Host "  2. Gaming (Ultimate Performance)" -ForegroundColor White
    Write-Host ""
    $option = Read-Host "Opción (1/2)"

    switch ($option) {
        "1" { $null = Set-OptiMaxPowerPlan -Perfil "Trabajo" }
        "2" { $null = Set-OptiMaxPowerPlan -Perfil "Gaming" }
        default { Write-Host "[✗] Opción no válida." -ForegroundColor Red }
    }
}
