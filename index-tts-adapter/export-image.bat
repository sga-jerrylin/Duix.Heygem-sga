@echo off
chcp 65001 >nul
echo ========================================
echo   IndexTTS Docker 镜像导出工具
echo ========================================
echo.

REM 检查 Docker 是否运行
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker 未运行，请先启动 Docker Desktop
    pause
    exit /b 1
)

REM 创建导出目录
set EXPORT_DIR=..\deploy\docker-images
if not exist "%EXPORT_DIR%" mkdir "%EXPORT_DIR%"

echo 📦 开始导出 Docker 镜像...
echo.

REM 检查 RTX 50 系列镜像
docker images duix-avatar-tts-indextts-5090:latest -q >nul 2>&1
if %errorlevel% equ 0 (
    echo [1/2] 导出 RTX 50 系列镜像 (duix-avatar-tts-indextts-5090:latest)...
    docker save duix-avatar-tts-indextts-5090:latest -o "%EXPORT_DIR%\duix-avatar-tts-5090.tar"
    if %errorlevel% equ 0 (
        echo ✅ RTX 50 系列镜像导出成功
        for %%A in ("%EXPORT_DIR%\duix-avatar-tts-5090.tar") do (
            set size=%%~zA
            set /a sizeMB=!size! / 1048576
            echo    文件大小: !sizeMB! MB
        )
    ) else (
        echo ❌ RTX 50 系列镜像导出失败
    )
    echo.
) else (
    echo ⚠️  未找到 RTX 50 系列镜像，跳过
    echo.
)

REM 检查 RTX 40 系列镜像
docker images duix-avatar-tts-indextts:latest -q >nul 2>&1
if %errorlevel% equ 0 (
    echo [2/2] 导出 RTX 40 系列镜像 (duix-avatar-tts-indextts:latest)...
    docker save duix-avatar-tts-indextts:latest -o "%EXPORT_DIR%\duix-avatar-tts-4090.tar"
    if %errorlevel% equ 0 (
        echo ✅ RTX 40 系列镜像导出成功
        for %%A in ("%EXPORT_DIR%\duix-avatar-tts-4090.tar") do (
            set size=%%~zA
            set /a sizeMB=!size! / 1048576
            echo    文件大小: !sizeMB! MB
        )
    ) else (
        echo ❌ RTX 40 系列镜像导出失败
    )
    echo.
) else (
    echo ⚠️  未找到 RTX 40 系列镜像，跳过
    echo.
)

REM 复制配置文件
echo 📋 复制配置文件...
copy /Y ..\deploy\docker-compose-indextts.yml "%EXPORT_DIR%\" >nul
copy /Y ..\deploy\docker-compose-indextts-5090.yml "%EXPORT_DIR%\" >nul
echo ✅ 配置文件复制完成
echo.

REM 创建导入脚本
echo 📝 生成导入脚本...
(
echo @echo off
echo chcp 65001 ^>nul
echo echo ========================================
echo echo   IndexTTS Docker 镜像导入工具
echo echo ========================================
echo echo.
echo.
echo REM 检查 Docker 是否运行
echo docker info ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 ^(
echo     echo ❌ Docker 未运行，请先启动 Docker Desktop
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM 检测显卡型号
echo echo 🔍 检测显卡型号...
echo nvidia-smi --query-gpu=name --format=csv,noheader ^> gpu_info.txt
echo set /p GPU_NAME=^<gpu_info.txt
echo del gpu_info.txt
echo echo 检测到显卡: %%GPU_NAME%%
echo echo.
echo.
echo REM 判断使用哪个镜像
echo set IMAGE_FILE=
echo set COMPOSE_FILE=
echo echo %%GPU_NAME%% ^| findstr /i "50" ^>nul
echo if %%errorlevel%% equ 0 ^(
echo     echo 📦 检测到 RTX 50 系列显卡，使用对应镜像
echo     set IMAGE_FILE=duix-avatar-tts-5090.tar
echo     set COMPOSE_FILE=docker-compose-indextts-5090.yml
echo ^) else ^(
echo     echo 📦 检测到 RTX 40 系列显卡，使用对应镜像
echo     set IMAGE_FILE=duix-avatar-tts-4090.tar
echo     set COMPOSE_FILE=docker-compose-indextts.yml
echo ^)
echo echo.
echo.
echo REM 检查镜像文件是否存在
echo if not exist "%%IMAGE_FILE%%" ^(
echo     echo ❌ 镜像文件不存在: %%IMAGE_FILE%%
echo     echo 请确保镜像文件在当前目录
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM 导入镜像
echo echo 📥 导入 Docker 镜像...
echo docker load -i "%%IMAGE_FILE%%"
echo if %%errorlevel%% neq 0 ^(
echo     echo ❌ 镜像导入失败
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 镜像导入成功
echo echo.
echo.
echo REM 启动服务
echo echo 🚀 启动服务...
echo docker-compose -f "%%COMPOSE_FILE%%" up -d
echo if %%errorlevel%% neq 0 ^(
echo     echo ❌ 服务启动失败
echo     pause
echo     exit /b 1
echo ^)
echo echo ✅ 服务启动成功
echo echo.
echo.
echo echo ⏳ 等待模型加载（约 4 分钟）...
echo timeout /t 240 /nobreak ^>nul
echo echo.
echo.
echo echo 📊 检查服务状态...
echo docker logs duix-avatar-tts --tail 5
echo echo.
echo.
echo echo 🔍 测试健康检查...
echo curl http://127.0.0.1:18180/health
echo echo.
echo echo.
echo echo ========================================
echo echo   部署完成！
echo echo ========================================
echo echo 服务地址: http://127.0.0.1:18180
echo echo 健康检查: http://127.0.0.1:18180/health
echo echo 查看日志: docker logs -f duix-avatar-tts
echo echo.
echo pause
) > "%EXPORT_DIR%\import-and-deploy.bat"
echo ✅ 导入脚本生成完成
echo.

REM 创建 README
echo 📝 生成说明文档...
(
echo # IndexTTS Docker 镜像部署包
echo.
echo ## 📦 包含文件
echo.
echo - `duix-avatar-tts-5090.tar` - RTX 50 系列镜像（5090, 5080）
echo - `duix-avatar-tts-4090.tar` - RTX 40 系列镜像（4090, 4080, 4070）
echo - `docker-compose-indextts-5090.yml` - RTX 50 系列配置
echo - `docker-compose-indextts.yml` - RTX 40 系列配置
echo - `import-and-deploy.bat` - 自动导入和部署脚本
echo.
echo ## 🚀 使用方法
echo.
echo ### 方法一：自动部署（推荐）
echo.
echo 1. 将整个文件夹复制到新机器
echo 2. 双击运行 `import-and-deploy.bat`
echo 3. 脚本会自动检测显卡型号并导入对应镜像
echo 4. 等待约 4 分钟后服务即可使用
echo.
echo ### 方法二：手动部署
echo.
echo **RTX 50 系列（5090, 5080）：**
echo ```bash
echo # 1. 导入镜像
echo docker load -i duix-avatar-tts-5090.tar
echo.
echo # 2. 启动服务
echo docker-compose -f docker-compose-indextts-5090.yml up -d
echo.
echo # 3. 查看日志
echo docker logs -f duix-avatar-tts
echo ```
echo.
echo **RTX 40 系列（4090, 4080, 4070）：**
echo ```bash
echo # 1. 导入镜像
echo docker load -i duix-avatar-tts-4090.tar
echo.
echo # 2. 启动服务
echo docker-compose -f docker-compose-indextts.yml up -d
echo.
echo # 3. 查看日志
echo docker logs -f duix-avatar-tts
echo ```
echo.
echo ## ✅ 验证部署
echo.
echo ```bash
echo # 检查健康状态
echo curl http://127.0.0.1:18180/health
echo.
echo # 应该返回：{"status":"healthy","model_loaded":true}
echo ```
echo.
echo ## 📊 系统要求
echo.
echo - Docker Desktop 已安装并运行
echo - NVIDIA GPU 驱动已安装
echo - NVIDIA Container Toolkit 已安装
echo - 磁盘空间：约 10GB
echo.
echo ## 🔧 常见问题
echo.
echo **Q: 导入镜像很慢？**
echo A: 镜像文件较大（5-6GB），请耐心等待
echo.
echo **Q: 服务启动后无法访问？**
echo A: 等待 4 分钟让模型加载完成，查看日志确认是否有 "IndexTTS 模型初始化成功！"
echo.
echo **Q: 如何查看日志？**
echo A: `docker logs -f duix-avatar-tts`
echo.
echo **Q: 如何重启服务？**
echo A: `docker restart duix-avatar-tts`
echo.
echo ## 📞 技术支持
echo.
echo 如有问题，请查看完整文档或联系技术支持。
) > "%EXPORT_DIR%\README.md"
echo ✅ 说明文档生成完成
echo.

echo ========================================
echo   导出完成！
echo ========================================
echo.
echo 📁 导出目录: %EXPORT_DIR%
echo.
echo 📦 包含文件:
dir /b "%EXPORT_DIR%"
echo.
echo 💡 下一步:
echo 1. 将 %EXPORT_DIR% 文件夹复制到新机器
echo 2. 在新机器上运行 import-and-deploy.bat
echo 3. 等待约 4 分钟后服务即可使用
echo.
pause

