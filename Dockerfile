FROM golang:1.10-stretch
MAINTAINER Douglas Marra <douglasmsi@gmail.com>
#
# Dockerfile for IPFS (https://ipfs.io/)
# Data is stored under /root/.ipfs/

ENV DEBIAN_FRONTEND noninteractive

ENV API_PORT 5002
ENV GATEWAY_PORT 8002
ENV SWARM_PORT 4001

EXPOSE ${SWARM_PORT}
# This may introduce security risk to expose API_PORT public
EXPOSE ${API_PORT}
EXPOSE ${GATEWAY_PORT}

# Only useful for this Dockerfile
ENV FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric

# Install ipfs using ipfs-update
RUN go get -u github.com/ipfs/ipfs-update \
    && ipfs-update install latest \
    && ipfs init

# config the api endpoint, may introduce security risk to expose API_PORT public
RUN ipfs config Addresses.API /ip4/0.0.0.0/tcp/${API_PORT}

# config the gateway endpoint
RUN ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/${GATEWAY_PORT}

# Remove bootstrap default
RUN ipfs bootstrap rm --all

# by default, run `ipfs daemon` to start as a running node
ENTRYPOINT ["ipfs"]
CMD ["daemon"]
