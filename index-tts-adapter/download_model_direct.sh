#!/bin/bash
# 直接下载 IndexTTS-2 模型文件（使用 wget 或 curl）
# 适用于 HuggingFace CLI 无法工作的情况

set -e

echo "=========================================="
echo "IndexTTS-2 模型直接下载脚本"
echo "=========================================="
echo ""

# 检查是否在 index-tts 目录
if [ ! -d "indextts" ]; then
    echo "[错误] 请在 index-tts 目录下运行此脚本"
    echo ""
    echo "正确的位置："
    echo "  index-tts-adapter/index-tts/"
    echo ""
    exit 1
fi

# 创建 checkpoints 目录
mkdir -p checkpoints
cd checkpoints

echo "开始下载模型文件..."
echo "使用国内镜像: hf-mirror.com"
echo ""

# 设置镜像地址
MIRROR="https://hf-mirror.com/IndexTeam/IndexTTS-2/resolve/main"

# 检查使用 wget 还是 curl
if command -v wget &> /dev/null; then
    DOWNLOAD="wget -c -O"
elif command -v curl &> /dev/null; then
    DOWNLOAD="curl -L -C - -o"
else
    echo "错误：未找到 wget 或 curl"
    echo "请安装其中之一："
    echo "  Ubuntu/Debian: sudo apt-get install wget"
    echo "  CentOS/RHEL: sudo yum install wget"
    echo "  macOS: brew install wget"
    exit 1
fi

echo "[1/6] 下载 config.yaml..."
$DOWNLOAD config.yaml "$MIRROR/config.yaml"

echo "[2/6] 下载 model.pt (主模型文件，约 2GB，请耐心等待)..."
$DOWNLOAD model.pt "$MIRROR/model.pt"

echo "[3/6] 下载 vocab.txt..."
$DOWNLOAD vocab.txt "$MIRROR/vocab.txt"

echo "[4/6] 下载 README.md..."
$DOWNLOAD README.md "$MIRROR/README.md"

echo "[5/6] 下载 .gitattributes..."
$DOWNLOAD .gitattributes "$MIRROR/.gitattributes" || true

echo "[6/6] 下载 LICENSE..."
$DOWNLOAD LICENSE "$MIRROR/LICENSE" || true

cd ..

echo ""
echo "=========================================="
echo "✅ 模型下载完成！"
echo "=========================================="
echo ""
echo "文件位置: checkpoints/"
echo ""
echo "下一步："
echo "  cd ../.."
echo "  ./build.sh"
echo ""

