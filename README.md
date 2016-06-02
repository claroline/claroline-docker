# claroline-docker

This will set you up with a working instance of Claroline Connect for test purposes. **DO NOT USE THIS IN PRODUCTION**
You are free to change the local port (99 in the example) to something more suited to your setup if you need.

Admin user :
- Username : admin
- Password : pass

## Easy install
```bash
docker pull claroline/claroline-docker
docker run -d -p 99:80 -t claroline/claroline-docker:latest
```

## Building the machine localy (Harder install)

### Building the machine
```bash
docker build -t claroline-connect .
```
### Running the machine
```bash
docker run -d -p 99:80 --name "claroline-connect" -t claroline-connect
```

### Accessing the machine
```bash
http://localhost:99/
```

### Removing the machine and all its contents
```bash
docker rm -f claroline-connect
```
