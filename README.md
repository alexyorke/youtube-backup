# youtube-backup
Brutally simple YouTube channel cloud backup.

# How to use

Edit the `.env` file with your S3-API or S3-like API information (for example Backblaze's B2, Wasabi, Amazon S3, etc.) You can sign up for a Wasabi account which has an S3 compatible API and substitute the access key and secret key in the file with your credentials. Additionally, edit the file to include your bucket name that you created and the channel that you would like to backup. If you're not using Wasabi, change the endpoint URL to whichever service you are using.

After editing the file, just run `docker-compose up youtube-channel-downloader` in this folder. Inside of the bucket, it will make a new folder named after the channel's id inside of your bucket with the videos in the highest quality possible, including subtitles, thumbnails, annotations, and the video description. Feel free to stop it at any point with `Ctrl+C` and re-run it later; it'll start where it left off.

Prefer to run it in the background? Just run it as `docker-compose up -d youtube-channel-downloader`. Or, run it as a cronjob to backup that channel's YouTube videos periodically.

## Goals

Occam's-razor-thinking is strongly preferred for this project. The overarching goal is just to backup YouTube channels, maximizing data integrity. This can be achieved by:

- Brutally simplifying the code at the expense of features. Reducing code paths reduces cyclomatic complexity which can make testing easier and helps avoid edge cases.
- Downloading at only the highest quality possible with the highest audio quality possible without providing options to change the quality. This provides as close as a ground truth as possible to the original video without adding in additional features and options which could introduce bugs and encode videos at the wrong quality.
- Reducing components. `youtube-backup` doesn't have a database as this introduces extra state; the database might get corrupted, it uses extra resources, and there is complexity with managing state between the filesystem and the database. Instead, an auto-generated file list containing only files which have been successfully backed up is used as the ground truth. If a file doesn't exist then it is not backed up. If it does exist then it is backed up.
- Using stateless methods when possible. `youtube-backup` runs in a Docker container which can be run on Amazon Lambda for instance. If it fails at any point throughout the process, simply re-running it will continue where it left off since it uses the filesystem as the state.
- There is no code in the application which deletes files. It only uploads and moves files, reducing the likelihood of deleting a file by mistake.

## Caveats

- Only public videos are downloaded. Downloading unlisted and private videos would require using the YouTube API (if that is supported) which would depend on an API key with limits, which would then have to be kept track of, which would require authentication, and updates if the API changes, and OAuth, and versioning, which...
- Not possible to backup half of a channel or half of a playlist. Everything is backed up. A simple deny list of not allowed YouTube ids could be created but simpler is better than more complex.
- Age-restricted videos require a cookies file of a YouTuber who is of sufficient age to watch age-restricted videos. Otherwise, they are not downloaded.
- Videos that have the error "This video is unavailable on this device." are not downloaded. I don't know why some videos show that when played in the web browser.
- If a video is in the process of encoding, it might be downloaded at a lower resolution than its maximum resolution. I have not tested this.

## Credits

Heavily based off of https://github.com/skypeter1/docker-s3-bucket. `youtube-dl` is also a large component.
