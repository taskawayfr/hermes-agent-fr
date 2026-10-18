#!/usr/bin/env bash
# Tâche programmée « script seul » (sans modèle) : n'affiche rien si tout va bien.
# Hermes n'envoie un message que si le script affiche quelque chose.
# Installation : copier dans ~/.hermes/scripts/, puis
#   hermes cron create "every 1h" --no-agent --script surveillance-disque.sh --deliver telegram --name disque
set -euo pipefail

SEUIL=90   # pourcentage d'occupation au-delà duquel on alerte (à adapter)

occupation=$(df -P "$HOME" | awk 'NR==2 { gsub("%", "", $5); print $5 }')
if [ "$occupation" -ge "$SEUIL" ]; then
  echo "Disque de la machine Hermes plein à ${occupation} % : faites de la place avant que l'agent ne s'arrête."
fi
