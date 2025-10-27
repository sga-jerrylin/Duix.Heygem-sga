# GPU 选择指南 - IndexTTS 适配器

本指南帮助你根据显卡型号选择正确的配置文件。

## 🎯 快速选择

### 如何查看你的显卡型号？

**Windows:**
```bash
nvidia-smi
```

**Linux:**
```bash
nvidia-smi
```

查看输出中的 GPU 名称，例如：
- `NVIDIA GeForce RTX 4090` → 使用 **RTX 40 系列配置**
- `NVIDIA GeForce RTX 5090` → 使用 **RTX 50 系列配置**
- `NVIDIA GeForce RTX 3090` → 使用 **RTX 40 系列配置**（向下兼容）

## 📋 配置文件对照表

| 显卡系列 | 型号示例 | Dockerfile | docker-compose 文件 | 构建脚本 |
|---------|---------|-----------|-------------------|---------|
| **RTX 50 系列** | 5090, 5080 | `Dockerfile.5090` | `docker-compose-indextts-5090.yml` | `build-5090.sh/bat` |
| **RTX 40 系列** | 4090, 4080, 4070 | `Dockerfile` | `docker-compose-indextts.yml` | `build.sh/bat` |
| **RTX 30 系列** | 3090, 3080, 3070 | `Dockerfile` | `docker-compose-indextts.yml` | `build.sh/bat` |
| **RTX 20 系列** | 2080 Ti, 2070 | `Dockerfile` | `docker-compose-indextts.yml` | `build.sh/bat` |

## 🚀 部署步骤

### RTX 50 系列（5090, 5080 等）

**特点：**
- 使用 CUDA 12.6
- 更大的共享内存（16GB）
- 针对 Blackwell 架构优化

**部署命令：**

**Windows:**
```bash
# 1. 构建镜像
cd index-tts-adapter
build-5090.bat

# 2. 启动服务
cd ..\deploy
docker-compose -f docker-compose-indextts-5090.yml up -d
```

**Linux/Mac:**
```bash
# 1. 构建镜像
cd index-tts-adapter
chmod +x build-5090.sh
./build-5090.sh

# 2. 启动服务
cd ../deploy
docker-compose -f docker-compose-indextts-5090.yml up -d
```

### RTX 40 系列（4090, 4080, 4070 等）

**特点：**
- 使用 CUDA 12.1
- 标准共享内存（8GB）
- 针对 Ada Lovelace 架构优化

**部署命令：**

**Windows:**
```bash
# 1. 构建镜像
cd index-tts-adapter
build.bat

# 2. 启动服务
cd ..\deploy
docker-compose -f docker-compose-indextts.yml up -d
```

**Linux/Mac:**
```bash
# 1. 构建镜像
cd index-tts-adapter
chmod +x build.sh
./build.sh

# 2. 启动服务
cd ../deploy
docker-compose -f docker-compose-indextts.yml up -d
```

### RTX 30 系列及更早（3090, 3080, 2080 Ti 等）

使用与 RTX 40 系列相同的配置（向下兼容）：

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

## 🔧 技术差异说明

### RTX 50 系列 vs RTX 40 系列

| 特性 | RTX 50 系列 | RTX 40 系列 |
|-----|-----------|-----------|
| **CUDA 版本** | 12.6 | 12.1 |
| **架构** | Blackwell | Ada Lovelace |
| **共享内存** | 16GB | 8GB |
| **CUDA 架构代码** | 9.0 | 8.9 |
| **优化选项** | `CUDA_MODULE_LOADING=LAZY` | 标准 |

### 为什么需要区分？

1. **CUDA 版本兼容性**：RTX 50 系列需要更新的 CUDA 版本
2. **架构优化**：不同架构的 GPU 有不同的优化策略
3. **内存管理**：RTX 50 系列支持更大的共享内存
4. **性能最优化**：使用匹配的配置可以获得最佳性能

## 📊 性能对比

### RTX 5090 (推荐配置)

- **显存**: 24GB+
- **推理速度**: ~0.5-1 秒/句（中文）
- **并发能力**: 高
- **推荐设置**: 
  - `use_fp16=True`
  - `shm_size=16g`

### RTX 4090 (推荐配置)

- **显存**: 24GB
- **推理速度**: ~0.8-1.5 秒/句（中文）
- **并发能力**: 中高
- **推荐设置**: 
  - `use_fp16=True`
  - `shm_size=8g`

### RTX 3090 (最低推荐)

- **显存**: 24GB
- **推理速度**: ~1-2 秒/句（中文）
- **并发能力**: 中
- **推荐设置**: 
  - `use_fp16=True` (必须)
  - `shm_size=8g`

## ⚠️ 常见问题

### Q1: 我用的是 RTX 3090，应该用哪个配置？

**答**: 使用 RTX 40 系列的配置（`docker-compose-indextts.yml`），它向下兼容。

### Q2: 我不确定我的显卡是哪个系列？

**答**: 运行 `nvidia-smi` 查看显卡型号：
- 型号以 50 开头（如 5090）→ RTX 50 系列
- 型号以 40 开头（如 4090）→ RTX 40 系列
- 型号以 30 开头（如 3090）→ RTX 30 系列

### Q3: 我用错了配置会怎样？

**答**: 
- 如果 RTX 50 用了 40 的配置：可能无法启动或性能不佳
- 如果 RTX 40 用了 50 的配置：可能无法启动（CUDA 版本不匹配）

### Q4: 我有多张不同型号的显卡怎么办？

**答**: 
1. 使用最新型号对应的配置
2. 在 docker-compose 中指定使用哪张显卡：
   ```yaml
   environment:
     - NVIDIA_VISIBLE_DEVICES=0  # 使用第一张显卡
   ```

### Q5: 如何切换配置？

**答**:
```bash
# 停止当前服务
docker-compose -f docker-compose-indextts.yml down

# 启动新配置
docker-compose -f docker-compose-indextts-5090.yml up -d
```

## 🔍 验证部署

部署完成后，验证服务是否正常：

```bash
# 查看日志
docker logs -f duix-avatar-tts

# 健康检查
curl http://127.0.0.1:18180/health

# 预期输出
{
  "status": "healthy",
  "model_loaded": true
}
```

## 📚 相关文档

- [完整迁移指南](INDEXTTS_MIGRATION_GUIDE.md)
- [适配器使用文档](index-tts-adapter/README.md)
- [原项目 GPU 配置](deploy/docker-compose-5090.yml)

## 💡 性能优化建议

### 所有显卡通用

1. **启用 FP16**：在 `api_server.py` 中设置 `use_fp16=True`
2. **关闭其他 GPU 程序**：确保 GPU 资源充足
3. **监控显存使用**：使用 `nvidia-smi` 监控

### RTX 50 系列专属

1. **增加共享内存**：已在配置中设置为 16GB
2. **启用延迟加载**：已设置 `CUDA_MODULE_LOADING=LAZY`
3. **考虑多 GPU**：如果有多张 5090，可以配置负载均衡

### RTX 40/30 系列

1. **必须启用 FP16**：否则可能显存不足
2. **适当降低批处理大小**：如果遇到 OOM 错误
3. **监控温度**：长时间运行注意散热

## 🎉 总结

选择正确的配置文件对于获得最佳性能至关重要。如有疑问，请参考本指南或在项目中提交 Issue。

祝你使用愉快！

