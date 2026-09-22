# ==============================================================================
# Script di sincronizzazione automatica in tempo reale con GitHub
# Monitora la cartella ed effettua commit & push automatici
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

# Rimuovi eventuali vecchie sottoscrizioni di eventi
Get-EventSubscriber -SourceIdentifier "Fs*" -ErrorAction SilentlyContinue | Unregister-Event -Force -ErrorAction SilentlyContinue
Get-Event -SourceIdentifier "Fs*" -ErrorAction SilentlyContinue | Remove-Event -ErrorAction SilentlyContinue

# Inizializza FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $targetDir
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher 'Created' -SourceIdentifier "FsCreated" | Out-Null
Register-ObjectEvent $watcher 'Changed' -SourceIdentifier "FsChanged" | Out-Null
Register-ObjectEvent $watcher 'Deleted' -SourceIdentifier "FsDeleted" | Out-Null
Register-ObjectEvent $watcher 'Renamed' -SourceIdentifier "FsRenamed" | Out-Null

$needsSync = $false
$lastChangeTime = [DateTime]::MinValue

Log-Message "Pronto. Ogni file aggiunto, modificato o rimosso verra' inviato a GitHub entro $debounceSeconds secondi." "Green"

try {
    while ($true) {
        try {
            Start-Sleep -Milliseconds 800

            # Raccoglie tutti gli eventi del FileSystem
            $events = Get-Event -SourceIdentifier "Fs*" -ErrorAction SilentlyContinue
            if ($events) {
                foreach ($evt in $events) {
                    $path = $evt.SourceEventArgs.FullPath
                    Remove-Event -EventIdentifier $evt.EventIdentifier -ErrorAction SilentlyContinue
                    
                    # Ignora cartella .git, file di log e temporanei
                    if ($path -and ($path -match "\\\.git(\\|$)" -or $path -match "\\sync_watch\.log$" -or $path -match "\.tmp$" -or $path -match "\.crdownload$")) {
                        continue
                    }

                    $needsSync = $true
                    $lastChangeTime = [DateTime]::UtcNow
                }
            }

            # Quando sono passati almeno $debounceSeconds dall'ultima modifica
            if ($needsSync) {
                $elapsed = ([DateTime]::UtcNow - $lastChangeTime).TotalSeconds
                if ($elapsed -ge $debounceSeconds) {
                    $needsSync = $false

                    Set-Location $targetDir
                    $status = git status --porcelain

                    if ($status) {
                        $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        Log-Message "Modifiche rilevate. Sincronizzazione in corso..." "Yellow"

                        # 1. Pull per evitare conflitti con modifiche remote
                        git pull --rebase origin main 2>&1 | Out-Null

                        # 2. Add
                        git add .

                        # 3. Commit
                        $commitMsg = "Auto-sync: $ts"
                        git commit -m $commitMsg 2>&1 | Out-Null

                        # 4. Push
                        $pushResult = git push origin main 2>&1
                        if ($LASTEXITCODE -eq 0) {
                            Log-Message "Sincronizzato con successo su GitHub!" "Green"
                        } else {
                            Log-Message "Errore durante il push su GitHub:`n$pushResult" "Red"
                        }
                    }
                }
            }
        }
        catch {
            Log-Message "Eccezione intercettata nel ciclo di monitoraggio: $_" "Red"
            Start-Sleep -Seconds 2
        }
    }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Get-EventSubscriber -SourceIdentifier "Fs*" -ErrorAction SilentlyContinue | Unregister-Event -Force -ErrorAction SilentlyContinue
    Get-Event -SourceIdentifier "Fs*" -ErrorAction SilentlyContinue | Remove-Event -ErrorAction SilentlyContinue
    Log-Message "=== Servizio di Sincronizzazione Fermato ===" "Cyan"
}
