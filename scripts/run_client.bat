@echo off
echo ==========================================
echo  Launching Flutter Client (Web / Chrome)
echo ==========================================

cd /d %~dp0\..\client
flutter run -d chrome
pause
