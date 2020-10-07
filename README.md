# youtube-backup
Backup YouTube channels and playlists.

## Goals

Occam's-razor-thinking is strongly preferred for this project. The overarching goal is just to backup YouTube playlists and channel videos, maximizing data integrity. This can be achieved by:

- Brutally simplifying the code at the expense of features. Reducing code paths reduces cyclomatic complexity which can make testing easier and helps avoid edge cases.
- Downloading at only the highest quality possible with the highest audio quality possible without providing options to change the quality. This provides as close as a ground truth as possible to the original video without adding in additional features and options which could introduce bugs and encode videos at the wrong quality.
- Reducing components. `youtube-backup` doesn't have a database as this introduces extra state; the database might get corrupted, it uses extra resources, and there is complexity with managing state between the filesystem and the database. Instead, the filesystem filenames are used as the ground truth. If a file doesn't exist then it is not backed up. If it does exist then it is backed up.
- Atomically backing up files. Files are first uploaded to a temporary directory and then moved only if the upload was successful. If the upload fails at any point in the process for any reason, the files are not moved and therefore will not be flagged as backed up.
- Using stateless methods when possible. `youtube-backup` runs in a Docker container which can be run on Amazon Lambda for instance. If it fails at any point throughout the process, simply re-running it will continue where it left off since it uses the filesystem as the state.
- There is no code in the application which deletes files. It only uploads and moves files, reducing the likelihood of deleting a file by mistake. Additionally, files are moved only if the destination does not exist to prevent erronous overwriting. Lifecycle policies, depending on the storage medium can be added to the temporary directory to prevent overgrowth.
- Again, depending on the storage medium, file hashes can be verified before the files are moved into place. This is an extra guarantee that the files were not modified while in transit or accidently modified by another process while being uploaded.
- Report generation after each backup. The files are listed on the channel and compared with the ones currently backed up. Any files which are missing from the backup are shown in the report.

## Caveats

- Since the uploads are organized by channel id and playlist id, identical videos can exist between channels and playlists which can increase the storage size. To reduce complexity `youtube-backup` does not support de-duplication. Instead, a storage medium with file-level or block-level de-duplication could be used.
- Only one version of a video's captions are kept. When a video is downloaded the metadata file is appended to but never overwritten. If the video already exists in the metadata it is not re-added.
- Subtitles and thumbnails, after being embedded into the video, are never changed after the video is downloaded.
- Only public videos are downloaded. Downloading unlisted and private videos would require using the YouTube API (if that is supported) which would depend on an API key with limits, which would then have to be kept track of, which would require authentication, and updates if the API changes, and OAuth, and versioning, which...
- Not possible to backup half of a channel or half of a playlist. Everything is backed up. A simple deny list of not allowed YouTube ids could be created but simpler is better than more complex.
- Videos cannot be partially downloaded and resumed later. While it is possible to do so (since it is a streaming service), it makes things more complicated. This can cause issues with extremely large videos that can't be downloaded in one shot.
