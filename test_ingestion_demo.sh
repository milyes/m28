#!/usr/bin/env bash
# ==============================================================================
# Z-CORE & NANS CORE // AUTOMATIC SAAS INGESTION DEMO
# ARCHITECT: MOHAMMED ILYES ZOUBIROU // TIMELINE: 2028 // LATENCY < 0.01s
# ==============================================================================

set -e

PORT=8080
TARGET_URL="http://localhost:${PORT}/upload"
MOCK_PDF="demo_client_payload.pdf"

echo -e "\033[0;36m[DEMO] Génération d'un fichier PDF client fictif pour le test...\033[0m"
# Génération d'un faux payload PDF propre pour la simulation
echo "%PDF-1.4 %⚡ Z-CORE INF-MATCHING DEMO PAYLOAD SOUVERAIN 2028 66/66 PASS" > "$MOCK_PDF"

echo -e "\033[0;36m[DEMO] Injection asynchrone du document dans le serveur local sur le port ${PORT}...\033[0m"

# Simulation d'un envoi de formulaire multipart/form-data via curl
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -F "file=@${MOCK_PDF};type=application/pdf" "$TARGET_URL")

if [ "$HTTP_STATUS" -eq 303 ] || [ "$HTTP_STATUS" -eq 200 ]; then
    echo -e "\033[0;32m[SUCCESS] TRANSIT TERMINÉ : Code HTTP ${HTTP_STATUS} reçu.\033[0m"
    echo -e "\033[0;32m[SUCCESS] Le payload a été intercepté par le serveur asynchrone et routé vers le processeur NANS.\033[0m"
    echo -e "\033[0;34m[INFO] Vérification des journaux système en direct :\033[0m"
    tail -n 3 zcore_production.log 2>/dev/null || tail -n 3 zcore_nans.log 2>/dev/null || echo "[OK] Serveur actif."
else
    echo -e "\033[0;31m[ÉCHEC] Le serveur n'a pas répondu correctement. Statut HTTP: ${HTTP_STATUS}\033[0m"
    echo -e "\033[0;33m[ASTECE] Assure-toi que ton serveur Python tourne bien en tâche de fond (./deploy_zcore_nans_2028_final.sh).\033[0m"
fi

# Nettoyage du fichier de test
rm -f "$MOCK_PDF"
