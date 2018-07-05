FROM ubuntu
MAINTAINER Douglas Marra <douglasmsi@gmail.com>
#
# Dockerfile for IPFS (https://ipfs.io/)
# Data is stored under /root/.ipfs/

ENV API_PORT 5001
ENV GATEWAY_PORT 8080
ENV SWARM_PORT 4001

EXPOSE ${SWARM_PORT}
# This may introduce security risk to expose API_PORT public
EXPOSE ${API_PORT}
EXPOSE ${GATEWAY_PORT}

RUN apt-get update
RUN apt-get install golang-go wget git -y
RUN echo "Teste"
RUN wget https://dist.ipfs.io/go-ipfs/v0.4.15/go-ipfs_v0.4.15_linux-amd64.tar.gz
RUN tar xvfz go-ipfs_v0.4.15_linux-amd64.tar.gz
RUN mv go-ipfs/ipfs /usr/local/bin/ipfs
RUN cd ~/
RUN ipfs version

RUN IPFS_PATH=~/.ipfs ipfs init

RUN export IPFS_PATH=~/.ipfs

RUN go get -u github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen

# Use o comando para gerar ou copie se você ja tiver
# RUN ipfs-swarm-key-gen > ~/.ipfs/swarm.key
RUN echo "/key/swarm/psk/1.0.0/" > ~/.ipfs/swarm.key
RUN echo "/base16/" >> ~/.ipfs/swarm.key
RUN echo "493294efca357564a808bf99c95cb0f7851a4ab394efd7d2750a67f5e059f835" >> ~/.ipfs/swarm.key


# config the api endpoint, may introduce security risk to expose API_PORT public
RUN IPFS_PATH=~/.ipfs ipfs config Addresses.API /ip4/0.0.0.0/tcp/${API_PORT}

# config the gateway endpoint
RUN IPFS_PATH=~/.ipfs ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/${GATEWAY_PORT}

# Remove bootstrap default
RUN IPFS_PATH=~/.ipfs ipfs bootstrap rm --all

 RUN export LIBP2P_FORCE_PNET=1 && IPFS_PATH=~/.ipfs ipfs daemon &

# by default, run `ipfs daemon` to start as a running node
ENTRYPOINT ["ipfs"]
CMD ["daemon"]
