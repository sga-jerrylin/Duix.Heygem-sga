# IndexTTS Adapter Dockerfile for RTX 40 Series (4090, 4080, etc.)
# 针对 RTX 40 系列显卡优化

FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    git-lfs \
    wget \
    curl \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /code

# 安装 uv 包管理器
RUN pip3 install -U uv

# 复制本地的 index-tts 代码（需要先手动下载）
COPY index-tts /code/index-tts

# 进入 index-tts 目录并安装依赖
WORKDIR /code/index-tts
RUN git lfs install --force && git lfs pull

# 使用 uv 安装依赖
RUN uv sync --all-extras

# 下载模型（使用 HuggingFace 镜像）
ENV HF_ENDPOINT=https://hf-mirror.com
RUN uv tool install "huggingface-hub[cli,hf_xet]" && \
    ~/.local/bin/hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints

# 复制适配器代码
WORKDIR /code
COPY api_server.py /code/api_server.py
COPY requirements.txt /code/requirements.txt

# 在 index-tts 目录中使用 uv 安装适配器依赖
WORKDIR /code/index-tts
RUN uv pip install -r /code/requirements.txt

# 创建数据目录
RUN mkdir -p /code/data

# 暴露端口
EXPOSE 8080

# 启动命令（使用 uv run 运行）
WORKDIR /code
CMD ["uv", "run", "--directory", "/code/index-tts", "python", "/code/api_server.py"]

