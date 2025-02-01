## Container setup tutorial


1. Set the variables in .env to your liking
	- Careful! Make sure the port and container name are not in use (`lsof -i:port_number`)

2. Use the following commands

```sh
export UID=$(id -u)
export GID=$(id -g)
export USER=$(whoami)
```

3. run `docker compose up -d`

4. you can access your container with `bash access_container.sh` 
