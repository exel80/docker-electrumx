FROM python:3.7-alpine3.12
LABEL maintainer="Luke Childs <lukechilds123@gmail.com>"

COPY ./bin /usr/local/bin
COPY ./VERSION /tmp

RUN VERSION=$(cat /tmp/VERSION) && \
    chmod a+x /usr/local/bin/* && \
    apk add --no-cache git build-base openssl cmake gcc libffi-dev && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.11/main leveldb-dev && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing rocksdb-dev && \
    pip install --upgrade pip && \
    pip install aiohttp x16r_hash aiorpcx x16rv2_hash pylru plyvel websockets python-rocksdb kawpow && \
    git clone -b $VERSION https://github.com/spesmilo/electrumx.git && \
    cd electrumx && \
    python setup.py install && \
    apk del git build-base && \
    rm -rf /tmp/*

VOLUME ["/data"]
ENV HOME /data
ENV ALLOW_ROOT 1
ENV DB_DIRECTORY /data
ENV SERVICES=tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx.key
ENV HOST ""
WORKDIR /data

EXPOSE 50001 50002 50004 8000

CMD ["init"]
