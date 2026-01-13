# GUÍA COMPLETA - LIMPIEZA POST-INCIDENTE

## 🗑️ ELIMINACIÓN DE RECURSOS AZURE

### **EJECUTA AHORA:**
```powershell
.\DELETE_ALL.ps1
```

**Qué eliminará:**
- ✅ rg-azmon-poc-mexicocentral (Escenarios 0, 1, 2)
- ✅ Todos los resource groups fallidos
- ✅ Archivos locales con credenciales
- ✅ Terraform states
- ✅ ZIPs de deployment

**Tiempo:** 5-10 minutos (background)

---

## 🔒 LIMPIEZA DE GITHUB

### **OPCIÓN 1: Eliminar Repositorio Completo (RECOMENDADO)**

**Es la forma más segura y simple:**

1. GitHub → https://github.com/BrianDJesusV/poc-az-monitor
2. Settings (tab superior)
3. Scroll hasta el final → **Danger Zone**
4. **Delete this repository**
5. Escribir: `BrianDJesusV/poc-az-monitor`
6. Confirmar

**Tiempo:** 1 minuto

---

### **OPCIÓN 2: Limpiar Historial Git (Avanzado)**

Si quieres mantener el código pero limpiar el historial:

#### **Método A: BFG Repo-Cleaner**

```bash
# Descargar BFG
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar

# Clonar repo con mirror
git clone --mirror git@github.com:BrianDJesusV/poc-az-monitor.git

# Limpiar archivos con secrets
java -jar bfg-1.14.0.jar --delete-files terraform.tfstate poc-az-monitor.git
java -jar bfg-1.14.0.jar --delete-files outputs.json poc-az-monitor.git

# Limpiar referencias
cd poc-az-monitor.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push --force
```

#### **Método B: git filter-repo**

```bash
# Instalar
pip install git-filter-repo

# Clonar repo
git clone git@github.com:BrianDJesusV/poc-az-monitor.git
cd poc-az-monitor

# Limpiar archivos específicos
git filter-repo --path terraform.tfstate --invert-paths
git filter-repo --path outputs.json --invert-paths
git filter-repo --path outputs.txt --invert-paths

# Force push
git push --force
```

---

## 📋 CHECKLIST POST-LIMPIEZA

### **Azure**
- [ ] Ejecutar `DELETE_ALL.ps1`
- [ ] Esperar 10 minutos
- [ ] Verificar en Portal que no quedan recursos
- [ ] Revisar billing (puede tomar 24h actualizarse)

### **GitHub**
- [ ] Eliminar repositorio O limpiar historial
- [ ] Si limpiaste historial, verificar con GitHub Secrets Scanner
- [ ] Configurar `.gitignore` para futuros proyectos

### **GitGuardian**
- [ ] Ir al email de GitGuardian
- [ ] Click "Mark as false positive" si eliminaste todo
- [ ] O click "Fix this secret leak" para confirmar remediación

### **Mejores Prácticas Futuras**
- [ ] NUNCA subir archivos `.tfstate`
- [ ] NUNCA subir `outputs.json`
- [ ] Usar `.gitignore` apropiado
- [ ] Usar Azure Key Vault para secrets
- [ ] Usar variables de entorno
- [ ] Revisar antes de cada commit

---

## 📄 ARCHIVO .gitignore PARA TERRAFORM

Crea este archivo en tu repo:

```gitignore
# Terraform
*.tfstate
*.tfstate.*
*.tfstate.backup
.terraform/
.terraform.lock.hcl
tfplan
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Sensitive outputs
outputs.json
outputs.txt

# Credentials
*.pem
*.key
*.pfx
*.p12
credentials.json

# Azure Functions
local.settings.json
*.zip

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
```

---

## ⏱️ TIMELINE COMPLETO

```
AHORA:
  1. Ejecutar DELETE_ALL.ps1         (1 min)
  2. Eliminar repo GitHub             (1 min)
  ────────────────────────────────────────
  TOTAL INMEDIATO:                    2 min

ESPERAR:
  3. Azure eliminando recursos        (5-10 min)
  4. GitHub procesando                (instantáneo)
  ────────────────────────────────────────
  TOTAL COMPLETO:                     10-12 min
```

---

## 🎯 COMANDOS RÁPIDOS

### **Verificar eliminación en Azure**
```powershell
az group list --query "[?starts_with(name, 'rg-azmon')].name" -o table
```
Debe retornar vacío después de 10 minutos.

### **Verificar costos**
```powershell
az consumption usage list --start-date 2026-01-01 --end-date 2026-01-31
```

### **Listar todas las suscripciones (verificar no hay otros recursos)**
```powershell
az resource list --query "[].{Name:name, Type:type, RG:resourceGroup}" -o table
```

---

## ✅ CONFIRMACIÓN FINAL

Después de 10-15 minutos:

1. **Azure Portal:** No debe haber resource groups `rg-azmon-*`
2. **GitHub:** Repo eliminado o historial limpio
3. **GitGuardian:** Marcar como resuelto
4. **Archivos locales:** Sin `.tfstate` ni `outputs.json`

---

## 💡 LECCIONES APRENDIDAS

**Para futuros proyectos:**
1. ✅ Siempre usar `.gitignore` ANTES del primer commit
2. ✅ Revisar archivos staged antes de commit
3. ✅ Usar Azure Key Vault para secrets
4. ✅ Variables de entorno para credenciales
5. ✅ GitHub Secret Scanning habilitado
6. ✅ Pre-commit hooks para detectar secrets

---

**Ejecuta ahora:**
```powershell
.\DELETE_ALL.ps1
```

**Luego ve a GitHub y elimina el repo.**

**Total: 10-12 minutos y todo limpio.** ✅
