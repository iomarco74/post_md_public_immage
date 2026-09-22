# ==============================================================================
# Script di sincronizzazione automatica in tempo reale con GitHub
# Cartella monitorata: cartella corrente dello script
# ==============================================================================

$targetDir = $PSScriptRoot
Set-Location $targetDir

$logFile = Join-Path $targetDir "sync_watch.log"
$debounceSeconds = 3

function Log-Message {
    param([string]$message, [string]$color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formatted = "[$timestamp] $message"
    Write-Host $formatted -ForegroundColor $color
    Add-Content -Path $logFile -Value $formatted -Encoding utf8 -ErrorAction SilentlyContinue
}

Log-Message "=== Servizio di Sincronizzazione Avviato ===" "Cyan"
Log-Message "Monitoraggio attivo su: $targetDir" "Cyan"

# Inizializza FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $targetDir
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$script:needsSync = $false
$script:lastEventTime = [DateTime]::MinValue

$changeHandler = {
    param($sender, $eventArgs)
    $path = $eventArgs.FullPath
    
    # Ignora file git, log, o temporanei
    if ($path -match "\\\.git" -or $path -match "\\sync_watch\.log$" -or $path -match "\.tmp$" -or $path -match "\.crdownload$") {
        return
    }

    $script:needsSync = $true
    $script:lastEventTime = [DateTime]::UtcNow
}

Register-ObjectEvent $watcher 'Created' -Action $changeHandler | Out-Null
Register-ObjectEvent $watcher 'Changed' -Action $changeHandler | Out-Null
Register-ObjectEvent $watcher 'Deleted' -Action $changeHandler | Out-Null
Register-ObjectEvent $watcher 'Renamed' -Action $changeHandler | Out-Null

Log-Message "Pronto. Ogni file aggiunto o modificato verrà inviato a GitHub entro $debounceSeconds secondi." "Green"

# Loop di monitoraggio e sync
try {
    while ($true) {
        Start-Sleep -Milliseconds 1000

        if ($script:needsSync) {
            $elapsed = ([DateTime]::UtcNow - $script:lastEventTime).TotalSeconds
            if ($elapsed -ge $debounceSeconds) {
                $script:needsSync = $false
                
                Set-Location $targetDir
                $status = git status --porcelain
                
                if ($status) {
                    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Log-Message "Modifiche rilevate. Avvio sincronizzazione..." "Yellow"

                    # 1. Pull remoto per prevenire divergenze
                    git pull --rebase origin main 2>&1 | Out-Null

                    # 2. Add
                    git add .

                    # 3. Commit
                    $commitMsg = "Auto-sync: $ts"
                    git commit -m $commitMsg 2>&1 | Out-Null

                    # 4. Push
                    $pushOutput = git push origin main 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Log-Message "Sincronizzazione completata con successo!" "Green"
                    } else {
                        Log-Message "Attenzione: errore durante git push:`n$pushOutput" "Red"
                    }
                }
            }
        }
    }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Log-Message "=== Servizio di Sincronizzazione Fermato ===" "Cyan"
}
