#!/bin/bash
set -e

# Run FastAPI with environment variables for host and port
#uvicorn api.app:app --host 0.0.0.0 --port 8000 --root-path /$SERVICE_NAME
uvicorn api.app:app --host 0.0.0.0 --port 8000 
