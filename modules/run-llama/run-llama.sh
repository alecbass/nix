#!/usr/bin/env bash

set -euo pipefail

mode=${1:-""}

if [[ $mode != "fim" && $mode != "default" ]]; then
    echo "Usage: <run_llama> <fim|default>"
    exit 1
fi

fim_model="ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF"
default_model="unsloth/gemma-4-E2B-it-GGUF"

if [[ $mode == "fim" ]]; then
    model=$fim_model
elif [[ $mode == "default" ]]; then
    model=$default_model
fi

context_size=${2:-40960}

echo "Running LLM"
echo "Model: $model"
echo "Context size: $context_size"

if [[ $mode == "fim" ]]; then
    echo "Running code autocompletion."""
    llama-server \
      --hf-repo "$model" \
      --temp 0.1 \
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
    echo "Running default"
    gpu_layers=8
    llama-server \
      --hf-repo "$model" \
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

