@echo off
REM 构建 IndexTTS Adapter Docker 镜像 (RTX 50 系列 - Windows)

echo ==========================================
echo IndexTTS Adapter 构建脚本 (RTX 50 系列)
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
    pause
    exit /b 1
)

REM 检查模型文件
if not exist "index-tts\checkpoints\config.yaml" (
    echo [警告] 未找到模型文件！
    echo 是否继续构建？(Y/N)
    set /p CONFIRM=
    if /i not "%CONFIRM%"=="Y" (
        exit /b 1
    )
)

echo [✓] index-tts 目录检查通过
echo.
echo 开始构建 Docker 镜像 (RTX 50 系列)...
echo.

docker build -f Dockerfile.5090 -t duix-avatar-tts-indextts-5090:latest .

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================
    echo ✅ 镜像构建成功！
    echo ==========================================
    echo.
    echo 下一步：
    echo   cd ..\deploy
    echo   docker-compose -f docker-compose-indextts-5090.yml up -d
    echo.
) else (
    echo.
    echo ❌ 镜像构建失败，请检查错误信息
    exit /b 1
)

