#!/usr/bin/env bash

set -euo pipefail

coder_model="unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF"
default_model="unsloth/Qwen3.6-27B-GGUF"

model_name=${1:-$default_model}
context_size=${2:-40960}

echo "Running LLM"
echo "Model: $model_name"
echo "Context size: $context_size"

llama-server \
  --hf-repo "$model_name" \
  --n-gpu-layers 999 \
  --ubatch-size 768 \
  --temp 0.2 \
  --ctx-size "$context_size" \
  --cache-type-k q5_1 \
  --cache-type-v q5_1 \
  --flash-attn on \
  --host 127.0.0.1 \
  --jinja \
  --port 8080
