# Run locally compose
docker-compose up

# Create image
docker build -t composesample .

#Tag image
docker tag composesample ($registry.LoginServer + '/composesample:v1')

#Push image
docker push ($registry.LoginServer + '/composesample:v1')

# Add Settings 
# DOCKER_REGISTRY_SERVER_URL
$registryName | Clip
# DOCKER_REGISTRY_SERVER_USERNAME
$registry.LoginServer | Clip
# DOCKER_REGISTRY_SERVER_PASSWORD
$credentials.Password | Clip