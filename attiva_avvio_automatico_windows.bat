@echo off
echo Configurazione avvio automatico all'accesso di Windows...
powershell.exe -NoLogo -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $startupPath = [Environment]::GetFolderPath('Startup'); $shortcut = $ws.CreateShortcut((Join-Path $startupPath 'SyncGithubImages.lnk')); $shortcut.TargetPath = (Join-Path '%~dp0' 'avvia_background.vbs'); $shortcut.WorkingDirectory = '%~dp0'; $shortcut.Save(); Write-Host 'Collegamento creato con successo in Esecuzione automatica!' -ForegroundColor Green"
pause
