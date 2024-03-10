. ../../scripts/utilities.ps1

Write-Host "Creating Certificates" -ForegroundColor DarkMagenta
Write-Host "Certificte Settings" -ForegroundColor DarkMagenta

$randomPwd = New-RandomPassword
$certPassword = Read-HostWithDefault -Message "Certificate Password" -DefaultValue $randomPwd -AsSecureString $true

$CertPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($certPassword))

docker compose `
    -f ../../docker/certs/docker-compose.yml run --rm `
    -v "$(pwd):/export" `
    -v "$(pwd)/scripts:/scripts" `
    -v "$(pwd)/dist:/dist" `
    -e "CERT_PASSWORD=$CertPwd"`
    create-certs

New-Directory -Path "../dist/certs"
Remove-Item -Path "../dist/certs" -Recurse -Force

Copy-Item -Path "./dist" -Destination "../dist/certs" -Recurse
Remove-Item -Path "./dist" -Recurse -Force

Write-Host "Certificates Created" -ForegroundColor DarkMagenta