# How to build arm32v7 (Raspberry) kafka zookeeper image

## Change docker

use base image of  arm32v7/openjdk:8u212-jre-slim

##Build on raspberry 3 for kafka zookeeper 3.4.13

```
docker build --build-arg build_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ") -t bqstony/wurstmeister-arm32v7-zookeeper:3.4.13 .
```

