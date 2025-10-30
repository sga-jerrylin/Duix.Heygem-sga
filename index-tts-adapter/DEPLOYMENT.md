# IndexTTS 部署指南

## 📦 准备工作

### 1. 准备 index-tts 目录（重要！）

在构建 Docker 镜像之前，必须先准备好 `index-tts` 目录。有两种方式：

#### 方式 A：在线下载（适合网络良好的环境）

```bash
# 进入 index-tts-adapter 目录
cd index-tts-adapter

# 克隆 index-tts 仓库
git clone https://github.com/index-tts/index-tts.git

# 进入目录并拉取 LFS 文件
cd index-tts
git lfs install
git lfs pull

# 下载模型文件（约 2-3GB）
pip install -U "huggingface-hub[cli]"
export HF_ENDPOINT=https://hf-mirror.com  # 使用国内镜像
python -m huggingface_hub download IndexTeam/IndexTTS-2 --local-dir=checkpoints

cd ..
```

#### 方式 B：离线部署（推荐，适合批量部署）

1. **在一台有网络的机器上准备好 index-tts 目录**（使用方式 A）

2. **打包整个目录**：
   ```bash
   # Windows
   tar -czf index-tts.tar.gz index-tts
   
   # Linux/Mac
   tar -czf index-tts.tar.gz index-tts/
   ```

3. **分发到其他机器**：
   - 将 `index-tts.tar.gz` 复制到目标机器的 `index-tts-adapter` 目录
   - 解压：`tar -xzf index-tts.tar.gz`

4. **或者直接复制整个 index-tts-adapter 目录**：
   ```bash
   # 打包整个 adapter 目录（包含 index-tts）
   tar -czf index-tts-adapter.tar.gz index-tts-adapter/
   
   # 在目标机器上解压即可使用
   tar -xzf index-tts-adapter.tar.gz
   ```

### 2. 验证目录结构

确保目录结构如下：

```
index-tts-adapter/
├── index-tts/                    # ← 必须存在
│   ├── checkpoints/              # ← 模型文件
│   │   ├── config.yaml
│   │   ├── model.pt
│   │   └── ...
│   ├── indextts/
│   ├── pyproject.toml
│   └── ...
├── api_server.py
├── Dockerfile
├── Dockerfile.5090
├── build.bat
├── build.sh
└── requirements.txt
```

## 🚀 构建和部署

### 步骤 1：构建 Docker 镜像

根据你的显卡型号选择对应的构建脚本：

#### RTX 40/30 系列（4090, 3090 等）

**Windows:**
```bash
cd index-tts-adapter
build.bat
```

**Linux/Mac:**
```bash
cd index-tts-adapter
chmod +x build.sh
./build.sh
```

#### RTX 50 系列（5090, 5080 等）

**Windows:**
```bash
cd index-tts-adapter
build-5090.bat
```

**Linux/Mac:**
```bash
cd index-tts-adapter
chmod +x build-5090.sh
./build-5090.sh
```

### 步骤 2：启动服务

#### RTX 40/30 系列

```bash
cd ../deploy
docker-compose -f docker-compose-indextts.yml up -d
```

#### RTX 50 系列

```bash
cd ../deploy
docker-compose -f docker-compose-indextts-5090.yml up -d
```

### 步骤 3：查看日志

```bash
docker logs -f duix-avatar-tts
```

等待看到以下日志表示启动成功：
```
INFO:__main__:IndexTTS 模型初始化成功！
INFO:     Uvicorn running on http://0.0.0.0:8080
```

### 步骤 4：测试服务

```bash
curl http://127.0.0.1:18180/health
```

预期响应：
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

## 🔧 配置数据目录

默认数据目录是 `d:/duix_avatar_data/voice/data`（Windows）。

如果需要修改，编辑 `deploy/docker-compose-indextts.yml`：

```yaml
services:
  duix-avatar-tts:
    volumes:
      - /your/custom/path:/code/data  # 修改这里
```

## 📝 常见问题

### Q1: 构建时提示 "未找到 index-tts 目录"

**原因**：没有准备 index-tts 目录

**解决**：按照上面的"准备工作"部分准备 index-tts 目录

### Q2: 构建时提示 "未找到模型文件"

**原因**：index-tts/checkpoints 目录为空

**解决**：
```bash
cd index-tts
pip install -U "huggingface-hub[cli]"
export HF_ENDPOINT=https://hf-mirror.com
python -m huggingface_hub download IndexTeam/IndexTTS-2 --local-dir=checkpoints
```

### Q3: 模型下载很慢或失败

**解决方案**：
1. 使用国内镜像：`export HF_ENDPOINT=https://hf-mirror.com`
2. 使用代理
3. 从其他已下载的机器复制 `index-tts/checkpoints` 目录

### Q4: 启动时报错 "CUDA out of memory"

**解决方案**：
1. 编辑 `api_server.py`，设置 `use_fp16=True`
2. 关闭其他占用 GPU 的程序

### Q5: 如何批量部署到多台机器？

**最佳实践**：
1. 在一台机器上准备好完整的 `index-tts-adapter` 目录（包含 index-tts）
2. 打包：`tar -czf index-tts-adapter-full.tar.gz index-tts-adapter/`
3. 分发到其他机器并解压
4. 直接运行构建脚本即可

## 🎯 快速部署清单

- [ ] 准备 index-tts 目录（克隆或解压）
- [ ] 下载模型文件到 index-tts/checkpoints
- [ ] 验证目录结构
- [ ] 运行构建脚本（build.bat 或 build.sh）
- [ ] 启动服务（docker-compose up -d）
- [ ] 查看日志确认启动成功
- [ ] 测试健康检查接口

## 📦 分发建议

如果需要分发给其他用户或部署到多台机器：

1. **准备完整包**：
   ```bash
   # 确保 index-tts 目录和模型都已准备好
   cd ..
   tar -czf index-tts-adapter-complete.tar.gz index-tts-adapter/
   ```

2. **分发方式**：
   - 网盘分享（推荐）
   - 内网文件服务器
   - U盘拷贝

3. **目标机器操作**：
   ```bash
   # 解压
   tar -xzf index-tts-adapter-complete.tar.gz
   
   # 构建
   cd index-tts-adapter
   ./build.sh  # 或 build.bat
   
   # 启动
   cd ../deploy
   docker-compose -f docker-compose-indextts.yml up -d
   ```

这样可以避免每台机器都需要从网络下载，大大提高部署效率！

