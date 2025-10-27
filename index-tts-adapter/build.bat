@echo off
REM 构建 IndexTTS Adapter Docker 镜像 (RTX 40 系列 - Windows)

echo 开始构建 IndexTTS Adapter Docker 镜像 (RTX 40 系列)...

docker build -t duix-avatar-tts-indextts-4090:latest .

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ 镜像构建成功！
    echo.
    echo 使用以下命令启动服务：
    echo   cd ..\deploy
    echo   docker-compose -f docker-compose-indextts.yml up -d
) else (
    echo.
    echo ❌ 镜像构建失败，请检查错误信息
    exit /b 1
)

