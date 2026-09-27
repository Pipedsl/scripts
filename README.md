# 🖥️ OptiMax Pro — Servicio Profesional de Optimización Windows

<div align="center">

```
 ██████  ██████  ████████ ██ ███    ███  █████  ██
██    ██ ██   ██    ██    ██ ████  ████ ██   ██  ██
██    ██ ██████     ██    ██ ██ ████ ██ ███████   ██
██    ██ ██         ██    ██ ██  ██  ██ ██   ██  ██
 ██████  ██         ██    ██ ██      ██ ██   ██ ██
                     P R O
```

**Kit profesional de scripts PowerShell para optimización de rendimiento en Windows 10/11**

</div>

---

## 📋 ¿Qué es OptiMax Pro?

OptiMax Pro es una suite de scripts PowerShell modulares diseñada para **técnicos y profesionales de soporte** que ofrecen servicios de optimización de computadores Windows. No es una herramienta para usuarios finales — es tu **herramienta profesional interna** que te permite:

- Diagnosticar problemas de rendimiento en segundos
- Aplicar optimizaciones probadas y seguras
- Ofrecer dos perfiles: **Trabajo** y **Gaming**
- Revertir cualquier cambio con un solo clic
- Documentar todo con logs automáticos

## 🚀 Inicio Rápido

### Requisitos
- Windows 10 / 11
- PowerShell 5.1 o superior
- **Ejecutar como Administrador**

### Ejecución (recomendada) ⭐
Doble clic en **`Iniciar-OptiMax.bat`** (en la raíz del proyecto).
Pide permisos de Administrador, desbloquea los scripts descargados y abre el menú. No cambia la política de ejecución del sistema.

> Si aparece "Windows protegió su PC" → **Más información** → **Ejecutar de todas formas**.

### Ejecución manual desde PowerShell
1. Abrir **PowerShell como Administrador**
2. Navegar a la carpeta del proyecto:
   ```powershell
   cd "C:\ruta\a\scripts-main"
   ```
3. Desbloquear los archivos (necesario si se descargó el ZIP) y ejecutar:
   ```powershell
   Get-ChildItem -Recurse -Filter *.ps1 | Unblock-File
   powershell -ExecutionPolicy Bypass -File .\scripts\launcher\Start-Optimizer.ps1
   ```

> ⚠️ **Error "no está firmado digitalmente"**: pasa al descargar el ZIP de GitHub. Windows marca los archivos como "descargados de internet" y la política `RemoteSigned` los bloquea aunque la hayas activado. Se soluciona con `Unblock-File` (arriba) o usando `Iniciar-OptiMax.bat`.

## 🏗️ Estructura del Proyecto

```
ScriptparaRendimientoWindows/
├── Iniciar-OptiMax.bat                # 🖱️ Doble clic para ejecutar
├── scripts/
│   ├── launcher/
│   │   └── Start-Optimizer.ps1        # 🎯 PUNTO DE ENTRADA PRINCIPAL
│   ├── diagnostico/
│   │   └── Get-SystemReport.ps1       # Diagnóstico completo del PC
│   ├── trabajo/
│   │   ├── Optimize-WorkPC.ps1        # Orquestador perfil trabajo
│   │   ├── Clean-TempFiles.ps1        # Limpieza de temporales
│   │   ├── Disable-Bloatware.ps1      # Eliminar software basura
│   │   ├── Optimize-Services.ps1      # Optimizar servicios Windows
│   │   ├── Optimize-StartupApps.ps1   # Gestionar inicio
│   │   └── Set-VisualPerformance.ps1  # Ajustar efectos visuales
│   ├── gaming/
│   │   ├── Optimize-GamingPC.ps1      # Orquestador perfil gaming
│   │   ├── Set-GamingPriority.ps1     # Prioridad CPU/GPU
│   │   ├── Optimize-NetworkLatency.ps1# Reducir latencia de red
│   │   └── Disable-GameOverlays.ps1   # Desactivar overlays
│   └── comun/
│       ├── Backup-RestorePoint.ps1    # Punto de restauración
│       ├── Set-PowerPlan.ps1          # Plan de energía
│       └── Restore-Defaults.ps1       # Revertir todo
├── docs/                              # Documentación
├── logs/                              # Logs automáticos (generado)
├── FotosRendimiento/                  # Evidencia visual (no sube a Git)
├── designInspo/                       # Referencias de diseño
├── .gitignore
└── README.md
```

## 📦 Perfiles de Optimización

### 🏢 Perfil Trabajo
Ideal para PCs de oficina, puntos de venta y equipos de trabajo general.

| Módulo | Descripción |
|--------|-------------|
| Limpieza | Elimina temporales, caché de navegadores, papelera |
| Bloatware | Remueve McAfee, SDXHelper, apps preinstaladas |
| Servicios | Desactiva telemetría, SysMain, indexación |
| Inicio | Gestiona programas que arrancan con Windows |
| Visual | Reduce animaciones manteniendo usabilidad |
| Energía | Plan Alto Rendimiento |

### 🎮 Perfil Gaming
Optimización agresiva para máximo rendimiento en juegos.

| Módulo | Descripción |
|--------|-------------|
| Todo lo de Trabajo | + las optimizaciones base |
| CPU/GPU Priority | Win32PrioritySeparation, GPU Scheduling |
| Game DVR | Desactiva grabación en segundo plano |
| Overlays | Elimina Xbox Game Bar y overlays |
| Red | Nagle off, TCP optimizado, latencia mínima |
| Core Parking | Todos los núcleos activos |
| Energía | Ultimate Performance |

## 🛡️ Seguridad

- ✅ **Punto de restauración** automático antes de cada optimización
- ✅ **Reversible** — script `Restore-Defaults.ps1` revierte TODO
- ✅ **Logs** detallados de cada acción en `/logs/`
- ✅ **AnyDesk protegido** — nunca se toca la herramienta de acceso remoto
- ✅ **Sin modificaciones destructivas** — no elimina componentes del sistema

## 💰 Modelo de Servicio

Este kit está diseñado para ser usado como **herramienta profesional interna**, no como producto de venta directa.

**Precios de referencia del servicio:**
| Servicio | Precio Sugerido |
|----------|----------------|
| Diagnóstico + Optimización Básica | $15.000 - $25.000 CLP |
| Optimización Completa (Trabajo) | $25.000 - $35.000 CLP |
| Optimización Gaming | $30.000 - $45.000 CLP |
| Mantenimiento mensual por equipo | 0.8 - 1.2 UF/mes |

## ⚠️ Aviso Legal

- Estos scripts modifican configuraciones del sistema operativo
- Siempre crear punto de restauración antes de usar
- No nos hacemos responsables por mal uso o ejecución sin supervisión
- Diseñado para uso por técnicos profesionales

---

<div align="center">

**OptiMax Pro** — Hecho con 💜 para técnicos que quieren trabajar mejor

</div>
