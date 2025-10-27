# IndexTTS 迁移指南

本指南将帮助你将 Duix.Avatar 项目的 TTS 引擎从 `fish-speech-ziming` 迁移到 `IndexTTS`。

## 📋 迁移概述

### 为什么要迁移到 IndexTTS？

- ✅ **更好的音质**：IndexTTS-2 提供工业级的语音合成质量
- ✅ **情感控制**：支持 8 种情感表达（开心、愤怒、悲伤、恐惧、厌恶、忧郁、惊讶、平静）
- ✅ **零样本克隆**：只需少量参考音频即可克隆音色
- ✅ **多语言支持**：支持中文、英文、日语、韩语等
- ✅ **持续更新**：IndexTTS 是 Bilibili 开源的活跃项目

### 迁移影响

- ✅ **客户端代码无需修改**：API 接口完全兼容
- ✅ **数据无需迁移**：使用相同的数据目录
- ⚠️ **首次启动较慢**：需要下载约 2-3GB 的模型文件
- ⚠️ **显存需求增加**：建议 8GB+ 显存（可通过 FP16 优化）

## 🚀 快速开始

### ⚠️ 重要：先确定你的显卡型号

在开始之前，请先确定你的显卡型号，不同显卡需要使用不同的配置文件：

```bash
nvidia-smi
```

- **RTX 50 系列**（5090, 5080 等）→ 使用 `docker-compose-indextts-5090.yml`
- **RTX 40 系列**（4090, 4080, 4070 等）→ 使用 `docker-compose-indextts.yml`
- **RTX 30 系列及更早**（3090, 3080, 2080 Ti 等）→ 使用 `docker-compose-indextts.yml`

📖 **详细的 GPU 选择指南**: 请查看 [GPU_SELECTION_GUIDE.md](GPU_SELECTION_GUIDE.md)

---

### 步骤 1: 停止现有服务

```bash
cd deploy
docker-compose down
```

### 步骤 2: 构建 IndexTTS 适配器镜像

#### RTX 50 系列（5090, 5080 等）

**Windows:**
```bash
cd ../index-tts-adapter
build-5090.bat
```

**Linux/Mac:**
```bash
cd ../index-tts-adapter
chmod +x build-5090.sh
./build-5090.sh
```

#### RTX 40/30 系列（4090, 3090 等）

**Windows:**
```bash
cd ../index-tts-adapter
build.bat
```

**Linux/Mac:**
```bash
cd ../index-tts-adapter
chmod +x build.sh
./build.sh
```

### 步骤 3: 启动新服务

#### RTX 50 系列

```bash
cd ../deploy
docker-compose -f docker-compose-indextts-5090.yml up -d
```

#### RTX 40/30 系列

```bash
cd ../deploy
docker-compose -f docker-compose-indextts.yml up -d
```

### 步骤 4: 查看日志

```bash
docker logs -f duix-avatar-tts
```

等待看到以下日志表示启动成功：
```
INFO:__main__:IndexTTS 模型初始化成功！
INFO:     Uvicorn running on http://0.0.0.0:8080
```

### 步骤 5: 测试服务

**健康检查:**
```bash
curl http://127.0.0.1:18180/health
```

**预期响应:**
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

## 🔧 配置优化

### 1. 显存优化（推荐）

如果你的 GPU 显存较小（< 8GB），可以启用 FP16 模式：

编辑 `index-tts-adapter/api_server.py`：
```python
tts_model = IndexTTS2(
    cfg_path="/code/index-tts/checkpoints/config.yaml",
    model_dir="/code/index-tts/checkpoints",
    use_fp16=True,  # 启用 FP16，节省约 50% 显存
    use_cuda_kernel=False,
    use_deepspeed=False
)
```

### 2. 加速推理（可选）

如果你想尝试加速推理，可以启用 CUDA 内核或 DeepSpeed：

```python
tts_model = IndexTTS2(
    cfg_path="/code/index-tts/checkpoints/config.yaml",
    model_dir="/code/index-tts/checkpoints",
    use_fp16=True,
    use_cuda_kernel=True,  # 启用 CUDA 内核加速
    use_deepspeed=True     # 启用 DeepSpeed 加速
)
```

⚠️ **注意**: 这些选项可能在某些系统上不稳定，请根据实际情况测试。

### 3. 多 GPU 支持

如果你有多个 GPU，可以在 `docker-compose-indextts.yml` 中指定：

```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=0,1  # 使用 GPU 0 和 1
```

### 4. 国内网络优化

如果下载模型很慢，可以使用国内镜像：

在 `docker-compose-indextts.yml` 中已经配置了：
```yaml
environment:
  - HF_ENDPOINT=https://hf-mirror.com
```

你也可以手动下载模型后挂载到容器：
```bash
# 下载模型到本地
mkdir -p ./checkpoints
cd ./checkpoints
# 使用 huggingface-cli 或浏览器下载 IndexTeam/IndexTTS-2

# 修改 docker-compose-indextts.yml，添加卷映射
volumes:
  - ./checkpoints:/code/index-tts/checkpoints
```

## 🧪 测试迁移

### 1. 测试音色训练

在 Duix.Avatar 客户端中：
1. 上传一段包含人声的视频（3-10 秒）
2. 创建新模特
3. 等待训练完成

### 2. 测试音频合成

1. 选择刚创建的模特
2. 输入文本："你好，这是一段测试语音。"
3. 点击"试听"
4. 检查生成的音频质量

### 3. 测试视频合成

1. 创建新视频项目
2. 选择模特和输入文本
3. 生成视频
4. 检查音视频同步效果

## 🐛 常见问题

### Q1: 启动时报错 "CUDA out of memory"

**解决方案:**
1. 启用 FP16 模式（见配置优化）
2. 关闭其他占用 GPU 的程序
3. 增加 Docker 的共享内存：`shm_size: '16g'`

### Q2: 模型下载失败

**解决方案:**
1. 检查网络连接
2. 使用国内镜像（见配置优化）
3. 手动下载模型文件

### Q3: 音频质量不如预期

**可能原因:**
1. 参考音频质量差（有噪音、回声等）
2. 参考音频太短（< 3 秒）或太长（> 10 秒）
3. 参考音频不包含清晰的人声

**解决方案:**
1. 使用高质量的参考音频（WAV 格式，16kHz 或 24kHz）
2. 确保参考音频长度在 3-10 秒之间
3. 使用包含清晰人声的音频

### Q4: 生成速度慢

**解决方案:**
1. 启用 FP16 模式
2. 尝试启用 CUDA 内核加速
3. 检查 GPU 利用率：`nvidia-smi`
4. 确保没有其他程序占用 GPU

### Q5: 想切换回原来的 TTS

**解决方案:**
```bash
cd deploy
docker-compose -f docker-compose-indextts.yml down
docker-compose -f docker-compose.yml up -d
```

## 📊 性能对比

| 指标 | fish-speech-ziming | IndexTTS-2 |
|------|-------------------|------------|
| 音质 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 情感表达 | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 音色克隆 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 生成速度 | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| 显存占用 | ~4GB | ~6GB (FP16) |
| 多语言支持 | ⭐⭐⭐ | ⭐⭐⭐⭐ |

## 🔄 回滚方案

如果迁移后遇到问题，可以快速回滚：

```bash
# 停止 IndexTTS 服务
cd deploy
docker-compose -f docker-compose-indextts.yml down

# 启动原来的服务
docker-compose -f docker-compose.yml up -d
```

数据不会丢失，因为两个服务使用相同的数据目录。

## 📚 进阶功能

### 情感控制（未来支持）

IndexTTS-2 支持情感控制，但当前适配器版本暂未实现。如果需要，可以扩展 API：

```python
# 在 api_server.py 中添加情感参数
tts_model.infer(
    spk_audio_prompt=str(reference_audio_path),
    text=request.text,
    output_path=output_path,
    emo_vector=[0, 0, 0.5, 0, 0, 0, 0, 0],  # 悲伤情感
    emo_alpha=0.6,
    verbose=False
)
```

### 多语言支持

IndexTTS-2 原生支持多语言，只需在文本中使用对应语言即可：

```python
# 中文
text = "你好，世界！"

# 英文
text = "Hello, world!"

# 混合
text = "你好，这是 English 和中文混合。"
```

## 🤝 获取帮助

- **IndexTTS 项目**: https://github.com/index-tts/index-tts
- **Duix.Avatar 项目**: https://github.com/duixcom/Duix.Avatar
- **问题反馈**: 在对应项目提交 Issue

## 📝 总结

迁移到 IndexTTS 可以显著提升语音合成质量，特别是在情感表达和音色克隆方面。虽然首次启动需要下载模型，但长期来看是值得的。

如果遇到任何问题，请参考本指南的故障排查部分，或在项目中提交 Issue。

祝你使用愉快！🎉

