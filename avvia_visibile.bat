@echo off
title GitHub Auto-Sync (post_md_public_immage)
echo Avvio sincronizzazione in tempo reale...
powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0sync_watch.ps1"
pause
