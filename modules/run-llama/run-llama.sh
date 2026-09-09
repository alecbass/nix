#!/usr/bin/env bash

set -euo pipefail

coder_model="unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF"
default_model="unsloth/Qwen3.6-27B-GGUF"

model_name=${1:-$default_model}
context_size=${2:-40960}
gpu_layers=${3:-64}

model_name="unsloth/gemma-4-E2B-it-GGUF"
model_name="ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF"
model_name="unsloth/gemma-4-26B-A4B-it-qat-GGUF"


echo "Running LLM"
echo "Model: $model_name"
echo "Context size: $context_size"

if [[ $model_name == "ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF" ]]; then
    echo "Running Qwen2.5 Coder for autocompletion."""
    llama-server \
      --hf-repo "$model_name" \
      --temp 1.0 \
      --host 127.0.0.1 \
      --jinja \
      --port 8012 \
      -ngl 99 \
      -fa on \
      -ub 1024 \
      -b 1024 \
      --ctx-size 0 \
      --cache-reuse 256
else
    gpu_layers=8
    llama-server \
      --hf-repo "$model_name" \
      --temp 1.0 \
      --host 127.0.0.1 \
      --jinja \
      --port 8012 \
      -ngl 99 \
      -fa on \
      -ub 1024 \
      -b 1024 \
      --ctx-size "$context_size" \
      --gpu-layers "$gpu_layers" \
      --cache-reuse 256
fi

