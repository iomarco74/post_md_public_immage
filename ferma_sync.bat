@echo off
echo Arresto del servizio di sincronizzazione in corso...
powershell.exe -NoLogo -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.Name -like 'powershell*' -and $_.CommandLine -like '*sync_watch.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Host 'Processo arrestato (PID: ' $_.ProcessId ')' -ForegroundColor Yellow }"
echo Servizio fermato.
pause
