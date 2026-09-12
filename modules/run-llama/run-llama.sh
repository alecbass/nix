#!/usr/bin/env bash

set -euo pipefail

mode=${1:-""}

if [[ $mode != "fim" && $mode != "big-fim" && $mode != "default" ]]; then
    echo "Usage: <run_llama> <fim|big-fim|default>"
    exit 1
fi

fim_model="ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF"
big_fim_model="ggml-org/Qwen3-Coder-30B-A3B-Instruct-Q8_0-GGUF"
default_model="unsloth/gemma-4-E2B-it-GGUF"

if [[ $mode == "fim" ]]; then
    model=$fim_model
elif [[ $mode == "big-fim" ]]; then
    model=$big_fim_model
elif [[ $mode == "default" ]]; then
    model=$default_model
fi

context_size=${2:-40960}

echo "Running LLM"
echo "Model: $model"
echo "Context size: $context_size"

if [[ $mode == "fim" ]]; then
    echo "Running code autocompletion."""
    gpu_layers=8
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
      --ctx-size "$context_size" \
      --cache-reuse 256 \
      --gpu-layers $gpu_layers
elif [[ $mode == "big-fim" ]]; then
    echo "Running BIG code autocompletion."""
    gpu_layers=8
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
      --ctx-size "$context_size" \
      --cache-reuse 256 \
      --gpu-layers $gpu_layers
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

