param(
    [string]$Name,
    [SecureString]$CertPassword
)

. ../../scripts/utilities.ps1

Write-Host "Adding Certificates" -ForegroundColor DarkMagenta

$CertPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($CertPassword))

$currentDir = Get-Location

docker compose `
    -f ../../docker/certs/docker-compose.yml run --rm `
    -v "$currentDir/dist:/export" `
    -v "$currentDir/scripts:/scripts" `
    -e "CERT_PASSWORD=$CertPwd" `
    -e "CERT_NAME=$Name" `
    create-certs /scripts/add-certs.sh

New-Directory -Path "../dist/certs/$Name"
Remove-Item -Path "../dist/certs/$Name" -Recurse -Force

Copy-Item -Path "./dist" -Destination "../dist/certs/$Name" -Recurse
Remove-Item -Path "./dist" -Recurse -Force

Write-Host "Certificates Added" -ForegroundColor DarkMagenta