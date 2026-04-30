"""
Script to start the FastAPI server
"""
import os
import sys

# Get the actual backend directory FIRST
backend_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, backend_dir)

# Load .env file
from dotenv import load_dotenv
env_path = os.path.join(backend_dir, '.env')
load_dotenv(env_path)

print(f"[OK] Backend directory: {backend_dir}")
print(f"[OK] DATABASE_URL loaded: {os.getenv('DATABASE_URL', 'NOT FOUND')[:50]}...")

# Start uvicorn
import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        reload_dirs=[os.path.join(backend_dir, "app")],
    )
