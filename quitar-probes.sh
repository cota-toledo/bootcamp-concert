#!/usr/bin/env bash
# EJERCICIO DEL BOOTCAMP: quita los health checks (readiness y liveness probes) de la app.
# Uso: bash quitar-probes.sh <tu-namespace>   ej: bash quitar-probes.sh juan-1
# Efecto esperado en Concert (tras Run now): Availability y Usability caen de 100 a 0.
set -euo pipefail
NS="${1:?Indica tu namespace, ej: bash quitar-probes.sh juan-1}"
echo "▶ Quitando readiness y liveness probes en $NS..."
oc set probe deployment/hola-resiliencia --readiness --liveness --remove -n "$NS"
oc rollout status deployment/hola-resiliencia -n "$NS" --timeout=180s
echo
echo "Probes actuales del contenedor (debería salir vacío):"
oc get deployment hola-resiliencia -n "$NS" \
  -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}{.spec.template.spec.containers[0].livenessProbe}{"\n"}'
echo "✔ Listo. Ahora ve a Concert → Integrations → tu job → Run now."
