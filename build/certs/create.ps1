Write-Host "Creating certificates"

docker compose `
    -f ../../docker/certs/docker-compose.yml run --rm `
    -v "$(pwd):/export" `
    -v "$(pwd)/scripts:/scripts" `
    create-certs