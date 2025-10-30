@echo off
REM 直接下载 IndexTTS-2 模型文件（使用 curl）
REM 适用于 HuggingFace CLI 无法工作的情况

echo ==========================================
echo IndexTTS-2 模型直接下载脚本
echo ==========================================
echo.

REM 检查是否在 index-tts 目录
if not exist "indextts" (
    echo [错误] 请在 index-tts 目录下运行此脚本
    echo.
    echo 正确的位置：
    echo   index-tts-adapter\index-tts\
    echo.
    pause
    exit /b 1
)

REM 创建 checkpoints 目录
if not exist "checkpoints" mkdir checkpoints
cd checkpoints

echo 开始下载模型文件...
echo 使用国内镜像: hf-mirror.com
echo.

REM 设置镜像地址
set MIRROR=https://hf-mirror.com/IndexTeam/IndexTTS-2/resolve/main

echo [1/6] 下载 config.yaml...
curl -L -o config.yaml "%MIRROR%/config.yaml"
if %ERRORLEVEL% NEQ 0 (
    echo 下载失败！
    pause
    exit /b 1
)

echo [2/6] 下载 model.pt (主模型文件，约 2GB，请耐心等待)...
curl -L -o model.pt "%MIRROR%/model.pt"
if %ERRORLEVEL% NEQ 0 (
    echo 下载失败！
    pause
    exit /b 1
)

echo [3/6] 下载 vocab.txt...
curl -L -o vocab.txt "%MIRROR%/vocab.txt"
if %ERRORLEVEL% NEQ 0 (
    echo 下载失败！
    pause
    exit /b 1
)

echo [4/6] 下载 README.md...
curl -L -o README.md "%MIRROR%/README.md"
if %ERRORLEVEL% NEQ 0 (
    echo 下载失败！
    pause
    exit /b 1
)

echo [5/6] 下载 .gitattributes...
curl -L -o .gitattributes "%MIRROR%/.gitattributes"

echo [6/6] 下载 LICENSE...
curl -L -o LICENSE "%MIRROR%/LICENSE"

cd ..

echo.
echo ==========================================
echo ✅ 模型下载完成！
echo ==========================================
echo.
echo 文件位置: checkpoints\
echo.
echo 下一步：
echo   cd ..\..
echo   build.bat
echo.
pause

