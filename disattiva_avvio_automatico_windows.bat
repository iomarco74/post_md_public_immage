@echo off
echo Rimozione avvio automatico all'accesso di Windows...
powershell.exe -NoLogo -ExecutionPolicy Bypass -Command "$startupPath = [Environment]::GetFolderPath('Startup'); $target = Join-Path $startupPath 'SyncGithubImages.lnk'; if (Test-Path $target) { Remove-Item $target -Force; Write-Host 'Avvio automatico disattivato con successo!' -ForegroundColor Green } else { Write-Host 'Nessun avvio automatico trovato.' -ForegroundColor Yellow }"
pause
