#!/usr/bin/env bash
set -e

# 1. Umgebungsvariablen für den lokalen LiteLLM-Proxy setzen
export ANTHROPIC_BASE_URL="https://openwebui.de"
export ANTHROPIC_API_KEY="XXXXXXXX"

# 2. Menü anzeigen
echo "======================================================="
echo "         CLAUDE CODE - LOKALE MODELLAUSWAHL"
echo "======================================================="
echo "[1] Gemma 4 (26B)  - vllm/google/gemma-4-26B-A4B-it"
echo "[2] Gemma 4 (31B)  - vllm/google/gemma-4-31B-it"
echo "[3] GPT-OSS (120B) - vllm/openai/gpt-oss-120b"
echo "[4] Qwen 3.5 (27B) - vllm/Qwen/Qwen3.5-27B"
echo "[5] DeepSeek v4 Flash - vllm/deepseek-ai/DeepSeek-V4-Flash"
echo "[6] DeepSeek v4 Pro - vllm/deepseek-ai/DeepSeek-V4-Pro"
echo "======================================================="
echo

# 3. Eingabe abfragen (Standard ist 1, falls du nur Enter drueckst)
read -rp "Waehle ein Modell (1-6) [Standard: 1]: " choice
choice="${choice:-1}"

# 4. Anhand der Eingabe das Modell auswaehlen (die kurzen Namen aus der yaml)
case "$choice" in
    1) SELECTED_MODEL="vllm/google/gemma-4-26B-A4B-it" ;;
    2) SELECTED_MODEL="vllm/google/gemma-4-31B-it" ;;
    3) SELECTED_MODEL="vllm/openai/gpt-oss-120b" ;;
    4) SELECTED_MODEL="vllm/Qwen/Qwen3.5-27B" ;;
    5) SELECTED_MODEL="vllm/deepseek-ai/DeepSeek-V4-Flash" ;;
    6) SELECTED_MODEL="vllm/deepseek-ai/DeepSeek-V4-Pro" ;;
    *)
        echo "Ungueltige Eingabe. Nutze Standard: Gemma 26B."
        SELECTED_MODEL="vllm/google/gemma-4-26B-A4B-it"
        ;;
esac

# 5. Modell an Claude uebergeben
export ANTHROPIC_MODEL="$SELECTED_MODEL"

echo
echo "=> Starte Claude Code mit: $ANTHROPIC_MODEL"
echo

# 6. Claude Code ausführen (weitere Parameter wie Ordnerpfade werden durch "$@" mitgenommen)
claude "$@"
