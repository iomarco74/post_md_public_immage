Set WshShell = CreateObject("WScript.Shell")
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
psCommand = "powershell.exe -NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & scriptDir & "\sync_watch.ps1"""
WshShell.Run psCommand, 0, False
