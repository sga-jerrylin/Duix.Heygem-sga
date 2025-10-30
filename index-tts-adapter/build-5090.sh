#!/bin/bash
# 构建 IndexTTS Adapter Docker 镜像 (RTX 50 系列)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "IndexTTS Adapter 构建脚本 (RTX 50 系列)"
echo "=========================================="
echo ""

# 检查 index-tts 目录
if [ ! -d "index-tts" ]; then
    echo -e "${RED}[错误]${NC} 未找到 index-tts 目录！"
    echo ""
    echo "请先准备 index-tts 目录（参考 build.sh 中的说明）"
    exit 1
fi

# 检查模型文件
if [ ! -f "index-tts/checkpoints/config.yaml" ]; then
    echo -e "${YELLOW}[警告]${NC} 未找到模型文件！"
    read -p "是否继续构建？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}[✓]${NC} index-tts 目录检查通过"
echo ""
echo "开始构建 Docker 镜像 (RTX 50 系列)..."
echo ""

docker build -f Dockerfile.5090 -t duix-avatar-tts-indextts-5090:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo -e "${GREEN}✅ 镜像构建成功！${NC}"
    echo "=========================================="
    echo ""
    echo "下一步："
    echo "  cd ../deploy"
    echo "  docker-compose -f docker-compose-indextts-5090.yml up -d"
    echo ""
else
    echo ""
    echo -e "${RED}❌ 镜像构建失败${NC}"
    exit 1
fi

