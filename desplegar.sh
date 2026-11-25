#!/usr/bin/env bash
# Despliega la app en uno o varios namespaces (los crea si no existen).
# Uso: bash desplegar.sh ns1 [ns2 ns3 ...]
#  ej: bash desplegar.sh bootcamp-juan-1
set -euo pipefail
[ $# -ge 1 ] || { echo "Uso: bash desplegar.sh ns1 [ns2 ...]"; exit 1; }
DIR="$(cd "$(dirname "$0")" && pwd)"

for NS in "$@"; do
  oc get project "$NS" >/dev/null 2>&1 || oc new-project "$NS" >/dev/null
  oc apply -n "$NS" -f "$DIR/base/" >/dev/null
  echo "✔ $NS creado"
done

echo "Esperando que levanten los pods..."
for NS in "$@"; do
  oc rollout status deployment/hola-resiliencia -n "$NS" --timeout=180s >/dev/null
  echo "✔ $NS listo → https://$(oc get route hola-resiliencia -n "$NS" -o jsonpath='{.spec.host}')"
done
