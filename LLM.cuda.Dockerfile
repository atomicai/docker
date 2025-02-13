ARG CUDA_IMAGE="12.5.0-devel-ubuntu22.04"
FROM nvidia/cuda:${CUDA_IMAGE}

# We need to set the host to 0.0.0.0 to allow outside access
ENV HOST=0.0.0.0
ENV PORT=1228
ENV CTXSZ=8192
ENV NTHREADS=10
ENV CHATF=chatml
ENV WEIGHTS_PATH=/weights
ENV MODEL_PATH=/weights/LLM.gguf

# Установим системные зависимости
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# setting build related env vars
ENV CUDA_DOCKER_ARCH=all
ENV GGML_CUDA=1

# Install depencencies
RUN python3 -m pip install --upgrade pip pytest cmake scikit-build setuptools fastapi uvicorn sse-starlette pydantic-settings starlette-context

# Install llama-cpp-python (build with cuda)
RUN CMAKE_ARGS="-DGGML_CUDA=on" pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/12.5

# Создаем директорию для весов (по умолчанию)
RUN mkdir -p ${WEIGHTS_PATH}}

# Run the server
CMD python3 -m llama_cpp.server --model ${MODEL_PATH} --port ${PORT} --chat-template ${CHATF} --threads ${NTHREADS} --ctx-size ${CTXSZ}
