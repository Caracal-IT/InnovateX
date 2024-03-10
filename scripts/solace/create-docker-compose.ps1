New-Directory -Path "../../docker/main"

$dockerComposeContent = @"
version: '3.8'
name: 'innovate-x'
services:
    solace:
        container_name: solace
        image: solace/solace-pubsub-standard:latest
        shm_size: 1g
        ulimits:
          core: -1
          nofile:
            soft: 2448
            hard: 6592
        deploy:
          restart_policy:
            condition: on-failure
            max_attempts: 1
        working_dir: /usr/sw
        ports:
            - '1883:1883'
        environment:
            - username_admin_globalaccesslevel=admin
            - username_admin_password=admin
            - system_scaling_maxconnectioncount=100
            - username=admin
            - password=admin    
"@

# Write content to the file
$dockerComposeContent | Out-File -FilePath docker/main/docker-compose.yml -Encoding UTF8