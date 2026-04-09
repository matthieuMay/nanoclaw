#!/bin/bash
# NanoClaw - Migration vers Ollama
# Utilisation : ./migrate-ollama.sh [modèle] [host] [token]

echo "🔄 Migration NanoClaw vers Ollama"
echo "=================================="

# Configuration par défaut
OLLAMA_HOST="${1:-host.docker.internal:11434}"
OLLAMA_MODEL="${2:-qwen3:9b}"
OLLAMA_TOKEN="${3:-ollama}"

echo "Configuration :"
echo "  Modèle : $OLLAMA_MODEL"
echo "  Ollama Host : $OLLAMA_HOST"
echo "  Token : $OLLAMA_TOKEN"
echo ""

# Étape 1 : Installer le modèle
echo "📥 Étape 1 : Installer le modèle sur Ollama..."
ollama pull "$OLLAMA_MODEL"
echo "✅ Modèle '$OLLAMA_MODEL' prêt !\n"

# Étape 2 : Mettre à jour .env
echo "📝 Étape 2 : Mettre à jour .env..."
if [ -f ".env" ]; then
    sed -i.bak 's|^ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY='"$OLLAMA_TOKEN"'|' .env
    sed -i.bak 's|^ANTHROPIC_BASE_URL=.*|ANTHROPIC_BASE_URL='"$OLLAMA_HOST"'|' .env
    echo "✅ .env mis à jour"
else
    echo "⚠️  Fichier .env non trouvé"
fi

# Étape 3 : Mettre à jour les sessions
echo ""
echo "📂 Étape 3 : Mettre à jour les sessions..."
if [ -d "data/sessions" ]; then
    find data/sessions -name ".claude/settings.json" -exec bash -c '
        for file in "$1"; do
            sed -i "s|model:.*|model: ollama/$OLLAMA_MODEL|g" "$file"
            sed -i "s|system: \"claude\"|system: \"ollama/$OLLAMA_MODEL\"|g" "$file"
            echo "  ✓ $(basename $(dirname $(dirname $(dirname "$file"))))/$(basename $(dirname $(dirname $(dirname "$file"))))"
        done
    ' _ {} \;
    echo "✅ Sessions mises à jour"
else
    echo "ℹ️  Aucun dossier data/sessions trouvé"
fi

echo ""
echo "=================================="
echo "✅ Migration terminée !"
echo ""
echo "🚀 Pour activer : restartez votre service NanoClaw" 