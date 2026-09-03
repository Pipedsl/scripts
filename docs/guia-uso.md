# 📖 Guía de Uso — OptiMax Pro

## Para el Técnico (Tú)

### Primer Uso en un Equipo Nuevo

1. **Copiar la carpeta** `scripts/` al PC del cliente (vía AnyDesk, USB, o descarga)

2. **Abrir PowerShell como Administrador:**
   - Clic derecho en el menú Inicio → "Windows PowerShell (Admin)"
   - O buscar "PowerShell" → Clic derecho → "Ejecutar como administrador"

3. **Permitir ejecución de scripts** (solo la primera vez):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Navegar a la carpeta:**
   ```powershell
   cd "C:\ruta\donde\copiaste\scripts\launcher"
   ```

5. **Ejecutar el launcher:**
   ```powershell
   .\Start-Optimizer.ps1
   ```

---

### Flujo de Trabajo Recomendado

```
1. DIAGNÓSTICO (opción 1)
   ↓ Analizar resultados
   ↓ Identificar problemas
   
2. BACKUP (opción 13)
   ↓ Siempre antes de cambios
   
3. OPTIMIZACIÓN COMPLETA (opción 2 o 3)
   ↓ Según el uso del equipo
   
4. VERIFICAR
   ↓ Abrir Monitor de Recursos
   ↓ Comparar antes/después
   
5. REINICIAR
   ↓ Aplicar todos los cambios
   
6. DOCUMENTAR
   → Tomar captura del estado final
   → Los logs se guardan automáticamente en /logs/
```

---

### Ejecución Remota (vía AnyDesk)

Cuando te conectas a un equipo remoto desde Santiago a Melipilla:

1. Conectarte vía AnyDesk
2. Abrir PowerShell Admin en el PC remoto
3. Copiar/pegar los scripts o ejecutar desde carpeta compartida
4. El script se ejecuta en el PC remoto, no en el tuyo

**Tip:** Si la conexión es lenta, ejecuta los scripts individuales en vez del orquestador completo. Así puedes ir módulo por módulo.

---

### Módulos Individuales (Uso Avanzado)

Si solo necesitas ejecutar un módulo específico:

```powershell
# Solo limpieza de temporales
cd scripts\trabajo
.\Clean-TempFiles.ps1

# Solo eliminar bloatware
.\Disable-Bloatware.ps1

# Solo diagnóstico
cd scripts\diagnostico
.\Get-SystemReport.ps1
```

---

## Solución de Problemas

### "No se puede ejecutar scripts en este sistema"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Acceso denegado" o "No tiene permisos"
→ No estás ejecutando como Administrador. Cerrar PowerShell y abrir como Admin.

### Un servicio no se puede desactivar
→ Puede estar protegido por el sistema. El script lo saltará automáticamente y continuará con los demás.

### El cliente quiere revertir los cambios
```powershell
cd scripts\comun
.\Restore-Defaults.ps1
```
→ Esto restaura TODA la configuración original.

### Los logs no se generan
→ Verificar que la carpeta tiene permisos de escritura. Los logs se crean en `scripts/../logs/`.

---

## Preguntas Frecuentes del Cliente

### "¿Qué le hicieron a mi PC?"
> "Realizamos una optimización profesional que incluye: limpieza de archivos basura, eliminación de software innecesario preinstalado, y configuración del sistema para máximo rendimiento. Todo es reversible."

### "¿Mis archivos están seguros?"
> "Absolutamente. No tocamos documentos, fotos ni archivos personales. Solo limpiamos archivos temporales del sistema y optimizamos la configuración."

### "¿Necesito hacer algo después?"
> "Solo reiniciar el equipo una vez. Después de eso, debería notar la diferencia inmediatamente."

### "¿Se puede deshacer?"
> "Sí, creamos un punto de restauración antes de cada optimización. Si algo no funciona bien, podemos revertir todo."

---

## Checklist Pre-Servicio

- [ ] ¿El equipo tiene backup de datos importantes?
- [ ] ¿Se creó punto de restauración?
- [ ] ¿Se ejecutó diagnóstico primero?
- [ ] ¿Se identificó si es perfil Trabajo o Gaming?
- [ ] ¿AnyDesk está en la lista de apps protegidas?

## Checklist Post-Servicio

- [ ] ¿Se reinició el equipo?
- [ ] ¿Se verificó que AnyDesk sigue funcionando?
- [ ] ¿Se tomaron capturas de antes/después?
- [ ] ¿Se guardaron los logs?
- [ ] ¿El cliente percibe mejora?
