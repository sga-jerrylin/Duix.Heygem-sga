#!/bin/bash
# 构建 IndexTTS Adapter Docker 镜像 (RTX 50 系列)

echo "开始构建 IndexTTS Adapter Docker 镜像 (RTX 50 系列)..."

# 构建镜像
docker build -f Dockerfile.5090 -t duix-avatar-tts-indextts-5090:latest .

if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功！"
    echo ""
    echo "使用以下命令启动服务："
    echo "  cd ../deploy"
    echo "  docker-compose -f docker-compose-indextts-5090.yml up -d"
else
    echo "❌ 镜像构建失败，请检查错误信息"
    exit 1
fi

