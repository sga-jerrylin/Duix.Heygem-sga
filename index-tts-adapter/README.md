# IndexTTS Adapter for Duix.Avatar

这是一个将 [IndexTTS](https://github.com/index-tts/index-tts) 适配到 Duix.Avatar 项目的适配器服务。

## 📋 功能说明

本适配器实现了与 `fish-speech-ziming` 兼容的 API 接口，使得 Duix.Avatar 项目可以无缝切换到 IndexTTS 作为 TTS 引擎。

### 优势

- ✅ **更好的音质**：IndexTTS-2 提供工业级的语音合成质量
- ✅ **情感控制**：支持多种情感表达（开心、愤怒、悲伤等）
- ✅ **零样本克隆**：只需少量参考音频即可克隆音色
- ✅ **多语言支持**：支持中文、英文等多种语言
- ✅ **无缝替换**：API 接口完全兼容，客户端代码无需修改

## 🚀 快速开始

### ⚠️ 重要：部署前准备

#### 1. 确定你的显卡型号

```bash
nvidia-smi
```

- **RTX 50 系列**（5090, 5080）→ 使用 5090 版本的脚本
- **RTX 40 系列**（4090, 4080, 4070）→ 使用标准版本的脚本
- **RTX 30 系列及更早**（3090, 3080）→ 使用标准版本的脚本

📖 **详细指南**: [GPU_SELECTION_GUIDE.md](../GPU_SELECTION_GUIDE.md)

#### 2. 准备 index-tts 目录（必须！）

**在构建 Docker 镜像之前，必须先准备好 `index-tts` 目录。**

##### 方式 A：在线下载（适合网络良好的环境）

```bash
# 进入 index-tts-adapter 目录
cd index-tts-adapter

# 克隆仓库
git clone https://github.com/index-tts/index-tts.git
cd index-tts
git lfs install
git lfs pull

# 下载模型（约 2-3GB）
pip install -U "huggingface-hub[cli]"
export HF_ENDPOINT=https://hf-mirror.com  # 国内镜像
python -m huggingface_hub download IndexTeam/IndexTTS-2 --local-dir=checkpoints
```

##### 方式 B：离线部署（推荐，适合批量部署）

1. 在一台有网络的机器上使用方式 A 准备好 `index-tts` 目录
2. 打包整个 `index-tts-adapter` 目录：
   ```bash
   tar -czf index-tts-adapter.tar.gz index-tts-adapter/
   ```
3. 分发到其他机器并解压即可使用

📖 **详细部署指南**: [DEPLOYMENT.md](DEPLOYMENT.md)

---

### 构建和启动

#### RTX 50 系列

**Windows:**
```bash
cd index-tts-adapter
build-5090.bat

cd ..\deploy
docker-compose -f docker-compose-indextts-5090.yml up -d
```

**Linux/Mac:**
```bash
cd index-tts-adapter
chmod +x build-5090.sh
./build-5090.sh

cd ../deploy
docker-compose -f docker-compose-indextts-5090.yml up -d
```

#### RTX 40/30 系列

**Windows:**
```bash
cd index-tts-adapter
build.bat

cd ..\deploy
docker-compose -f docker-compose-indextts.yml up -d
```

**Linux/Mac:**
```bash
cd index-tts-adapter
chmod +x build.sh
./build.sh

cd ../deploy
docker-compose -f docker-compose-indextts.yml up -d
```

### 查看日志

```bash
docker logs -f duix-avatar-tts
```

等待看到以下日志表示启动成功：
```
INFO:__main__:IndexTTS 模型初始化成功！
INFO:     Uvicorn running on http://0.0.0.0:8080
```

### 方式二：本地开发测试

如果你想在本地测试而不使用 Docker：

1. **安装依赖**

```bash
cd index-tts-adapter

# 安装 uv 包管理器
pip install -U uv

# 克隆 index-tts
git clone https://github.com/index-tts/index-tts.git
cd index-tts
git lfs install
git lfs pull

# 安装依赖
uv sync --all-extras

# 下载模型
uv tool install "huggingface-hub[cli,hf_xet]"
hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints

# 返回上级目录
cd ..

# 安装适配器依赖
pip install -r requirements.txt
```

2. **修改配置**

编辑 `api_server.py`，将路径修改为本地路径：

```python
DATA_ROOT = Path("D:/duix_avatar_data/voice/data")  # Windows
# 或
DATA_ROOT = Path("/path/to/duix_avatar_data/voice/data")  # Linux
```

3. **启动服务**

```bash
python api_server.py
```

## 📡 API 接口

### 1. 预处理接口

**端点**: `POST /v1/preprocess_and_tran`

**请求示例**:
```json
{
  "format": ".wav",
  "reference_audio": "origin_audio/test.wav",
  "lang": "zh"
}
```

**响应示例**:
```json
{
  "code": 0,
  "asr_format_audio_url": "origin_audio/test.wav",
  "reference_audio_text": "参考音频"
}
```

### 2. 音频合成接口

**端点**: `POST /v1/invoke`

**请求示例**:
```json
{
  "speaker": "uuid-here",
  "text": "你好，这是一段测试语音。",
  "format": "wav",
  "topP": 0.7,
  "max_new_tokens": 1024,
  "chunk_length": 100,
  "repetition_penalty": 1.2,
  "temperature": 0.7,
  "need_asr": false,
  "streaming": false,
  "is_fixed_seed": 0,
  "is_norm": 1,
  "reference_audio": "origin_audio/test.wav",
  "reference_text": "参考文本"
}
```

**响应**: 返回 WAV 格式的音频二进制数据

### 3. 健康检查

**端点**: `GET /health`

**响应示例**:
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

## 🔧 配置说明

### Docker 配置

在 `docker-compose-indextts.yml` 中可以调整以下配置：

```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=0  # 使用的 GPU 编号
  - HF_ENDPOINT=https://hf-mirror.com  # HuggingFace 镜像地址

volumes:
  - d:/duix_avatar_data/voice/data:/code/data  # 数据目录映射

deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1  # GPU 数量
          capabilities: [gpu]

shm_size: '8g'  # 共享内存大小
```

### 性能优化

在 `api_server.py` 中可以调整模型参数：

```python
tts_model = IndexTTS2(
    cfg_path="/code/index-tts/checkpoints/config.yaml",
    model_dir="/code/index-tts/checkpoints",
    use_fp16=True,  # 使用 FP16 精度（节省显存，略微降低质量）
    use_cuda_kernel=False,  # 是否使用 CUDA 内核加速
    use_deepspeed=False  # 是否使用 DeepSpeed 加速
)
```

## 🐛 故障排查

### 1. 模型加载失败

**问题**: 日志显示 "初始化 IndexTTS 模型失败"

**解决方案**:
- 检查 GPU 是否可用：`nvidia-smi`
- 检查 CUDA 版本是否兼容（需要 CUDA 12.1+）
- 检查模型文件是否完整下载

### 2. 音频文件找不到

**问题**: "参考音频不存在"

**解决方案**:
- 确保音频文件放在 `D:\duix_avatar_data\voice\data` 目录下
- 检查 docker-compose 中的卷映射是否正确
- 确保文件路径使用相对路径（相对于数据根目录）

### 3. 显存不足

**问题**: CUDA out of memory

**解决方案**:
- 在 `api_server.py` 中启用 `use_fp16=True`
- 减少 `shm_size` 大小
- 关闭其他占用 GPU 的程序

### 4. 下载速度慢

**问题**: 模型下载很慢

**解决方案**:
- 使用国内镜像：设置 `HF_ENDPOINT=https://hf-mirror.com`
- 或手动下载模型后放到 `checkpoints` 目录

## 📝 注意事项

1. **首次启动时间较长**：需要下载约 2-3GB 的模型文件
2. **GPU 要求**：需要 NVIDIA GPU，显存建议 8GB 以上
3. **音频格式**：参考音频建议使用 WAV 格式，采样率 16kHz 或 24kHz
4. **音频长度**：参考音频建议 3-10 秒，包含清晰的人声

## 🔄 切换回原始 TTS

如果需要切换回 fish-speech-ziming：

```bash
cd deploy
docker-compose -f docker-compose.yml up -d
```

## 📚 相关链接

- [IndexTTS GitHub](https://github.com/index-tts/index-tts)
- [IndexTTS 论文](https://arxiv.org/abs/2502.05512)
- [Duix.Avatar 项目](https://github.com/duixcom/Duix.Avatar)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本适配器遵循 MIT 许可证。IndexTTS 项目请参考其原始许可证。

