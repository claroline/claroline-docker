# claroline-docker

## Building the machine
```bash
docker build -t claroline-connect .
```
## Running the machine
```bash
docker run -d -p 99:80 --name "claroline-connect" -t claroline-connect
```

## Accessing the machine
```bash
http://localhost:99/
```

## Removing the machine and all its contents
```bash
docker rm -f claroline-connect
```
