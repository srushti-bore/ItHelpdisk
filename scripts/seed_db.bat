@echo off
echo ==========================================
echo  Seeding IT Helpdesk Demo Database
echo ==========================================

cd /d %~dp0\..
python -m backend.db.seed
pause
