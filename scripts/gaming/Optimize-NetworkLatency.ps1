<#
.SYNOPSIS
    OptiMax Pro — Optimización de Latencia de Red para Gaming
.DESCRIPTION
    Reduce la latencia de red desactivando Nagle's Algorithm,
    optimizando TCP/IP y configurando QoS para juegos.
.NOTES
    Autor: OptiMax Pro
    Requiere: Ejecutar como Administrador
#>

#Requires -RunAsAdministrator

function Optimize-OptiMaxNetworkLatency {
    [CmdletBinding()]
    param()

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   🌐 OPTIMAX PRO — Latencia de Red (Gaming)    ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""

    $changes = 0

    # ══════════════════════════════════════════
    # 1. DESHABILITAR NAGLE'S ALGORITHM
    # ══════════════════════════════════════════
    Write-Host "── Desactivando Nagle's Algorithm ─────────────────" -ForegroundColor Cyan
    Write-Host "  (Reduce la latencia enviando paquetes inmediatamente)" -ForegroundColor DarkGray
    Write-Host ""

    try {
        $netAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

        foreach ($adapter in $netAdapters) {
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($adapter.InterfaceGuid)"

            if (Test-Path $regPath) {
                # TcpAckFrequency = 1 → ACK inmediato
                Set-ItemProperty -Path $regPath -Name "TcpAckFrequency" -Value 1 -Type DWord
                # TCPNoDelay = 1 → Desactiva Nagle
                Set-ItemProperty -Path $regPath -Name "TCPNoDelay" -Value 1 -Type DWord

                Write-Host "[✓] $($adapter.Name): Nagle desactivado, ACK inmediato" -ForegroundColor Green
                $changes++
            }
        }
    }
    catch {
        Write-Host "[✗] Error al configurar Nagle: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ══════════════════════════════════════════
    # 2. OPTIMIZAR TCP/IP GLOBAL
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Optimización TCP/IP Global ─────────────────────" -ForegroundColor Cyan

    try {
        $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"

        # DefaultTTL - optimizar tiempo de vida de paquetes
        Set-ItemProperty -Path $tcpPath -Name "DefaultTTL" -Value 64 -Type DWord
        Write-Host "[✓] DefaultTTL establecido a 64" -ForegroundColor Green
        $changes++

        # Desactivar TCP timestamps (reduce overhead)
        Set-ItemProperty -Path $tcpPath -Name "Tcp1323Opts" -Value 1 -Type DWord
        Write-Host "[✓] TCP Timestamps optimizado (Window Scaling ON, Timestamps OFF)" -ForegroundColor Green
        $changes++

        # MaxUserPort - más puertos disponibles
        Set-ItemProperty -Path $tcpPath -Name "MaxUserPort" -Value 65534 -Type DWord
        Write-Host "[✓] Max User Port: 65534" -ForegroundColor Green
        $changes++

        # Reducir TcpTimedWaitDelay
        Set-ItemProperty -Path $tcpPath -Name "TcpTimedWaitDelay" -Value 30 -Type DWord
        Write-Host "[✓] TCP Timed Wait Delay: 30s (default 240s)" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[✗] Error en TCP/IP: $($_.Exception.Message)" -ForegroundColor Red
    }

    # ══════════════════════════════════════════
    # 3. DESACTIVAR AUTO-TUNING DE RED
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Auto-Tuning de Red ─────────────────────────────" -ForegroundColor Cyan

    try {
        # Desactivar auto-tuning puede ayudar con routers viejos
        netsh int tcp set global autotuninglevel=normal 2>$null
        Write-Host "[✓] TCP Auto-Tuning: Normal (compatible con todos los routers)" -ForegroundColor Green
        $changes++

        # ECN Capability
        netsh int tcp set global ecncapability=disabled 2>$null
        Write-Host "[✓] ECN desactivado (mejor compatibilidad)" -ForegroundColor Green
        $changes++

        # RSS (Receive Side Scaling) - mantener habilitado si hay múltiples cores
        netsh int tcp set global rss=enabled 2>$null
        Write-Host "[✓] RSS habilitado (distribuye tráfico entre cores)" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[!] Algunos ajustes de red no pudieron aplicarse" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # 4. OPTIMIZAR DNS
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Optimización DNS ───────────────────────────────" -ForegroundColor Cyan

    try {
        # Limpiar caché DNS
        Clear-DnsClientCache
        Write-Host "[✓] Caché DNS limpiado" -ForegroundColor Green

        # Configurar DNS más rápidos (Cloudflare)
        Write-Host ""
        Write-Host "  ¿Configurar DNS de Cloudflare (1.1.1.1) para menor latencia? (S/N): " -ForegroundColor Yellow -NoNewline
        $dnsConfirm = Read-Host

        if ($dnsConfirm -eq 'S' -or $dnsConfirm -eq 's') {
            $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
            foreach ($adapter in $activeAdapters) {
                Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("1.1.1.1", "1.0.0.1")
                Write-Host "[✓] DNS de $($adapter.Name) → 1.1.1.1 / 1.0.0.1 (Cloudflare)" -ForegroundColor Green
                $changes++
            }
        }
        else {
            Write-Host "[→] DNS no modificado" -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host "[!] Error al configurar DNS" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # 5. NETWORK THROTTLING INDEX
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Network Throttling ─────────────────────────────" -ForegroundColor Cyan

    try {
        $mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Set-ItemProperty -Path $mmcssPath -Name "NetworkThrottlingIndex" -Value 4294967295 -Type DWord
        Write-Host "[✓] Network Throttling desactivado (máximo throughput)" -ForegroundColor Green
        $changes++
    }
    catch {
        Write-Host "[!] No se pudo desactivar network throttling" -ForegroundColor Yellow
    }

    # ══════════════════════════════════════════
    # TEST DE LATENCIA
    # ══════════════════════════════════════════
    Write-Host ""
    Write-Host "── Test de Latencia ───────────────────────────────" -ForegroundColor Cyan

    try {
        $targets = @(
            @{ Name = "Cloudflare DNS"; IP = "1.1.1.1" },
            @{ Name = "Google DNS"; IP = "8.8.8.8" },
            @{ Name = "Chile IX"; IP = "200.1.123.46" }
        )

        Write-Host ""
        Write-Host "    {0,-20} {1,10} {2,10} {3,10}" -f "DESTINO", "MIN", "AVG", "MAX" -ForegroundColor DarkGray
        Write-Host "    $("-" * 52)" -ForegroundColor DarkGray

        foreach ($target in $targets) {
            $ping = Test-Connection -ComputerName $target.IP -Count 4 -ErrorAction SilentlyContinue
            if ($ping) {
                $min = ($ping | Measure-Object -Property Latency -Minimum).Minimum
                $avg = [math]::Round(($ping | Measure-Object -Property Latency -Average).Average, 1)
                $max = ($ping | Measure-Object -Property Latency -Maximum).Maximum

                $color = if ($avg -lt 20) { "Green" } elseif ($avg -lt 50) { "Yellow" } else { "Red" }
                Write-Host ("    {0,-20} {1,10} {2,10} {3,10}" -f $target.Name, "${min}ms", "${avg}ms", "${max}ms") -ForegroundColor $color
            }
            else {
                Write-Host ("    {0,-20} {1,>10}" -f $target.Name, "TIMEOUT") -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "[!] No se pudo realizar test de latencia" -ForegroundColor Yellow
    }

    # ── Resumen ──
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  OPTIMIZACIÓN DE RED COMPLETADA" -ForegroundColor Magenta
    Write-Host "  ✓ $changes optimizaciones aplicadas" -ForegroundColor White
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    # Log
    $logPath = Join-Path $PSScriptRoot "..\..\logs"
    if (-not (Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath -Force | Out-Null }
    $logFile = Join-Path $logPath "network-latency.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    "$timestamp | NETWORK LATENCY | Cambios: $changes" | Out-File -Append -FilePath $logFile
}

# Ejecutar si se llama directamente
if ($MyInvocation.InvocationName -ne '.') {
    Optimize-OptiMaxNetworkLatency
}
