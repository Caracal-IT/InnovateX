param(
    [string]$Name
)

. ../../scripts/utilities.ps1

Write-Host "Creating Certificates" -ForegroundColor DarkMagenta
Write-Host "Certificte Settings" -ForegroundColor DarkMagenta

$randomPwd = New-RandomPassword
$certPassword = Read-HostWithDefault -Message "Certificate Password" -DefaultValue $randomPwd -AsSecureString $true

$CertPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($certPassword))

$currentDir = Get-Location

docker compose `
    -f ../../docker/certs/docker-compose.yml run --rm `
    -v "$currentDir/dist:/export" `
    -v "$currentDir/scripts:/scripts" `
    -v "$currentDir/dist:/dist" `
    -e "CERT_PASSWORD=$CertPwd" `
    -e "CERT_NAME=$Name" `
    create-certs /scripts/start.sh

New-Directory -Path "../dist/certs/$Name"
Remove-Item -Path "../dist/certs/$Name" -Recurse -Force

$certPassword | ConvertFrom-SecureString | out-file "./dist/credentials.bin"
Copy-Item -Path "./dist/" -Destination "../dist/certs/$Name/" -Recurse
Remove-Item -Path "./dist" -Recurse -Force

Write-Host "Certificates Created" -ForegroundColor DarkMagenta