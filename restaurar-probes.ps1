# Vuelve a poner los health checks (readiness y liveness probes) de la app.
# Uso: .\restaurar-probes.ps1 <tu-namespace>   ej: .\restaurar-probes.ps1 bootcamp-juan-1
# Efecto esperado en Concert (tras Run now): Availability y Usability vuelven a 100.
$ErrorActionPreference = 'Stop'
$NS = $args[0]
if (-not $NS) { Write-Host "Indica tu namespace, ej: .\restaurar-probes.ps1 bootcamp-juan-1"; exit 1 }

function Invoke-Oc {
  & oc @args
  if ($LASTEXITCODE -ne 0) { throw "Falló: oc $($args -join ' ')" }
}

Write-Host "▶ Restaurando readiness y liveness probes en $NS..."
Invoke-Oc set probe deployment/hola-resiliencia --readiness -n $NS `
  --get-url=http://:8080/ --initial-delay-seconds=5 --period-seconds=10
Invoke-Oc set probe deployment/hola-resiliencia --liveness -n $NS `
  --get-url=http://:8080/ --initial-delay-seconds=15 --period-seconds=20
Invoke-Oc rollout status deployment/hola-resiliencia -n $NS --timeout=180s
Write-Host ""
Write-Host "Probes actuales del contenedor:"
$r = Invoke-Oc get deployment hola-resiliencia -n $NS -o 'jsonpath={.spec.template.spec.containers[0].readinessProbe.httpGet}'
$l = Invoke-Oc get deployment hola-resiliencia -n $NS -o 'jsonpath={.spec.template.spec.containers[0].livenessProbe.httpGet}'
Write-Host "readiness: $r"
Write-Host "liveness:  $l"
Write-Host "✔ Listo. Ahora ve a Concert → Integrations → tu job → Run now."
