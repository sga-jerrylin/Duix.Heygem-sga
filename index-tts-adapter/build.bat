@echo off
REM 构建 IndexTTS Adapter Docker 镜像 (RTX 40 系列 - Windows)

echo ==========================================
echo IndexTTS Adapter 构建脚本 (RTX 40 系列)
echo ==========================================
echo.

REM 检查 index-tts 目录是否存在
if not exist "index-tts" (
    echo [错误] 未找到 index-tts 目录！
    echo.
    echo 请先准备 index-tts 目录：
    echo.
    echo 方式 1：从 GitHub 克隆（需要网络）
    echo   git clone https://github.com/index-tts/index-tts.git
    echo   cd index-tts
    echo   git lfs install
    echo   git lfs pull
    echo.
    echo 方式 2：从已准备好的压缩包解压
    echo   将 index-tts 目录解压到当前目录
    echo.
    echo 目录结构应该是：
    echo   index-tts-adapter\
    echo   ├── index-tts\
    echo   │   ├── checkpoints\     (模型文件)
    echo   │   ├── indextts\
    echo   │   └── ...
    echo   └── Dockerfile
    echo.
    pause
    exit /b 1
)

REM 检查模型文件是否存在
if not exist "index-tts\checkpoints\config.yaml" (
    echo [警告] 未找到模型文件！
    echo.
    echo 模型文件应该在: index-tts\checkpoints\
    echo.
    echo 下载模型：
    echo   cd index-tts
    echo   pip install -U "huggingface-hub[cli]"
    echo   set HF_ENDPOINT=https://hf-mirror.com
    echo   huggingface-cli download IndexTeam/IndexTTS-2 --local-dir=checkpoints
    echo.
    echo 是否继续构建？(Y/N)
    set /p CONFIRM=
    if /i not "%CONFIRM%"=="Y" (
        echo 已取消构建
        exit /b 1
    )
)

echo [✓] index-tts 目录检查通过
echo.
echo 开始构建 Docker 镜像...
echo.

docker build -t duix-avatar-tts-indextts-4090:latest .

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================
    echo ✅ 镜像构建成功！
    echo ==========================================
    echo.
    echo 下一步：
    echo   cd ..\deploy
    echo   docker-compose -f docker-compose-indextts.yml up -d
    echo.
) else (
    echo.
    echo ==========================================
    echo ❌ 镜像构建失败
    echo ==========================================
    echo.
    echo 常见问题：
    echo 1. index-tts 目录不完整
    echo 2. Docker 服务未启动
    echo 3. 磁盘空间不足
    echo.
    exit /b 1
)

