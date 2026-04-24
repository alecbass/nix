#!/usr/bin/env bash
set -euo pipefail

context_size=${1:-40960}

echo "Running LLM"
echo "Context size: $context_size"

coder_model="unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF"
model="unsloth/Qwen3.6-35B-A3B-GGUF"

llama-server \
  --hf-repo $model \
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
