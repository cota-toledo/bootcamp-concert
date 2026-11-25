# Despliega la app en uno o varios namespaces (los crea si no existen).
# Uso: .\desplegar.ps1 ns1 [ns2 ns3 ...]
#  ej: .\desplegar.ps1 bootcamp-juan-1
# Si PowerShell bloquea scripts:
#   powershell -ExecutionPolicy Bypass -File .\desplegar.ps1 bootcamp-juan-1
$ErrorActionPreference = 'Stop'
$Namespaces = $args
if ($Namespaces.Count -lt 1) { Write-Host "Uso: .\desplegar.ps1 ns1 [ns2 ...]"; exit 1 }
if (-not (Get-Command oc -ErrorAction SilentlyContinue)) {
  Write-Host "No se encontró 'oc'. Instálalo y agrégalo al PATH."; exit 1
}
$Dir = $PSScriptRoot

function Invoke-Oc {
  & oc @args
  if ($LASTEXITCODE -ne 0) { throw "Falló: oc $($args -join ' ')" }
}

foreach ($NS in $Namespaces) {
  oc get project $NS *> $null
  if ($LASTEXITCODE -ne 0) { Invoke-Oc new-project $NS | Out-Null }
  Invoke-Oc apply -n $NS -f (Join-Path $Dir 'base') | Out-Null
  Write-Host "✔ $NS creado"
}

Write-Host "Esperando que levanten los pods..."
foreach ($NS in $Namespaces) {
  Invoke-Oc rollout status deployment/hola-resiliencia -n $NS --timeout=180s | Out-Null
  $hostName = Invoke-Oc get route hola-resiliencia -n $NS -o 'jsonpath={.spec.host}'
  Write-Host "✔ $NS listo → https://$hostName"
}
