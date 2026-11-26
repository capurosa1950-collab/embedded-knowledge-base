@echo off
cd /d "%~dp0"

echo ============================================================
echo          Pushing Knowledge Base to GitHub
echo ============================================================
echo.
echo Current directory: %cd%
echo Executing: git push -u origin main
echo.

git push -u origin main

echo.
echo ============================================================
echo Execution finished. If prompted, please complete browser login.
echo ============================================================
echo.
pause
