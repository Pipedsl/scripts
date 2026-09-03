# 🔍 Diagnóstico — PC Vendedor (Melipilla)

**Fecha:** 03/09/2026
**Técnico:** Felipe (remoto vía AnyDesk desde Santiago)
**Equipo:** PC de punto de venta

---

## Estado del Sistema (Captura del Monitor de Recursos)

### 🔴 RAM — PROBLEMA PRINCIPAL
- **Uso:** 89% (7005 MB de 8192 MB)
- **Disponible:** Solo 825 MB libres
- **Instalada:** 8192 MB (8 GB)
- **Estado:** CRÍTICO

**Procesos más pesados en RAM:**
| Proceso | RAM (MB) | Observación |
|---------|----------|-------------|
| MsMpEng.exe | ~330 | Windows Defender (necesario) |
| dwm.exe | ~215 | Desktop Window Manager (sistema) |
| AnyDesk.exe | ~200 | Acceso remoto (NECESARIO) |
| chrome.exe (x4) | ~600+ | Múltiples instancias Chrome |
| msedge.exe | ~185 | Microsoft Edge |
| SnippingTool | ~170 | Herramienta recortes |
| javaw.exe | ~120 | Java (¿para qué?) |

### 🟢 CPU — SIN PROBLEMAS
- **Uso:** 7%
- **Frecuencia máxima:** 62-65%
- **Conclusión:** CPU no es cuello de botella

### 🟡 Disco — ACTIVIDAD ALTA
- **Problema detectado:** SDXHelper.exe consumiendo +1 MB/s
- **SDXHelper.exe (PID 9164):** 1,033,769 B/s lectura
- **SDXHelper.exe (PID 5864):** 624,469 B/s lectura
- **Conclusión:** Office SDK Helper saturando el disco

### 🟡 Red — NORMAL
- AnyDesk: 85,283 B/s envío (normal para sesión remota)
- Chrome: 2,210 B/s recepción
- Sin anomalías

---

## Problemas Identificados (Prioridad)

### 1. 🔴 RAM Insuficiente
La RAM está al 89%. Con solo 8 GB y múltiples navegadores abiertos, el sistema está usando swap constantemente.

**Solución software:** Optimización de servicios y procesos innecesarios (~150-200 MB recuperables)
**Solución hardware:** Ampliar a 16 GB (~$25.000-35.000 CLP)

### 2. 🟡 Bloatware Consumiendo Recursos
- **McAfee WebAdvisor:** Antivirus preinstalado innecesario (Windows Defender ya está activo)
- **SDXHelper.exe:** Office SDK Helper consumiendo disco masivamente
- **McAfee + SDXHelper** juntos consumen ~100-150 MB RAM y saturan disco

### 3. 🟡 Múltiples Navegadores Abiertos
- 4 instancias de Chrome
- Microsoft Edge
- Cada pestaña consume ~50-100 MB de RAM

### 4. 🟡 Java Corriendo en Background
- javaw.exe consumiendo ~120 MB RAM
- ¿Es necesario? Revisar qué aplicación Java usa el vendedor

---

## Plan de Acción

### Inmediato (vía AnyDesk)
1. ✅ Ejecutar `Optimize-WorkPC.ps1` para aplicar optimización completa
2. ✅ Eliminar McAfee (Windows Defender es suficiente)
3. ✅ Desactivar SDXHelper vía Task Scheduler
4. ✅ Reducir Chrome a máximo 2-3 pestañas
5. ✅ Investigar si Java es necesario

### Mediano plazo
- 💰 Recomendar ampliación de RAM a 16 GB
- 💰 Verificar si el disco es HDD → cambiar a SSD

---

## Resultado Esperado Post-Optimización

| Métrica | Antes | Después (estimado) |
|---------|-------|-------------------|
| RAM en uso | 89% | 65-70% |
| MB disponibles | 825 MB | 1.5-2 GB |
| Disco I/O | Alto (SDXHelper) | Normal |
| Tiempo de arranque | Lento | -30% más rápido |
