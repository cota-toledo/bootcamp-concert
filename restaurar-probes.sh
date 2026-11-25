#!/usr/bin/env bash
# Vuelve a poner los health checks (readiness y liveness probes) de la app.
# Uso: ./restaurar-probes.sh <tu-namespace>   ej: ./restaurar-probes.sh concert-bootcamp-ncarreno
# Efecto esperado en Concert (tras Run now): Availability y Usability vuelven a 100.
set -euo pipefail
NS="${1:?Indica tu namespace, ej: ./restaurar-probes.sh concert-bootcamp-ncarreno}"
echo "▶ Restaurando readiness y liveness probes en $NS..."
oc set probe deployment/hola-resiliencia --readiness -n "$NS" \
  --get-url=http://:8080/ --initial-delay-seconds=5 --period-seconds=10
oc set probe deployment/hola-resiliencia --liveness -n "$NS" \
  --get-url=http://:8080/ --initial-delay-seconds=15 --period-seconds=20
oc rollout status deployment/hola-resiliencia -n "$NS" --timeout=180s
echo
echo "Probes actuales del contenedor:"
oc get deployment hola-resiliencia -n "$NS" \
  -o jsonpath='readiness: {.spec.template.spec.containers[0].readinessProbe.httpGet}{"\n"}liveness:  {.spec.template.spec.containers[0].livenessProbe.httpGet}{"\n"}'
echo "✔ Listo. Ahora ve a Concert → Integrations → tu job → Run now."
