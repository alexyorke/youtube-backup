#!/bin/bash

## Mount S3 bucket and create automatic mount script
echo $AWS_ACCESS_KEY:$AWS_SECRET_ACCESS_KEY > /root/.passwd-s3fs && \
     chmod 600 /root/.passwd-s3fs && \
     s3fs $S3_BUCKET_NAME $S3_MOUNT_DIRECTORY -o passwd_file=/root/.passwd-s3fs -o use_path_request_style -o url="$S3_ENDPOINT_URL" && \

# Download channel
channel_id=$(youtube-dl --get-filename -o '%(channel_id)s' https://www.youtube.com/c/$CHANNEL_NAME/ 2>/dev/null | head -n 1) && \
youtube-dl -f best -c --write-description --download-archive /var/www/s3/$channel_id/archive.txt -i --write-info-json --write-annotations \
           --cookies /var/www/s3/$channel_id/cookies.txt --all-subs --embed-thumbnail --embed-subs --add-metadata --write-thumbnail \
           -o "/var/www/s3/%(channel_id)s/%(title)s-%(id)s.%(ext)s" https://www.youtube.com/c/$CHANNEL_NAME/;