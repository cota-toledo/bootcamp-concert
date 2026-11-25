# EJERCICIO DEL BOOTCAMP: quita los health checks (readiness y liveness probes) de la app.
# Uso: .\quitar-probes.ps1 <tu-namespace>   ej: .\quitar-probes.ps1 bootcamp-juan-1
# Efecto esperado en Concert (tras Run now): Availability y Usability caen de 100 a 0.
$ErrorActionPreference = 'Stop'
$NS = $args[0]
if (-not $NS) { Write-Host "Indica tu namespace, ej: .\quitar-probes.ps1 bootcamp-juan-1"; exit 1 }

function Invoke-Oc {
  & oc @args
  if ($LASTEXITCODE -ne 0) { throw "Falló: oc $($args -join ' ')" }
}

Write-Host "▶ Quitando readiness y liveness probes en $NS..."
Invoke-Oc set probe deployment/hola-resiliencia --readiness --liveness --remove -n $NS
Invoke-Oc rollout status deployment/hola-resiliencia -n $NS --timeout=180s
Write-Host ""
Write-Host "Probes actuales del contenedor (debería salir vacío):"
$r = Invoke-Oc get deployment hola-resiliencia -n $NS -o 'jsonpath={.spec.template.spec.containers[0].readinessProbe}'
$l = Invoke-Oc get deployment hola-resiliencia -n $NS -o 'jsonpath={.spec.template.spec.containers[0].livenessProbe}'
Write-Host "$r$l"
Write-Host "✔ Listo. Ahora ve a Concert → Integrations → tu job → Run now."
