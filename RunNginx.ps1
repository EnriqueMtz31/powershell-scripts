Set-Location C:/nginx-1.20.1
Write-Host "Current location/directory: " -NoNewline
Write-Host (Get-Location) "`n" -ForegroundColor Cyan
Write-Host "nginx.exe will be executed. " -NoNewline
Write-Host "Feel free to start coding once the nginx version prompts.`n" -BackgroundColor DarkYellow -ForegroundColor Black
Write-Host "Before you begin, keep in mind these following commands to run for nginx:"
Write-Host "nginx -s stop		fast shutdown
nginx -s quit		graceful shutdown
nginx -s reload		changing config, starting new worker processes w/new config, etc.
nginx -s reopen		re-opening log files `n"

Write-Host "Happy coding :)`n" -ForegroundColor Green
.\\nginx.exe -v
.\\nginx.exe
