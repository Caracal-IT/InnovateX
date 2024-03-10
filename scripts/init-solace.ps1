Write-Host "Initialize Solace" -ForegroundColor DarkYellow

try
{
    Set-Location -Path $PWD/build/certs
    ./create.ps1
}
catch
{
    Write-Host "Error creating certificates" -ForegroundColor Red
}
finally {
    Set-Location -Path ../../
}

Write-Host "Solace initialized" -ForegroundColor DarkYellow