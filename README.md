# Docker image for machine learning development

## Get started

```shell
# Git clone
git clone https://github.com/tatsy/docker-mlenv
cd docker-mlenv

# Please make sure to set the following IDs
export GID=$(id -g)
export UID=$(id -u)
export USERNAME="your_name"

# Build and run the Docker image
docker compose build  # Build the Docker image
docker compose up -d  # Run the container as a daemon

# Enter to the container
docker exec -it mlenv-app-your_name /usr/bin/zsh
```
