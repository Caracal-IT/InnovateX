Write-Host "Initialize Solace" -ForegroundColor DarkYellow

. ./scripts/utilities.ps1

try
{
    ./scripts/solace/create-certs.ps1
    ./scripts/solace/create-docker-compose.ps1
}
catch
{
    Write-Host "Error Initializing" -ForegroundColor Red
    throw
}

Write-Host "Solace Initialized" -ForegroundColor DarkYellow