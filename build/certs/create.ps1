param (
    [SecureString]$CertPassword
)

Write-Host "Creating certificates" -ForegroundColor DarkMagenta

$CertPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($CertPassword))

docker compose `
    -f ../../docker/certs/docker-compose.yml run --rm `
    -v "$(pwd):/export" `
    -v "$(pwd)/scripts:/scripts" `
    -e "CERT_PASSWORD=$CertPwd"`
    create-certs

Write-Host "Certificates Created" -ForegroundColor DarkMagenta