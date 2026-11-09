#!/usr/bin/env bash
# ==============================================================================
# Z-CORE & NANS CORE // AUTOMATIC SECURE BACKUP SYSTEM
# ARCHITECT: MOHAMMED ILYES ZOUBIROU // TIMELINE: 2028
# ==============================================================================

set -e

BACKUP_NAME="backup_zcore_$(date +%Y%m%d_%H%M%S).tar.gz"
TARGET_DIR="/data/data/com.termux/files/home/m28"

echo -e "\033[0;36m[BACKUP] Initialisation de la sauvegarde souveraine...\033[0m"

# Vérification du répertoire courant
if [ "$PWD" != "$TARGET_DIR" ]; then
    cd "$TARGET_DIR"
fi

# Création de l'archive tar.gz en excluant les fichiers volumineux ou inutiles
tar --exclude='*.log' \
    --exclude='payload_*' \
    --exclude='backup_zcore_*.tar.gz' \
    -czf "$BACKUP_NAME" .

echo -e "\033[0;32m[SUCCESS] Archive créée avec succès : ${BACKUP_NAME}\033[0m"
echo -e "\033[0;35m[INFO] Contenu sauvegardé dans : $TARGET_DIR\033[0m"
echo -e "\033[0;34m[CMD] Pour restaurer : tar -xzf ${BACKUP_NAME}\033[0m"
