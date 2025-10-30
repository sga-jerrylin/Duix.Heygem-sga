#!/usr/bin/env python3
"""
IndexTTS-2 模型下载脚本
用于下载 IndexTTS-2 模型到 checkpoints 目录
"""

import os
import sys
from pathlib import Path

try:
    from huggingface_hub import snapshot_download
except ImportError:
    print("错误：未安装 huggingface_hub")
    print("请先运行：pip install -U 'huggingface-hub[cli]'")
    sys.exit(1)

def main():
    # 设置镜像（国内用户推荐）
    use_mirror = input("是否使用国内镜像？(Y/n): ").strip().lower()
    if use_mirror != 'n':
        os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
        print("✓ 使用国内镜像: https://hf-mirror.com")
    
    # 确定下载目录
    script_dir = Path(__file__).parent
    checkpoints_dir = script_dir / "checkpoints"
    
    print("\n" + "="*50)
    print("IndexTTS-2 模型下载")
    print("="*50)
    print(f"下载目录: {checkpoints_dir.absolute()}")
    print("模型大小: 约 2-3GB")
    print("="*50)
    print()
    
    try:
        print("开始下载...")
        snapshot_download(
            repo_id="IndexTeam/IndexTTS-2",
            local_dir=str(checkpoints_dir),
            local_dir_use_symlinks=False,
            resume_download=True
        )
        
        print("\n" + "="*50)
        print("✅ 下载完成！")
        print("="*50)
        
        # 验证关键文件
        config_file = checkpoints_dir / "config.yaml"
        if config_file.exists():
            print(f"✓ 配置文件已就绪: {config_file}")
        else:
            print(f"⚠ 警告：未找到 config.yaml")
        
        print("\n下一步：")
        print("  cd ..")
        print("  build.bat  (Windows) 或 ./build.sh (Linux/Mac)")
        
    except KeyboardInterrupt:
        print("\n\n下载已取消")
        print("提示：下次运行会自动续传")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 下载失败: {e}")
        print("\n可能的解决方案：")
        print("1. 检查网络连接")
        print("2. 使用代理或 VPN")
        print("3. 使用国内镜像（重新运行脚本并选择 Y）")
        print("4. 尝试使用 Git 方式：")
        print("   git clone https://hf-mirror.com/IndexTeam/IndexTTS-2 checkpoints")
        sys.exit(1)

if __name__ == "__main__":
    main()

