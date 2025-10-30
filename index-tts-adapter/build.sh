#!/bin/bash
# 构建 IndexTTS Adapter Docker 镜像 (RTX 40 系列)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "IndexTTS Adapter 构建脚本 (RTX 40 系列)"
echo "=========================================="
echo ""

# 检查 index-tts 目录是否存在
if [ ! -d "index-tts" ]; then
    echo -e "${RED}[错误]${NC} 未找到 index-tts 目录！"
    echo ""
    echo "请先准备 index-tts 目录："
    echo ""
    echo "方式 1：从 GitHub 克隆（需要网络）"
    echo "  git clone https://github.com/index-tts/index-tts.git"
    echo "  cd index-tts"
    echo "  git lfs install"
    echo "  git lfs pull"
    echo ""
    echo "方式 2：从已准备好的压缩包解压"
    echo "  tar -xzf index-tts.tar.gz"
    echo ""
    echo "目录结构应该是："
    echo "  index-tts-adapter/"
    echo "  ├── index-tts/"
    echo "  │   ├── checkpoints/     (模型文件)"
    echo "  │   ├── indextts/"
    echo "  │   └── ..."
    echo "  └── Dockerfile"
    echo ""
    exit 1
fi

# 检查模型文件是否存在
if [ ! -f "index-tts/checkpoints/config.yaml" ]; then
    echo -e "${YELLOW}[警告]${NC} 未找到模型文件！"
    echo ""
    echo "模型文件应该在: index-tts/checkpoints/"
    echo ""
    echo "下载模型："
    echo "  cd index-tts"
    echo "  pip install -U 'huggingface-hub[cli]'"
    echo "  export HF_ENDPOINT=https://hf-mirror.com"
    echo "  huggingface-cli download IndexTeam/IndexTTS-2 --local-dir=checkpoints"
    echo ""
    read -p "是否继续构建？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消构建"
        exit 1
    fi
fi

echo -e "${GREEN}[✓]${NC} index-tts 目录检查通过"
echo ""
echo "开始构建 Docker 镜像..."
echo ""

# 构建镜像
docker build -t duix-avatar-tts-indextts-4090:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo -e "${GREEN}✅ 镜像构建成功！${NC}"
    echo "=========================================="
    echo ""
    echo "下一步："
    echo "  cd ../deploy"
    echo "  docker-compose -f docker-compose-indextts.yml up -d"
    echo ""
else
    echo ""
    echo "=========================================="
    echo -e "${RED}❌ 镜像构建失败${NC}"
    echo "=========================================="
    echo ""
    echo "常见问题："
    echo "1. index-tts 目录不完整"
    echo "2. Docker 服务未启动"
    echo "3. 磁盘空间不足"
    echo ""
    exit 1
fi

