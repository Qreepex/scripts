#!/usr/bin/env fish

# 1. Umgebungsvariablen für den lokalen LiteLLM-Proxy setzen
set -x ANTHROPIC_BASE_URL "https://openwebui.de"
set -x ANTHROPIC_API_KEY "XXXXXXXX"

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
read -P "Waehle ein Modell (1-6) [Standard: 1]: " choice
if test -z "$choice"
    set choice 1
end

# 4. Anhand der Eingabe das Modell auswaehlen (die kurzen Namen aus der yaml)
switch $choice
    case 1
        set SELECTED_MODEL "vllm/google/gemma-4-26B-A4B-it"
    case 2
        set SELECTED_MODEL "vllm/google/gemma-4-31B-it"
    case 3
        set SELECTED_MODEL "vllm/openai/gpt-oss-120b"
    case 4
        set SELECTED_MODEL "vllm/Qwen/Qwen3.5-27B"
    case 5
        set SELECTED_MODEL "vllm/deepseek-ai/DeepSeek-V4-Flash"
    case 6
        set SELECTED_MODEL "vllm/deepseek-ai/DeepSeek-V4-Pro"
    case '*'
        echo "Ungueltige Eingabe. Nutze Standard: Gemma 26B."
        set SELECTED_MODEL "vllm/google/gemma-4-26B-A4B-it"
end

# 5. Modell an Claude uebergeben
set -x ANTHROPIC_MODEL $SELECTED_MODEL

echo
echo "=> Starte Claude Code mit: $ANTHROPIC_MODEL"
echo

# 6. Claude Code ausführen (weitere Parameter wie Ordnerpfade werden durch $argv mitgenommen)
claude $argv
