#!/usr/bin/env bash

set -euo pipefail

coder_model="unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF"
default_model="unsloth/Qwen3.6-27B-GGUF"

model_name=${1:-$default_model}
context_size=${2:-40960}
gpu_layers=${3:-64}

model_name="unsloth/gemma-4-E2B-it-GGUF"

echo "Running LLM"
echo "Model: $model_name"
echo "Context size: $context_size"

llama-server \
  --hf-repo "$model_name" \
  --temp 1.0 \
  --host 127.0.0.1 \
  --jinja \
  --port 8080
