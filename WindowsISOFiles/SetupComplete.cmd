@echo off
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass "%WINDIR%\Setup\Files\post.ps1"
rd /q /s "%WINDIR%\Setup\Files"
del /q /f "%0"
