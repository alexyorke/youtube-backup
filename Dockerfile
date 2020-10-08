FROM ubuntu:18.04

## Some utilities
RUN apt-get update -y && \
    apt-get install -y build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev pkg-config libssl-dev mime-support automake libtool wget tar git unzip
RUN apt-get install lsb-release -y  && apt-get install zip vim python curl attr ffmpeg atomicparsley dos2unix -y
RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl

## Install S3 Fuse
RUN rm -rf /usr/src/s3fs-fuse
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse/ /usr/src/s3fs-fuse
WORKDIR /usr/src/s3fs-fuse 
RUN ./autogen.sh && ./configure && make && make install

## Create folder
WORKDIR /var/www
RUN mkdir s3

## Set the directory where you want to mount your s3 bucket
ARG S3_MOUNT_DIRECTORY=/var/www/s3
ENV S3_MOUNT_DIRECTORY=$S3_MOUNT_DIRECTORY

## change workdir to /
WORKDIR /

## Entry Point
ADD start-script.sh /start-script.sh
RUN dos2unix /start-script.sh
RUN chmod 755 /start-script.sh
CMD ["/start-script.sh"]
