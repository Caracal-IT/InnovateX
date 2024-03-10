Clear-Host
Write-Host "Initialize InnovateX" -ForegroundColor Green

. ./scripts/utilities.ps1

Write-Host "InnovateX Settings" -ForegroundColor Green

$name = Read-HostWithDefault -Message "Name" -DefaultValue "Caracal" 
$description = Read-HostWithDefault -Message "Description" -DefaultValue "Caracal is a simple and fast message orchestrator"
$version = Read-HostWithDefault -Message "Version" -DefaultValue "1.0.0"
$mqttBroker = Read-HostWithDefault -Message "MQTT Broker (solace|hive-mq)" -DefaultValue "solace"

Write-Host "Creating Settings" -ForegroundColor Green

$jsonSettings = @"
{
    "name": "$name",
    "description": "$description",
    "version": "$version",
    "mqttBroker": "$mqttBroker"
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

if($mqttBroker -eq "solace") {
    . ./scripts/init-solace.ps1
} elseif($mqttBroker -eq "hive-mq") {
    . ./scripts/init-hive-mq.ps1
} else {
    Write-Host "Invalid MQTT Broker" -ForegroundColor Red
    exit
}

Write-Host "InnovateX Initialized" -ForegroundColor Green