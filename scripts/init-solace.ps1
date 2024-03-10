Write-Host "Initialize Solace" -ForegroundColor DarkYellow

. ./scripts/utilities.ps1

try
{
    Set-Location -Path $PWD/build/certs
    ./create.ps1 -Name "dev.caracal.com"
    ./create.ps1 -Name "default-client"
    
    New-Directory -Path "./dist"
    Copy-Item -Path "../../build/dist/certs/default-client/ca.pem" -Destination "./dist/ca.pem"
    Copy-Item -Path "../../build/dist/certs/default-client/ca.key" -Destination "./dist/ca.key"

    $CertPassword = Get-Content -Path "../../build/dist/certs/default-client/credentials.bin" | ConvertTo-SecureString

    
    ./add-certs.ps1 -Name "mqtt-explorer" -CertPassword $CertPassword
}
catch
{
    Write-Host "Error creating certificates" -ForegroundColor Red
}
finally {
    Set-Location -Path ../../
}

Write-Host "Solace initialized" -ForegroundColor DarkYellow