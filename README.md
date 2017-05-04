This is a quick Bash script that can be run on Linux to automatically refill any portable device with random songs from your music library. I wrote it for my personal usage so I thought it could be useful to others.

The idea is that I would simply connect the phone via USB to the living room computer, activate MTP file transfer and get new music onto it without further interaction.

The hard part is figuring out the path of the phone Music directory. For an Android phone attached to a system running GNOME, it should be something like: /run/user/1000/gvfs/mtp\:host\=&ast;/&ast;/Music/. Not exactly user friendly.

Example usage. Transfer 10 random songs (deleting the older ones):

> refill.sh 10 /home/flavio/Music/Rock/ /run/user/1000/gvfs/mtp\:host\=&ast;/&ast;/Music/

Add the script to Cron to have the script automatically run.
