#!/usr/bin/env bash
set -e

echo "=========================================="
echo " Starting IT Helpdesk Backend (FastAPI)"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../backend"
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
