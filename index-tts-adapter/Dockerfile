# IndexTTS Adapter Dockerfile for RTX 40 Series (4090, 4080, etc.)
# 针对 RTX 40 系列显卡优化
# 使用本地 index-tts 目录，模型内置在镜像中

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

# 复制本地的 index-tts 目录（包含代码和模型）
# 重要：构建前必须准备好完整的 index-tts 目录（包含 checkpoints 模型文件）
COPY index-tts /code/index-tts

# 复制适配器代码
COPY api_server.py /code/api_server.py
COPY requirements.txt /code/requirements.txt

# 进入 index-tts 目录并安装依赖
WORKDIR /code/index-tts

# 确保 Git LFS 文件已拉取（如果有）
RUN git lfs install --force 2>/dev/null || true

# 使用 uv 安装 index-tts 依赖
RUN uv sync --all-extras

# 安装适配器依赖
RUN uv pip install -r /code/requirements.txt

# 创建数据目录
RUN mkdir -p /code/data

# 验证模型文件是否存在
RUN if [ ! -f "/code/index-tts/checkpoints/config.yaml" ]; then \
        echo "错误：未找到模型文件！请确保 index-tts/checkpoints 目录包含模型文件"; \
        exit 1; \
    fi && \
    echo "✓ 模型文件验证成功"

# 暴露端口
EXPOSE 8080

# 启动命令（使用 uv run 运行）
WORKDIR /code
CMD ["uv", "run", "--directory", "/code/index-tts", "python", "/code/api_server.py"]

