#!/bin/bash

echo "========================================"
echo "  IndexTTS Docker 镜像导出工具"
echo "========================================"
echo ""

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 创建导出目录
EXPORT_DIR="../deploy/docker-images"
mkdir -p "$EXPORT_DIR"

echo "📦 开始导出 Docker 镜像..."
echo ""

# 检查 RTX 50 系列镜像
if docker images duix-avatar-tts-indextts-5090:latest -q | grep -q .; then
    echo "[1/2] 导出 RTX 50 系列镜像 (duix-avatar-tts-indextts-5090:latest)..."
    docker save duix-avatar-tts-indextts-5090:latest -o "$EXPORT_DIR/duix-avatar-tts-5090.tar"
    if [ $? -eq 0 ]; then
        echo "✅ RTX 50 系列镜像导出成功"
        size=$(du -h "$EXPORT_DIR/duix-avatar-tts-5090.tar" | cut -f1)
        echo "   文件大小: $size"
    else
        echo "❌ RTX 50 系列镜像导出失败"
    fi
    echo ""
else
    echo "⚠️  未找到 RTX 50 系列镜像，跳过"
    echo ""
fi

# 检查 RTX 40 系列镜像
if docker images duix-avatar-tts-indextts:latest -q | grep -q .; then
    echo "[2/2] 导出 RTX 40 系列镜像 (duix-avatar-tts-indextts:latest)..."
    docker save duix-avatar-tts-indextts:latest -o "$EXPORT_DIR/duix-avatar-tts-4090.tar"
    if [ $? -eq 0 ]; then
        echo "✅ RTX 40 系列镜像导出成功"
        size=$(du -h "$EXPORT_DIR/duix-avatar-tts-4090.tar" | cut -f1)
        echo "   文件大小: $size"
    else
        echo "❌ RTX 40 系列镜像导出失败"
    fi
    echo ""
else
    echo "⚠️  未找到 RTX 40 系列镜像，跳过"
    echo ""
fi

# 复制配置文件
echo "📋 复制配置文件..."
cp -f ../deploy/docker-compose-indextts.yml "$EXPORT_DIR/"
cp -f ../deploy/docker-compose-indextts-5090.yml "$EXPORT_DIR/"
echo "✅ 配置文件复制完成"
echo ""

# 创建导入脚本
echo "📝 生成导入脚本..."
cat > "$EXPORT_DIR/import-and-deploy.sh" << 'EOF'
#!/bin/bash

echo "========================================"
echo "  IndexTTS Docker 镜像导入工具"
echo "========================================"
echo ""

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 检测显卡型号
echo "🔍 检测显卡型号..."
GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
echo "检测到显卡: $GPU_NAME"
echo ""

# 判断使用哪个镜像
IMAGE_FILE=""
COMPOSE_FILE=""
if echo "$GPU_NAME" | grep -qi "50"; then
    echo "📦 检测到 RTX 50 系列显卡，使用对应镜像"
    IMAGE_FILE="duix-avatar-tts-5090.tar"
    COMPOSE_FILE="docker-compose-indextts-5090.yml"
else
    echo "📦 检测到 RTX 40 系列显卡，使用对应镜像"
    IMAGE_FILE="duix-avatar-tts-4090.tar"
    COMPOSE_FILE="docker-compose-indextts.yml"
fi
echo ""

# 检查镜像文件是否存在
if [ ! -f "$IMAGE_FILE" ]; then
    echo "❌ 镜像文件不存在: $IMAGE_FILE"
    echo "请确保镜像文件在当前目录"
    exit 1
fi

# 导入镜像
echo "📥 导入 Docker 镜像..."
docker load -i "$IMAGE_FILE"
if [ $? -ne 0 ]; then
    echo "❌ 镜像导入失败"
    exit 1
fi
echo "✅ 镜像导入成功"
echo ""

# 启动服务
echo "🚀 启动服务..."
docker-compose -f "$COMPOSE_FILE" up -d
if [ $? -ne 0 ]; then
    echo "❌ 服务启动失败"
    exit 1
fi
echo "✅ 服务启动成功"
echo ""

echo "⏳ 等待模型加载（约 4 分钟）..."
sleep 240
echo ""

echo "📊 检查服务状态..."
docker logs duix-avatar-tts --tail 5
echo ""

echo "🔍 测试健康检查..."
curl http://127.0.0.1:18180/health
echo ""
echo ""

echo "========================================"
echo "  部署完成！"
echo "========================================"
echo "服务地址: http://127.0.0.1:18180"
echo "健康检查: http://127.0.0.1:18180/health"
echo "查看日志: docker logs -f duix-avatar-tts"
echo ""
EOF

chmod +x "$EXPORT_DIR/import-and-deploy.sh"
echo "✅ 导入脚本生成完成"
echo ""

# 创建 README
echo "📝 生成说明文档..."
cat > "$EXPORT_DIR/README.md" << 'EOF'
# IndexTTS Docker 镜像部署包

## 📦 包含文件

- `duix-avatar-tts-5090.tar` - RTX 50 系列镜像（5090, 5080）
- `duix-avatar-tts-4090.tar` - RTX 40 系列镜像（4090, 4080, 4070）
- `docker-compose-indextts-5090.yml` - RTX 50 系列配置
- `docker-compose-indextts.yml` - RTX 40 系列配置
- `import-and-deploy.sh` - 自动导入和部署脚本（Linux/Mac）
- `import-and-deploy.bat` - 自动导入和部署脚本（Windows）

## 🚀 使用方法

### 方法一：自动部署（推荐）

**Linux/Mac:**
```bash
cd docker-images
chmod +x import-and-deploy.sh
./import-and-deploy.sh
```

**Windows:**
```bash
cd docker-images
import-and-deploy.bat
```

脚本会自动：
1. 检测显卡型号
2. 导入对应镜像
3. 启动服务
4. 等待模型加载
5. 验证部署

### 方法二：手动部署

**RTX 50 系列（5090, 5080）：**
```bash
# 1. 导入镜像
docker load -i duix-avatar-tts-5090.tar

# 2. 启动服务
docker-compose -f docker-compose-indextts-5090.yml up -d

# 3. 查看日志
docker logs -f duix-avatar-tts
```

**RTX 40 系列（4090, 4080, 4070）：**
```bash
# 1. 导入镜像
docker load -i duix-avatar-tts-4090.tar

# 2. 启动服务
docker-compose -f docker-compose-indextts.yml up -d

# 3. 查看日志
docker logs -f duix-avatar-tts
```

## ✅ 验证部署

```bash
# 检查健康状态
curl http://127.0.0.1:18180/health

# 应该返回：{"status":"healthy","model_loaded":true}
```

## 📊 系统要求

- Docker 已安装并运行
- NVIDIA GPU 驱动已安装
- NVIDIA Container Toolkit 已安装
- 磁盘空间：约 10GB

## 🔧 常见问题

**Q: 导入镜像很慢？**
A: 镜像文件较大（5-6GB），请耐心等待

**Q: 服务启动后无法访问？**
A: 等待 4 分钟让模型加载完成，查看日志确认是否有 "IndexTTS 模型初始化成功！"

**Q: 如何查看日志？**
A: `docker logs -f duix-avatar-tts`

**Q: 如何重启服务？**
A: `docker restart duix-avatar-tts`

## 📞 技术支持

如有问题，请查看完整文档或联系技术支持。
EOF

echo "✅ 说明文档生成完成"
echo ""

echo "========================================"
echo "  导出完成！"
echo "========================================"
echo ""
echo "📁 导出目录: $EXPORT_DIR"
echo ""
echo "📦 包含文件:"
ls -lh "$EXPORT_DIR"
echo ""
echo "💡 下一步:"
echo "1. 将 $EXPORT_DIR 文件夹复制到新机器"
echo "2. 在新机器上运行 import-and-deploy.sh (Linux/Mac) 或 import-and-deploy.bat (Windows)"
echo "3. 等待约 4 分钟后服务即可使用"
echo ""

