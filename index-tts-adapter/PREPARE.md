# 准备 index-tts 目录

## 🎯 目标

在构建 Docker 镜像之前，需要准备好 `index-tts` 目录（包含代码和模型文件）。

## 📦 两种准备方式

### 方式 1：在线下载（首次准备）

适合：有良好网络连接的环境

```bash
# 1. 克隆 index-tts 仓库
git clone https://github.com/index-tts/index-tts.git

# 2. 进入目录
cd index-tts

# 3. 初始化 Git LFS
git lfs install
git lfs pull

# 4. 下载模型文件（约 2-3GB）
pip install -U "huggingface-hub[cli]"

# 使用国内镜像（推荐）
export HF_ENDPOINT=https://hf-mirror.com  # Linux/Mac
# 或
set HF_ENDPOINT=https://hf-mirror.com     # Windows

# 下载模型（使用 Python 模块方式，避免 PATH 问题）
python -m huggingface_hub download IndexTeam/IndexTTS-2 --local-dir=checkpoints

# 如果上面的命令不工作，也可以尝试：
# huggingface-cli download IndexTeam/IndexTTS-2 --local-dir=checkpoints

# 5. 返回上级目录
cd ..
```

### 方式 2：离线部署（批量部署推荐）

适合：网络不稳定、需要批量部署、分发给其他用户

#### 步骤 A：在有网络的机器上准备

1. 使用方式 1 准备好 `index-tts` 目录
2. 打包整个 `index-tts-adapter` 目录：

```bash
# 返回到 index-tts-adapter 的上级目录
cd ..

# 打包（包含 index-tts 目录）
tar -czf index-tts-adapter-complete.tar.gz index-tts-adapter/

# 或者只打包 index-tts 目录
cd index-tts-adapter
tar -czf index-tts.tar.gz index-tts/
```

#### 步骤 B：分发到目标机器

1. 通过网盘、U盘或内网文件服务器分发压缩包
2. 在目标机器上解压：

```bash
# 如果是完整包
tar -xzf index-tts-adapter-complete.tar.gz

# 如果只是 index-tts 目录
cd index-tts-adapter
tar -xzf index-tts.tar.gz
```

## ✅ 验证目录结构

准备完成后，目录结构应该是：

```
index-tts-adapter/
├── index-tts/                    # ← 必须存在
│   ├── checkpoints/              # ← 模型文件目录
│   │   ├── config.yaml          # ← 必须存在
│   │   ├── model.pt
│   │   └── ...
│   ├── indextts/                # 源代码
│   ├── pyproject.toml
│   ├── uv.lock
│   └── ...
├── api_server.py
├── Dockerfile
├── build.bat
├── build.sh
└── requirements.txt
```

## 🔍 检查是否准备完成

运行以下命令检查：

**Windows:**
```cmd
dir index-tts\checkpoints\config.yaml
```

**Linux/Mac:**
```bash
ls -l index-tts/checkpoints/config.yaml
```

如果文件存在，说明准备完成！

## 🚀 下一步

准备完成后，运行构建脚本：

**Windows:**
```bash
build.bat          # RTX 40/30 系列
build-5090.bat     # RTX 50 系列
```

**Linux/Mac:**
```bash
./build.sh         # RTX 40/30 系列
./build-5090.sh    # RTX 50 系列
```

## ❓ 常见问题

### Q: 为什么不在 Dockerfile 中自动下载？

A: 因为：
1. 网络问题可能导致构建失败
2. 每次构建都要重新下载，浪费时间和带宽
3. 不利于批量部署和分发

### Q: 模型文件有多大？

A: 约 2-3GB

### Q: 可以使用其他版本的模型吗？

A: 可以，但需要确保模型文件放在 `index-tts/checkpoints/` 目录下，并且包含 `config.yaml`

### Q: 如何更新模型？

A: 删除 `index-tts/checkpoints/` 目录，重新下载即可

## 📝 提示

- 首次准备需要下载约 2-3GB 数据，请确保网络稳定
- 准备好的 `index-tts` 目录可以重复使用，不需要每次都下载
- 建议保存一份完整的压缩包，方便后续部署

