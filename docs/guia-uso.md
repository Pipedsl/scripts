# 📖 Guía Completa de Uso — OptiMax Pro

## Tabla de Contenidos

1. [¿Qué es OptiMax Pro?](#qué-es-optimax-pro)
2. [Instalación en el PC del Cliente](#instalación-en-el-pc-del-cliente)
3. [Cómo Funciona el Launcher (Menú Principal)](#cómo-funciona-el-launcher)
4. [Flujo de Trabajo Paso a Paso](#flujo-de-trabajo-paso-a-paso)
5. [Sistema de Backups y Restauración (IMPORTANTE)](#sistema-de-backups-y-restauración)
6. [Cada Módulo Explicado](#cada-módulo-explicado)
7. [Uso Remoto vía AnyDesk](#uso-remoto-vía-anydesk)
8. [Sistema de Logs](#sistema-de-logs)
9. [Solución de Problemas](#solución-de-problemas)
10. [Respuestas para el Cliente](#respuestas-para-el-cliente)
11. [Checklists](#checklists)

---

## ¿Qué es OptiMax Pro?

OptiMax Pro es tu **caja de herramientas profesional** para arreglar PCs lentos. Piensa en esto como el kit de un mecánico: tiene diferentes herramientas para diferentes problemas, y tú decides cuáles usar según lo que necesite cada equipo.

**No es un programa que instalas** — son scripts de PowerShell que ejecutas desde la terminal. Esto tiene ventajas:
- No deja software instalado en el PC del cliente
- Se puede ejecutar remotamente vía AnyDesk
- Puedes elegir qué módulos usar según cada caso
- Todo queda documentado en logs

---

## Instalación en el PC del Cliente

Hay **3 formas** de llevar OptiMax Pro al PC del cliente:

### Opción 1: Desde GitHub (La más cómoda) ⭐
Si el PC tiene internet y Git instalado:
```powershell
# Abrir PowerShell como Administrador
cd C:\
git clone https://github.com/Pipedsl/scripts.git OptiMaxPro
cd C:\OptiMaxPro\scripts\launcher
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\Start-Optimizer.ps1
```

### Opción 2: Descargar ZIP desde GitHub (Sin Git)
1. Ir a `https://github.com/Pipedsl/scripts`
2. Clic en el botón verde **Code** → **Download ZIP**
3. Descomprimir en `C:\OptiMaxPro\`
4. Abrir PowerShell Admin y navegar a la carpeta

### Opción 3: Copiar vía AnyDesk o USB
1. Copiar toda la carpeta `scripts/` al PC del cliente
2. Pegarla en `C:\OptiMaxPro\` (o donde prefieras)

### Después de copiar (SIEMPRE)
La forma más fácil: **doble clic en `Iniciar-OptiMax.bat`** (raíz del proyecto). Se encarga de todo: pide Administrador, desbloquea los scripts y abre el menú.

Si prefieres hacerlo a mano desde PowerShell (Administrador), en la carpeta del proyecto:

```powershell
# 1. Quitar la marca "descargado de internet" a los scripts
Get-ChildItem -Recurse -Filter *.ps1 | Unblock-File

# 2. Ejecutar el launcher permitiendo scripts solo en esta ejecución
powershell -ExecutionPolicy Bypass -File .\scripts\launcher\Start-Optimizer.ps1
```

**¿Por qué no basta con `Set-ExecutionPolicy RemoteSigned`?** `RemoteSigned` permite scripts locales, pero exige firma digital a los que vienen de internet. Los archivos de un ZIP descargado de GitHub quedan marcados como "de internet", así que siguen bloqueados con el error *"no está firmado digitalmente"*. `Unblock-File` quita esa marca.

---

## Cómo Funciona el Launcher

Al ejecutar `Start-Optimizer.ps1` verás un menú con 14 opciones:

```
┌─────────────────────────────────────────────────────────┐
│                    MENU PRINCIPAL                       │
├─────────────────────────────────────────────────────────┤
│   1.  📋  Diagnóstico Completo del Sistema             │  ← Siempre empieza aquí
│                                                        │
│   ── PERFILES DE OPTIMIZACIÓN ─────────────────────    │
│   2.  🏢  Optimización TRABAJO (completa)              │  ← Ejecuta todo automático
│   3.  🎮  Optimización GAMING (completa)               │  ← Ejecuta todo automático
│                                                        │
│   ── MÓDULOS INDIVIDUALES ─────────────────────────    │
│   4.  🧹  Limpieza de Archivos Temporales             │
│   5.  🗑️  Eliminar Bloatware                          │
│   6.  ⚙️  Optimizar Servicios del Sistema             │  ← Puedes ejecutar
│   7.  🚀  Gestionar Programas de Inicio               │     cada módulo por
│   8.  🎨  Optimización Visual                          │     separado si quieres
│   9.  ⚡  Configurar Plan de Energía                   │     más control
│  10.  🎯  Prioridad CPU/GPU (Gaming)                   │
│  11.  🌐  Optimizar Latencia de Red                    │
│  12.  🎬  Desactivar Overlays de Juegos               │
│                                                        │
│   ── SEGURIDAD ────────────────────────────────────    │
│  13.  💾  Crear Punto de Restauración                  │  ← Backup manual
│  14.  🔄  Restaurar Configuración Original             │  ← Deshacer TODO
│                                                        │
│   0.  ❌  Salir                                        │
└─────────────────────────────────────────────────────────┘
```

### ¿Qué opción elijo?

| Situación | Opción |
|-----------|--------|
| Primera vez en un PC → | **1** (Diagnóstico) para ver qué tiene |
| PC de oficina / punto de venta → | **2** (Trabajo completa) |
| PC gamer lento → | **3** (Gaming completa) |
| Solo quieres limpiar basura → | **4** (Temporales) |
| Solo quitar McAfee → | **5** (Bloatware) |
| Algo salió mal → | **14** (Restaurar todo) |

---

## Flujo de Trabajo Paso a Paso

### Caso Real: El PC del vendedor de Melipilla

```
PASO 1 → Te conectas vía AnyDesk desde Santiago
         Abres PowerShell como Administrador en su PC

PASO 2 → Descargas OptiMax Pro (git clone o ZIP)
         Ejecutas .\Start-Optimizer.ps1

PASO 3 → Seleccionas opción 1 (Diagnóstico)
         ┌──────────────────────────────────────┐
         │ El script analiza todo el PC:         │
         │ - CPU: 7% ✅ bien                    │
         │ - RAM: 89% 🔴 PROBLEMA               │
         │ - McAfee detectado 🔴                 │
         │ - SDXHelper consumiendo disco 🔴      │
         │                                       │
         │ RECOMENDACIÓN: Perfil Trabajo          │
         └──────────────────────────────────────┘
         
PASO 4 → Seleccionas opción 2 (Optimización Trabajo)
         ┌──────────────────────────────────────┐
         │ ¿Iniciar? (S/N) → S                  │
         │                                       │
         │ [████░░░░░░] 14% — Creando backup...  │  ← Primero backup automático
         │ [████████░░] 28% — Limpiando temp...  │
         │ [████████░░] 42% — Eliminando McAfee..│
         │ [██████████] 57% — Servicios...       │
         │ ... hasta completar 7 pasos            │
         │                                       │
         │ ✅ COMPLETADO                          │
         │ Disco liberado: ~450 MB                │
         │ RAM estimada libre: ~180 MB            │
         └──────────────────────────────────────┘

PASO 5 → Le pides al vendedor que reinicie el PC
         (o lo reinicias tú vía AnyDesk)

PASO 6 → Te reconectas y verificas en el Monitor de Recursos
         que la RAM bajó y el disco ya no está saturado
```

---

## Sistema de Backups y Restauración

### ¿Qué es un "Punto de Restauración"?

Imagina que el PC es un videojuego. Un **punto de restauración** es como un **"save game"** — es una foto del estado actual del sistema que Windows guarda internamente. Si algo sale mal después, puedes "cargar el save" y el PC vuelve exactamente a como estaba antes.

### ¿Qué guarda un punto de restauración?

| ✅ SÍ guarda | ❌ NO guarda |
|--------------|-------------|
| Configuración del sistema | Documentos del usuario |
| Programas instalados | Fotos, videos, música |
| Drivers | Archivos del escritorio |
| Registro de Windows | Correos, navegadores |
| Servicios del sistema | Contraseñas |

**Traducción**: Si restauras un punto de restauración, el **sistema** vuelve a como estaba, pero los **archivos personales** del usuario (documentos, fotos, etc.) **NO se tocan**. No se pierden ni se modifican.

### ¿Cuándo se crea un backup?

OptiMax Pro crea un punto de restauración **automáticamente** en dos situaciones:

1. **Cuando ejecutas una optimización completa** (opción 2 o 3): Es el primer paso que hace el orquestador. No necesitas hacer nada.
2. **Cuando lo creas manualmente** (opción 13): Si quieres crear uno extra antes de hacer algo por tu cuenta.

```
Ejemplo de lo que ves en pantalla:

╔══════════════════════════════════════════════════╗
║   💾 OPTIMAX PRO — Punto de Restauración        ║
╚══════════════════════════════════════════════════╝

[→] Verificando protección del sistema...
[→] Creando punto de restauración...
[✓] Punto de restauración creado exitosamente
    Descripción: OptiMax Pro - Perfil Trabajo [2026-09-03 10:30]
```

### ¿Cómo restauro un backup si algo sale mal?

Tienes **2 formas** de volver atrás:

#### Forma 1: Desde OptiMax Pro (Recomendada)
Ejecuta la opción **14** del menú ("Restaurar Configuración Original"). Esto revierte **específicamente** los cambios que hizo OptiMax Pro:
- Reactiva los servicios que desactivó
- Restaura los efectos visuales
- Vuelve al plan de energía "Equilibrado"
- Reactiva Game DVR y overlays
- Restaura la configuración de red

```powershell
# O directamente sin el launcher:
cd scripts\comun
.\Restore-Defaults.ps1
```

#### Forma 2: Desde Windows (El "save game")
Si la opción 14 no funciona o el PC tiene un problema más grave, puedes restaurar el punto de restauración completo desde Windows:

1. Buscar **"Crear un punto de restauración"** en el menú Inicio
2. Clic en **"Restaurar sistema..."**
3. Seleccionar el punto que dice **"OptiMax Pro - ..."**
4. Seguir el asistente → El PC se reiniciará solo
5. Cuando vuelva a encender, todo estará como antes

```
⚠️ IMPORTANTE:
La restauración de Windows puede tardar 10-20 minutos.
El PC se reinicia solo durante el proceso.
NO apagues el PC mientras restaura.
```

### ¿Qué pasa si no se puede crear el punto de restauración?

A veces Windows tiene la protección del sistema desactivada (especialmente en PCs baratos que vienen con poco disco). Si eso pasa, el script te preguntará:

```
[✗] Error al crear punto de restauración
[!] ¿Deseas continuar sin punto de restauración? (S/N):
```

**Mi recomendación**: Si es la primera vez que optimizas ese PC, escribe **N** (No) y habilita la protección manualmente:

1. Buscar "Crear un punto de restauración" en el menú Inicio
2. Seleccionar la unidad C: → clic en **"Configurar..."**
3. Marcar **"Activar protección del sistema"**
4. Asignar al menos **2-5 GB** de espacio
5. Clic en Aceptar
6. Volver a intentar la optimización

Si ya conoces el equipo y confías en que no habrá problemas, puedes escribir **S** y continuar sin backup.

---

## Cada Módulo Explicado

### 📋 Módulo 1: Diagnóstico (`Get-SystemReport.ps1`)

**¿Qué hace?** Analiza TODO el PC y te genera un reporte visual con colores en la terminal.

**¿Qué analiza?**
- Info del sistema (marca, modelo, Windows, tiempo encendido)
- CPU (modelo, núcleos, uso actual)
- RAM (total, usada, % uso, módulos instalados, slots vacíos)
- Discos (HDD vs SSD, espacio libre, particiones)
- GPU (modelo, VRAM, driver)
- Top 10 procesos que más RAM consumen
- Programas de inicio
- Servicios innecesarios activos
- Bloatware detectado (McAfee, Candy Crush, etc.)
- Temperatura del sistema
- Conectividad de red
- **Recomendaciones automáticas** (ej: "ampliar RAM", "cambiar a SSD")

**¿Modifica algo?** NO. Solo lee y muestra información. Es 100% seguro.

**¿Cuándo usarlo?**
- Siempre como primer paso en un PC nuevo
- Para mostrarle al cliente qué problemas tiene su equipo
- Para tener evidencia del "antes" (tomar captura de pantalla)

---

### 🧹 Módulo 4: Limpieza de Temporales (`Clean-TempFiles.ps1`)

**¿Qué hace?** Borra archivos basura que Windows y los programas van acumulando.

**¿Qué limpia exactamente?**

| Carpeta | Qué contiene | ¿Es seguro borrar? |
|---------|-------------|---------------------|
| `%TEMP%` (carpeta temp del usuario) | Archivos temporales de programas | ✅ Sí, 100% seguro |
| `C:\Windows\Temp` | Archivos temporales del sistema | ✅ Sí (los que estén en uso se saltan solos) |
| `C:\Windows\Prefetch` | Caché de inicio rápido de apps | ✅ Sí, Windows la reconstruye sola |
| Caché de Windows Update | Updates ya instalados | ✅ Sí, libera mucho espacio |
| Caché de Chrome | Imágenes/datos cacheados | ✅ Sí, no borra contraseñas ni favoritos |
| Caché de Edge | Igual que Chrome | ✅ Sí |
| Caché de Firefox | Igual | ✅ Sí |
| Papelera de reciclaje | Archivos "eliminados" | ⚠️ Verificar con el cliente primero |
| Thumbnails (miniaturas) | Caché de previsualizaciones | ✅ Sí, se regenera sola |
| Minidumps y LiveKernelReports | Reportes de errores/pantallazos azules | ✅ Sí |

**¿Borra archivos del usuario (documentos, fotos)?** NUNCA. Solo toca archivos temporales del sistema.

**Resultado típico:** Libera entre 200 MB y 5 GB dependiendo de cuánto tiempo lleva sin limpiarse.

---

### 🗑️ Módulo 5: Eliminar Bloatware (`Disable-Bloatware.ps1`)

**¿Qué es "bloatware"?** Son programas que vienen preinstalados en el PC y que nadie pidió. Consumen RAM, CPU y disco sin dar valor.

**¿Qué elimina?**

| Programa | Por qué se elimina |
|----------|-------------------|
| **McAfee** (todos los componentes) | Antivirus innecesario, Windows Defender ya protege |
| **SDXHelper.exe** | Actualizador de Office que consume +1 MB/s de disco |
| Candy Crush, Solitario | Juegos preinstalados |
| Spotify, TikTok, Disney+ | Apps de entretenimiento preinstaladas |
| Facebook, Instagram | Redes sociales preinstaladas |
| Xbox Game Bar y servicios | Overlays innecesarios |
| Bing News, Weather, Maps | Apps de Microsoft que nadie usa |
| Clipchamp | Editor de video preinstalado |

**¿Qué NUNCA toca? (Apps Protegidas)**

| App protegida | Razón |
|--------------|-------|
| **AnyDesk** | 🔒 Tu herramienta de trabajo remoto |
| Calculadora | Útil en punto de venta |
| Fotos | Para ver imágenes |
| Microsoft Store | Necesaria para actualizaciones |
| Paint, Notepad | Herramientas básicas |
| Windows Terminal | Necesaria para los scripts |
| Herramienta de Recortes | Para capturas |

**¿Qué pasa si elimino McAfee?** Windows Defender se queda como antivirus principal. Es más liviano y viene incluido gratis con Windows. **Es mejor** que McAfee para PCs con poca RAM.

**Extra:** El script también bloquea que Windows reinstale automáticamente apps de bloatware en el futuro.

---

### ⚙️ Módulo 6: Optimizar Servicios (`Optimize-Services.ps1`)

**¿Qué es un "servicio"?** Son programas invisibles que corren en segundo plano desde que enciendes el PC. Algunos son esenciales (como el de red o audio), pero otros solo consumen recursos sin dar valor.

**¿Qué servicios desactiva?**

| Servicio | Qué hace | RAM que consume | Por qué desactivarlo |
|----------|----------|----------------|---------------------|
| DiagTrack | Envía datos de uso a Microsoft | ~15 MB | Privacidad + rendimiento |
| SysMain (Superfetch) | Pre-carga apps en RAM | ~50 MB | Malo con 8 GB de RAM (compite por memoria) |
| Windows Search | Indexa todos los archivos | ~30 MB | Consume disco constantemente |
| dmwappushservice | Auxiliar de telemetría | ~5 MB | Innecesario |
| Geolocalización | GPS del PC | ~5 MB | Un PC de escritorio no necesita GPS |
| Remote Registry | Permite editar registro remotamente | ~3 MB | Riesgo de seguridad |
| Windows Media Player Network | Streaming de WMP | ~5 MB | Nadie usa WMP |
| Retail Demo | Modo demostración de tienda | ~2 MB | No es una tienda de PCs |
| Windows Insider | Para beta testers | ~3 MB | No estamos probando betas |
| Fax | Enviar fax | ~2 MB | 😄 |

**Servicios extra que desactiva en modo Gaming:**

| Servicio | RAM | Razón |
|----------|-----|-------|
| Xbox Live Auth | ~8 MB | Solo para juegos Xbox Live |
| Xbox Game Save | ~5 MB | Guardado en nube Xbox |
| Xbox Networking | ~8 MB | Red de Xbox |

**Además**, modifica el **registro de Windows** para:
- Reducir telemetría al mínimo
- Desactivar el ID de publicidad (deja de rastrear)
- Desactivar feedback automático a Microsoft

**RAM estimada total recuperable:** ~100-180 MB

**¿Es reversible?** SÍ. La opción 14 del menú reactiva todos estos servicios.

---

### 🚀 Módulo 7: Programas de Inicio (`Optimize-StartupApps.ps1`)

**¿Qué son "programas de inicio"?** Son apps que se abren solas cuando enciendes el PC. Cuantas más tengas, más tarda en arrancar y más RAM consume desde el primer momento.

**¿Qué hace el script?**
1. **Escanea** 3 fuentes: Registro de Windows, carpeta Startup, y Tareas Programadas
2. **Clasifica** cada programa:
   - 🟢 **ESENCIAL** (no tocar): Windows Security, AnyDesk, drivers de audio/GPU
   - 🔴 **RECOMENDADO DESACTIVAR**: OneDrive, Skype, Spotify, Steam, Adobe, Chrome
   - 🟡 **REVISAR MANUALMENTE**: Programas que no reconoce
3. **Crea un backup** (archivo JSON) de la configuración actual
4. **Te pregunta** si quieres desactivar los recomendados

**El backup se guarda en:** `logs/startup-backup-FECHA.json`

**¿Si me equivoco y desactivé algo importante?** El backup JSON tiene toda la info para reactivarlo manualmente.

---

### 🎨 Módulo 8: Rendimiento Visual (`Set-VisualPerformance.ps1`)

**¿Qué hace?** Reduce las animaciones y efectos visuales de Windows para que el PC responda más rápido.

Tiene **3 niveles**:

| Perfil | Qué desactiva | Qué mantiene | Para quién |
|--------|--------------|-------------|-----------|
| **Trabajo** | Animaciones taskbar, transparencia, Aero Peek, sombras | ClearType (fuentes legibles), vista previa de iconos | PCs de oficina |
| **Gaming** | Todo lo de Trabajo + efectos de sombra extra | ClearType | PCs gamer |
| **Mínimo** | TODO: animaciones, transparencia, sombras, preview | Nada visual | PCs muy viejos/lentos |

**¿Qué es ClearType?** Es la tecnología que hace que las letras se vean suaves y legibles en la pantalla. Siempre lo mantenemos porque sin él las fuentes se ven pixeladas y feas.

**¿El PC se va a ver "feo"?** El perfil Trabajo apenas se nota — el PC se siente más rápido pero visualmente casi no cambia. El perfil Mínimo sí se nota (parece Windows XP), pero es para PCs que realmente lo necesitan.

---

### ⚡ Módulo 9: Plan de Energía (`Set-PowerPlan.ps1`)

**¿Qué es un plan de energía?** Es la configuración que le dice a Windows cuánta energía usar. Por defecto viene en "Equilibrado" que ahorra energía pero reduce rendimiento.

| Plan | Descripción | Cuándo usar |
|------|------------|-------------|
| **Equilibrado** (default) | Baja velocidad de CPU cuando no se usa | PCs portátiles con batería |
| **Alto Rendimiento** | CPU siempre al máximo disponible | PCs de escritorio / trabajo |
| **Ultimate Performance** | Todo al máximo, sin ahorro energético | Gaming, edición de video |

**Para el PC del vendedor:** Alto Rendimiento es lo correcto. Es un PC de escritorio conectado a la corriente, no necesita ahorrar batería.

**Configuraciones adicionales del perfil Trabajo:**
- Pantalla se apaga después de 15 minutos
- PC se suspende después de 30 minutos
- Hibernación desactivada (libera espacio en disco igual al tamaño de la RAM)

**Configuraciones del perfil Gaming:**
- Pantalla NUNCA se apaga (evita que se apague durante una partida)
- PC NUNCA se suspende
- USB Selective Suspend desactivado (evita que se desconecten teclado/mouse)

---

### 🎯 Módulo 10: Prioridad CPU/GPU Gaming (`Set-GamingPriority.ps1`)

**Solo para perfil Gaming.** Ajusta configuraciones internas de Windows para que los juegos reciban la máxima atención del procesador y la GPU.

**Cambios principales:**
- **Win32PrioritySeparation → 26**: Le dice a Windows "dale TODA la prioridad al programa que está en primer plano (el juego)"
- **GPU Scheduling**: El GPU maneja su propia cola de trabajo en vez de depender del CPU
- **Core Parking OFF**: Todos los núcleos del CPU siempre disponibles (Windows por defecto "duerme" algunos para ahorrar energía)
- **MMCSS Gaming Profile**: Prioridad máxima para multimedia (GPU 8, CPU 6, I/O Alto)
- **Kernel en RAM**: El kernel de Windows no se pagina a disco (más rápido, usa un poco más de RAM)

---

### 🌐 Módulo 11: Latencia de Red (`Optimize-NetworkLatency.ps1`)

**Solo para gaming.** Reduce el tiempo que tardan los datos en viajar entre el PC y el servidor del juego.

**Cambios:**
- **Nagle's Algorithm OFF**: Windows por defecto junta varios paquetes chicos y los envía juntos. Para gaming esto agrega latencia. Lo desactivamos para envío inmediato.
- **TCP Optimizado**: Más puertos disponibles, menos tiempo de espera
- **DNS Cloudflare** (opcional): Te pregunta si quieres cambiar el DNS a 1.1.1.1 (más rápido que el del ISP)
- **Test de latencia**: Al final hace ping a 3 servidores y muestra tu latencia

---

### 🎬 Módulo 12: Overlays de Juegos (`Disable-GameOverlays.ps1`)

**¿Qué es un overlay?** Es una capa visual que se superpone sobre el juego. Ejemplo: la barra de Xbox que aparece con Win+G.

**¿Por qué desactivarlos?** Cada overlay consume FPS (cuadros por segundo). En PCs con pocos recursos, puede significar la diferencia entre jugar fluido o con lag.

**¿Qué desactiva?**
- Game DVR (grabación automática de clips — consume CPU y disco)
- Xbox Game Bar (overlay con Win+G)
- Servicios Xbox (Auth, Game Save, Networking, Accessories)
- Sugerencias de Windows durante juegos
- Fullscreen Optimizations (fuerza pantalla completa real, mejor rendimiento)

---

## Uso Remoto vía AnyDesk

### Flujo para conectarte desde Santiago al PC de Melipilla

```
TU MAC (Santiago)                    PC DEL VENDEDOR (Melipilla)
     │                                        │
     │  1. Abres AnyDesk en tu Mac            │
     │──────────────────────────────────────►  │
     │                                        │
     │  2. Ingresas el ID del PC del vendedor │
     │  3. El vendedor acepta la conexión     │
     │                                        │
     │  4. Ahora ves su escritorio            │
     │                                        │
     │  5. Clic derecho en Inicio →           │
     │     "Windows PowerShell (Admin)"       │
     │                                        │
     │  6. Ejecutas los comandos de           │
     │     instalación y el launcher          │
     │                                        │
     │  IMPORTANTE: Los scripts se ejecutan   │
     │  en el PC DEL VENDEDOR, no en tu Mac.  │
     │  AnyDesk solo muestra la pantalla.     │
     └────────────────────────────────────────┘
```

### Tips para conexión remota lenta

Si la conexión AnyDesk está lenta (Melipilla puede tener internet inestable):

1. **Usa módulos individuales** en vez del orquestador completo. Así si se corta la conexión, solo pierdes el módulo actual, no toda la optimización.
2. **Baja la calidad visual de AnyDesk**: En AnyDesk → Display → Quality → "Speed"
3. **No ejecutes diagnóstico visual**: Los gráficos del reporte consumen ancho de banda de AnyDesk. Mejor guarda el log y revísalo después.
4. **Agenda horarios fuera de pico**: Entre las 8-10 AM o después de las 8 PM la red suele estar mejor.

### ¿Qué pasa si se corta la conexión durante una optimización?

**No pasa nada grave.** Los scripts modifican configuraciones del sistema que se aplican inmediatamente. Si se corta:
- Lo que ya se hizo, queda hecho
- Lo que no alcanzó a hacer, no se hizo
- Puedes reconectarte y continuar donde quedaste
- El punto de restauración ya se creó al inicio

---

## Sistema de Logs

Cada vez que ejecutas un módulo, se guarda un registro en la carpeta `logs/` (se crea automáticamente).

### Archivos de log generados

| Archivo | Qué contiene |
|---------|-------------|
| `restore-points.log` | Fecha y descripción de cada punto de restauración creado |
| `cleanup.log` | MB liberados en cada limpieza |
| `bloatware.log` | Programas removidos y errores |
| `services.log` | Servicios optimizados y RAM estimada liberada |
| `visual.log` | Cambios visuales aplicados |
| `startup-backup-FECHA.json` | Backup completo de programas de inicio |
| `diagnostico-FECHA.log` | Reporte de diagnóstico en texto plano |
| `optimize-work.log` | Resumen de optimización trabajo completa |
| `optimize-gaming.log` | Resumen de optimización gaming completa |
| `gaming-priority.log` | Cambios de prioridad CPU/GPU |
| `network-latency.log` | Optimizaciones de red aplicadas |
| `game-overlays.log` | Overlays desactivados |
| `restore-defaults.log` | Restauraciones realizadas |

### ¿Para qué sirven los logs?

1. **Evidencia para el cliente**: Puedes mostrar exactamente qué se hizo
2. **Comparar antes/después**: Cuánta RAM se liberó, cuánto disco se limpió
3. **Debugging**: Si algo falla, los logs muestran qué pasó
4. **Historial**: Saber cuándo fue la última optimización de cada equipo

---

## Solución de Problemas

### "No se puede ejecutar scripts en este sistema" / "no está firmado digitalmente"
```powershell
# Solución rápida: doble clic en Iniciar-OptiMax.bat

# O a mano, en la carpeta del proyecto (PowerShell Admin):
Get-ChildItem -Recurse -Filter *.ps1 | Unblock-File
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\scripts\launcher\Start-Optimizer.ps1
# Bypass -Scope Process solo aplica a la ventana actual de PowerShell
```

### "Acceso denegado" o "No tiene permisos"
No estás ejecutando como **Administrador**. 
- Cerrar PowerShell
- Buscar "PowerShell" en el menú Inicio
- **Clic derecho** → "Ejecutar como Administrador"
- Acepta el popup de UAC (User Account Control)

### Un servicio no se puede desactivar
Algunos servicios están protegidos por Windows (como TrustedInstaller). El script los **salta automáticamente** y continúa con los demás. No es un error, es normal.

### McAfee no se desinstala completamente
McAfee es famoso por ser difícil de remover. Si el script no lo elimina completamente:
1. Descargar **MCPR** (McAfee Consumer Product Removal) desde el sitio oficial de McAfee
2. Ejecutar MCPR como administrador
3. Seguir el asistente
4. Reiniciar

### El PC parece igual de lento después de la optimización
Posibles causas:
- **No se reinició**: Muchos cambios requieren reinicio
- **RAM insuficiente**: Si tiene 8 GB y usa Chrome con 10+ pestañas, la optimización software tiene límite. Recomienda ampliar a 16 GB (~$25.000-35.000 CLP)
- **Disco HDD**: Si el disco es HDD (mecánico), cambiar a SSD es el upgrade más impactante (~$20.000-40.000 CLP por un SSD de 240GB)
- **PC muy antiguo**: A veces el hardware simplemente no da más

### AnyDesk dejó de funcionar después de la optimización
Esto **no debería pasar** porque AnyDesk está en la lista de apps protegidas. Pero si por alguna razón ocurre:
- AnyDesk no se desinstala, pero su servicio pudo haberse afectado
- Pedirle al vendedor que abra AnyDesk manualmente
- Verificar que el servicio "AnyDesk Service" está corriendo en `services.msc`

### Los logs no se generan
La carpeta `logs/` se crea automáticamente, pero si no tiene permisos de escritura:
```powershell
# Crear la carpeta manualmente
New-Item -ItemType Directory -Path "C:\OptiMaxPro\logs" -Force
```

---

## Respuestas para el Cliente

Estas son respuestas preparadas para las preguntas más comunes que te hará el cliente. Úsalas tal cual o adáptalas:

### "¿Qué le hicieron a mi PC?"
> "Hicimos una optimización profesional completa. Eliminamos programas basura que venían preinstalados (como McAfee que estaba consumiendo mucha memoria), limpiamos archivos temporales, y configuramos Windows para que use los recursos de forma más eficiente. Es como hacerle una afinación al motor de un auto."

### "¿Mis archivos están seguros?"
> "Totalmente. No tocamos ningún documento, foto, ni archivo personal. Solo limpiamos archivos temporales del sistema (basura que Windows genera solo) y ajustamos configuraciones internas. Tus archivos están exactamente donde estaban."

### "¿Necesito hacer algo después?"
> "Solo reiniciar el equipo una vez para que se apliquen todos los cambios. Después de eso, debería notar que el PC enciende más rápido y responde mejor."

### "¿Se puede deshacer?"
> "Sí. Antes de hacer cualquier cambio, creamos un punto de restauración (como un respaldo del sistema). Si algo no funciona bien, podemos volver atrás en minutos sin perder ningún archivo."

### "¿Por qué estaba tan lento?"
> "Principalmente por tres razones: McAfee (un antivirus que no necesita porque ya tiene Windows Defender), muchos programas abriéndose solos cuando enciende el PC, y servicios de Windows que envían datos a Microsoft constantemente. Con 8GB de RAM, todo eso estaba saturando la memoria."

### "¿Tengo que hacer esto seguido?"
> "Recomiendo una revisión cada 3-6 meses. Windows va acumulando archivos temporales y actualizaciones que lo van haciendo más lento. Ofrecemos un servicio de mantenimiento mensual si le interesa."

### "¿No me van a hackear con esos scripts?"
> "No. Los scripts son creados por nosotros, están en GitHub (plataforma de código abierto) donde cualquiera puede revisar exactamente qué hacen. No envían datos a ningún servidor externo, no instalan nada, y todo es reversible."

---

## Checklists

### ✅ Pre-Servicio (Antes de tocar el PC)

```
□ ¿Te conectaste exitosamente vía AnyDesk?
□ ¿Abriste PowerShell como Administrador?
□ ¿Descargaste/copiaste OptiMax Pro al PC?
□ ¿Habilitaste ejecución de scripts (Set-ExecutionPolicy)?
□ ¿Ejecutaste el diagnóstico primero (opción 1)?
□ ¿Tomaste captura de pantalla del "antes"?
□ ¿Identificaste si es perfil Trabajo o Gaming?
□ ¿Le preguntaste al cliente si tiene archivos importantes sin respaldo?
```

### ✅ Post-Servicio (Después de optimizar)

```
□ ¿La optimización terminó sin errores críticos?
□ ¿Se reinició el equipo?
□ ¿AnyDesk sigue funcionando?
□ ¿El vendedor/cliente nota mejora?
□ ¿Tomaste captura del "después" en Monitor de Recursos?
□ ¿Se generaron los logs correctamente?
□ ¿Le explicaste al cliente qué se hizo?
□ ¿Le recomendaste upgrade de RAM/SSD si aplica?
□ ¿Ofreciste el servicio de mantenimiento mensual?
```

### ✅ Si Algo Sale Mal

```
□ ¿Intentaste la opción 14 (Restaurar Configuración Original)?
□ ¿Si eso no funcionó, restauraste el punto de restauración desde Windows?
□ ¿Revisaste los logs para entender qué pasó?
□ ¿El PC puede encender normalmente?
□ ¿AnyDesk funciona para reconectarte?
```
