# Clair container scan
## Overview
Automatically scan all local docker containers with [Clair Vulnerability Scanner](https://github.com/coreos/clair) using [Clair-Scanner](https://github.com/arminc/clair-scanner) and [clair-local-scan](https://github.com/arminc/clair-local-scan).
## Quick start
### Scan all local containers
To get json output of the clair scan of all running containers to standard out just run:
```bash
docker-compose run --rm scanner 2>/dev/null && docker-compose down >/dev/null 2>&1
```
### Scan a particular local image
To scan one particular local image, you can use the included cs tool:
```
# To scan alpine:3.4 run:
docker-compose run --rm scanner cs alpine:3.4
# clean up
docker-compose down
```
The `cs` is just a wrapper around [Clair-Scanner](https://github.com/arminc/clair-scanner), wiring it to the clair service (using the `-c` and the `--ip` parameters). So you can use all of its parameters.
To list all parameters run:
```
docker-compose run --rm scanner cs
```
## Prerequisites
* Docker
* docker-compose

## Credits
* Docker
* docker-compose
* [Clair Vulnerability Scanner](https://github.com/coreos/clair)
* [Clair-Scanner](https://github.com/arminc/clair-scanner) (release v8 is included)
* [clair-local-scan](https://github.com/arminc/clair-local-scan).
