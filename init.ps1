Write-Host "Initialize InnovateX" -ForegroundColor Green

. ./scripts/utilities.ps1

$name = Prompt-InputWithDefault -Message "Name" -DefaultValue "Caracal" 
$description = Prompt-InputWithDefault -Message "Description" -DefaultValue "Caracal is a simple and fast message orchestrator"
$version = Prompt-InputWithDefault -Message "Version" -DefaultValue "1.0.0"
$mqttBroker = Prompt-InputWithDefault -Message "MQTT Broker (solace|hive-mq)" -DefaultValue "solace"

$randomPwd = Generate-RandomPassword
$certPassword = Prompt-InputWithDefault -Message "Certificate Password" -DefaultValue $randomPwd -AsSecureString $true

Write-Host "Creating settings" -ForegroundColor Green

$secureCertPwd = $certPassword | ConvertFrom-SecureString

$jsonSettings = @"
{
    "name": "$name",
    "description": "$description",
    "version": "$version",
    "mqttBroker": "$mqttBroker",
    "certPassword": "$secureCertPwd"
}
"@

$jsonSettings | Out-File -FilePath "./build/config/settings.json" -Encoding utf8 -Force

$cnf = @"
APP_NAME=$name
APP_DESCRIPTION=$description
APP_VERSION=$version
MQTT_BROKER=$mqttBroker
"@

$cnf | Out-File -FilePath "./build/config/settings.cnf" -Encoding utf8 -Force

try
{
    cd ./build/certs
    ./create.ps1 -CertPassword $certPassword
}
catch
{
    Write-Host "Error creating certificates" -ForegroundColor Red
}
finally
{
    cd ../../
}

Write-Host "InnovateX initialized" -ForegroundColor Green