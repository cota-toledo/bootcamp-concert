# Instrucciones Windows

[← Volver al inicio](README.md)

## Requisitos
- Acceso a IBM Concert. Tu usuario es `<tu-usuario>` y contraseña `bootcamp`.
- El **token** de OpenShift que te entregaremos (da acceso solo a tu namespace).
- El CLI de OpenShift (`oc.exe`) y **Git Bash** para correr los scripts (son scripts bash; no funcionan en CMD ni PowerShell).

### Instalar Git Bash
Si ya tienes Git instalado, salta este paso (busca "Git Bash" en el menú Inicio).

1. Descarga Git para Windows desde https://git-scm.com/download/win.
2. Instálalo con las opciones por defecto (siguiente, siguiente…).

### Instalar `oc`
1. Descarga https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-windows.zip
2. En el Explorador, clic derecho sobre el zip → **Extraer todo…**
3. Abre **Git Bash** y crea la carpeta `bin` en tu usuario (Git Bash la agrega al `PATH` automáticamente):
```bash
mkdir -p ~/bin
explorer.exe "$(cygpath -w ~/bin)"
```
4. Se abre la carpeta `C:\Users\<tu-usuario-de-windows>\bin`. Copia ahí el archivo **`oc.exe`** que extrajiste.
5. Cierra Git Bash y ábrelo de nuevo.

También puedes descargar `oc` desde la consola del cluster: **? → Command line tools**.

### Verificar
En Git Bash:
```bash
oc version --client
```
Debe mostrar `Client Version: 4.x.x`.

## 0. Prepara la terminal
1. Abre **Git Bash** en la carpeta donde quieras guardar el kit
   (en el Explorador: clic derecho en un espacio vacío → **Open Git Bash here**;
   en Windows 11 puede estar dentro de **Mostrar más opciones**).
2. Clona **este repositorio**, entra a la carpeta e inicia sesión con el token que te enviaremos:

```bash
git clone https://github.com/cota-toledo/bootcamp-concert.git
cd bootcamp-concert
oc login --token=<tu-token> --server=https://api.itz-czzc0l.hub01-lb.techzone.ibm.com:6443
```
- Si aparece un aviso sobre certificados, responde `y`.
- Si el comando se queda pegado sin mostrar nada, ciérralo con `Ctrl + C` y vuelve a ejecutarlo agregando `winpty` al inicio:
  `winpty oc login --token=<tu-token> --server=https://api.itz-czzc0l.hub01-lb.techzone.ibm.com:6443`
- Si dice que no tienes acceso a proyectos, no pasa nada: los scripts reciben tu namespace como argumento.

> Tu token solo te da acceso a tu namespace. No lo compartas.

## 1. Descubre tu app en Concert

![Concert - Resilience](data/home.png)

1. Concert → **Discover your data** → *Red Hat OpenShift (OCP)* → **Use existing connection**: `Openshift TZC` → Cluster name `concert-bootcamp-<tu-usuario>` → Next.

   ![Discover your data](data/discover1.png)

2. Target environment: `concert-bootcamp-<tu-usuario>` · Assessment period: **Minute** · count **1**.

   ![Target environment](data/discover2.png)

3. Namespaces → **Select Namespaces** → *Advanced filters → Include namespaces*: escribe tu namespace `concert-bootcamp-<tu-usuario>` → **Apply**
   → márcalo **solo a él** → **Select**.

   ![Namespaces](data/discover3.png)

4. Lápiz de la tarjeta → **New application**, profile **Kubernetes profile** → **Save** → **Next** hasta el Summary.

   ![New application](data/discover4.png)

   ![Summary](data/discover5.png)

## 2. Revisa tu postura inicial
Resilience → **Postures** → tu postura → última evaluación.
Anota **Availability** y **Usability** (deberían estar en 100).

## 3. Quita los health checks
En Git Bash, dentro de la carpeta `bootcamp-concert`:
```bash
bash quitar-probes.sh concert-bootcamp-<tu-usuario>
```

## 4. Reevalúa
Concert → **Integrations → Ingestion jobs** → tu job → **⋮ → Run now**.
Espera **~2 minutos** y abre la **última** evaluación de tu postura.

## 5. Compara
¿Qué pasó con **Availability** y **Usability**?
> Compara esos pilares, no el puntaje total: Security puede variar sola mientras llegan los escaneos.

## 6. (Opcional) Vuelve atrás
```bash
bash restaurar-probes.sh concert-bootcamp-<tu-usuario>
```
Run now otra vez → Availability y Usability deberían volver a 100.

---
**¿Por qué importa?** Sin health checks, Kubernetes solo sabe que el proceso está corriendo.
Si la app se cuelga, le sigue mandando tráfico y nunca la reinicia. Concert lo detecta como
un riesgo de disponibilidad.
