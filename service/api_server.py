import os
import sys
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# --- 环境路径设置 ---
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)
    print(f"项目根目录: {PROJECT_ROOT}")

# 导入路由
# 注意：确保 api_chat.py 和 api_report.py 文件保存无误
from service.API.api_chat import router as chat_router
from service.API.api_report import router as report_router

# --- FastAPI 应用定义 ---
# 只定义一次 app
app = FastAPI(title="MedSynthAI Inquiry API")

# 1. 配置 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 2. 注册路由
# 显式打印，确保执行
print("正在注册路由: /api/chat ...")
app.include_router(chat_router)
app.include_router(report_router)

# 3. 启动服务
if __name__ == "__main__":
    print("启动 MedSynthAI API 服务...")
    
    # [调试] 打印所有已注册的路由
    print("\n[DEBUG] 已注册的路由列表:")
    for route in app.routes:
        methods = getattr(route, "methods", None)
        print(f"  - Path: {route.path:<20} | Methods: {methods}")
    print("-" * 50 + "\n")

    # 运行服务
    uvicorn.run(app, host="0.0.0.0", port=8000)