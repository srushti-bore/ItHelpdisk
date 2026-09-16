@echo off
echo ==========================================
echo  Starting IT Helpdesk Backend (FastAPI)
echo ==========================================

cd /d %~dp0\..\backend
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
