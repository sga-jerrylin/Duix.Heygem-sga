"""
IndexTTS Adapter Server
适配 fish-speech-ziming API 接口的 IndexTTS 服务器
"""
import os
import sys
import json
import logging
import tempfile
import uuid
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import Response, JSONResponse
from pydantic import BaseModel
import uvicorn

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 初始化 FastAPI
app = FastAPI(title="IndexTTS Adapter API", version="1.0.0")

# 全局变量存储 TTS 模型
tts_model = None
DATA_ROOT = Path("/code/data")  # Docker 容器内的数据目录


class PreprocessRequest(BaseModel):
    """预处理请求模型"""
    format: str
    reference_audio: str
    lang: str = "zh"


class InvokeRequest(BaseModel):
    """音频合成请求模型"""
    text: str
    speaker: Optional[str] = None
    format: str = "wav"
    topP: float = 0.7
    max_new_tokens: int = 1024
    chunk_length: int = 100
    repetition_penalty: float = 1.2
    temperature: float = 0.7
    need_asr: bool = False
    streaming: bool = False
    is_fixed_seed: int = 0
    is_norm: int = 1
    reference_audio: Optional[str] = None
    reference_text: Optional[str] = None
    emotion: str = "neutral"


def init_tts_model():
    """初始化 IndexTTS 模型"""
    global tts_model
    
    try:
        logger.info("正在初始化 IndexTTS 模型...")
        
        # 导入 IndexTTS
        sys.path.insert(0, '/code/index-tts')
        from indextts.infer_v2 import IndexTTS2
        
        # 初始化模型
        tts_model = IndexTTS2(
            cfg_path="/code/index-tts/checkpoints/config.yaml",
            model_dir="/code/index-tts/checkpoints",
            use_fp16=True,  # 使用 FP16 以节省显存
            use_cuda_kernel=False,
            use_deepspeed=False
        )
        
        logger.info("IndexTTS 模型初始化成功！")
        return True
        
    except Exception as e:
        logger.error(f"初始化 IndexTTS 模型失败: {e}")
        import traceback
        traceback.print_exc()
        return False


@app.on_event("startup")
async def startup_event():
    """应用启动时初始化模型"""
    success = init_tts_model()
    if not success:
        logger.error("模型初始化失败，服务可能无法正常工作")


@app.get("/")
async def root():
    """健康检查端点"""
    return {
        "status": "ok",
        "service": "IndexTTS Adapter",
        "model_loaded": tts_model is not None
    }


@app.post("/v1/preprocess_and_tran")
async def preprocess_and_tran(request: PreprocessRequest):
    """
    预处理和训练接口（兼容 fish-speech-ziming）
    
    这个接口在 fish-speech 中用于处理参考音频并提取特征。
    在 IndexTTS 中，我们不需要预处理，直接返回原始音频路径即可。
    """
    try:
        logger.info(f"收到预处理请求: {request.dict()}")
        
        # 构建完整的音频路径
        audio_path = DATA_ROOT / request.reference_audio
        
        # 检查文件是否存在
        if not audio_path.exists():
            logger.error(f"音频文件不存在: {audio_path}")
            return JSONResponse(
                status_code=400,
                content={
                    "code": -1,
                    "message": f"音频文件不存在: {request.reference_audio}"
                }
            )
        
        # IndexTTS 不需要预处理，直接返回原始路径
        # 这里我们可以使用 ASR 来提取文本，但为了简化，先返回空文本
        # 实际使用时，IndexTTS 会自动处理参考音频
        
        response_data = {
            "code": 0,
            "asr_format_audio_url": request.reference_audio,
            "reference_audio_text": "参考音频"  # IndexTTS 不需要文本，这里返回占位符
        }
        
        logger.info(f"预处理成功: {response_data}")
        return response_data
        
    except Exception as e:
        logger.error(f"预处理失败: {e}")
        import traceback
        traceback.print_exc()
        return JSONResponse(
            status_code=500,
            content={
                "code": -1,
                "message": f"预处理失败: {str(e)}"
            }
        )


@app.post("/v1/invoke")
async def invoke(request: InvokeRequest):
    """
    音频合成接口（兼容 fish-speech-ziming）

    使用 IndexTTS 生成音频
    """
    try:
        logger.info(f"收到音频合成请求: speaker={request.speaker}, text={request.text[:50]}...")

        if tts_model is None:
            raise HTTPException(status_code=503, detail="TTS 模型未初始化")

        # 处理参考音频路径
        reference_audio_path = None
        if request.reference_audio:
            reference_audio_path = DATA_ROOT / request.reference_audio
            if not reference_audio_path.exists():
                logger.error(f"参考音频不存在: {reference_audio_path}")
                raise HTTPException(status_code=400, detail=f"参考音频不存在: {request.reference_audio}")

        # 创建临时输出文件
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp_file:
            output_path = tmp_file.name

        try:
            # 使用 IndexTTS 生成音频
            if reference_audio_path:
                logger.info(f"开始生成音频，参考音频: {reference_audio_path}")
                tts_model.infer(
                    spk_audio_prompt=str(reference_audio_path),
                    text=request.text,
                    output_path=output_path,
                    verbose=False
                )
            else:
                # 使用默认说话人
                logger.info(f"开始生成音频，使用默认说话人")
                tts_model.infer(
                    text=request.text,
                    output_path=output_path,
                    verbose=False
                )
            
            # 读取生成的音频文件
            with open(output_path, 'rb') as f:
                audio_data = f.read()
            
            logger.info(f"音频生成成功，大小: {len(audio_data)} bytes")
            
            # 返回音频数据
            return Response(
                content=audio_data,
                media_type="audio/wav",
                headers={
                    "Content-Disposition": f"attachment; filename={request.speaker}.wav"
                }
            )
            
        finally:
            # 清理临时文件
            if os.path.exists(output_path):
                os.remove(output_path)
                
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"音频合成失败: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"音频合成失败: {str(e)}")


@app.get("/health")
async def health_check():
    """健康检查"""
    return {
        "status": "healthy",
        "model_loaded": tts_model is not None
    }


if __name__ == "__main__":
    # 启动服务器
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8080,
        log_level="info"
    )

