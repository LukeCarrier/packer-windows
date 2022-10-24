@ECHO off

cmd.exe /c reg ^
    add HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell ^
    /v ExecutionPolicy ^
    /t REG_SZ ^
    /d RemoteSigned /f
