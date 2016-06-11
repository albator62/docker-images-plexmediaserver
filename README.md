## Plex Media Server
This is an image for running your own [Plex Media Server](http://plex.tv).  Because it's built on top of [ecloudfs](https://hub.docker.com/r/joshhogle/ecloudfs), you have the option of storing media locally on the host or by utilizing a supported cloud service.  You also have the option to encrypt media.  This can be used to prevent a cloud provider from actually seeing what media you have stored on their service.

**You should always be sure to comply with your cloud service provider's acceptable usage policies.  This is not meant to advocate for abusing services or for using this as a way to hide pirated media that you are storing.**

### What You Need
- The [run-container](https://raw.githubusercontent.com/TheJoshHogle/docker-tools/master/run-container) script for easily creating Docker containers
- You should review the [ecloudfs](https://hub.docker.com/r/joshhogle/ecloudfs) instructions for configuring your media storage.
- You should consider purchasing a [Plex Pass](https://plex.tv/subscription/about) from Plex for premium features.  It's really not expensive and gives you some pretty cool additions.
- Finally, you'll need to choose a folder for storing the Plex configuration files and data (eg: **/opt/docker/plex/data**)

### Initial Plex Setup
If this is the first time you are running the server, you'll need to trick the container into providing you *local* access to Plex so you can claim the server on your account.  These instructions assume that you want Plex to be publicly accessible via port 8080.  You can choose any port you like, however.  Just replace references to 8080 with the port of your choosing.

1. On the Docker host, create the configuration folder you chose above.
  - `host# mkdir -p /opt/docker/plex/data`
  - `host# chown 107:109 /opt/docker/plex/data`
  - `host# chmod 750 /opt/docker/plex/data`
2. Download the **run-container** script (see **What You Need** above) and store it in the **/opt/docker** folder.  Make sure to make the script executable.
  - `host# chmod +x /opt/docker/run-container`
3. Create a new file called **container.conf** inside the **/opt/docker/plex** folder.  The format is shown below in the **Container Configuration File Format**.
4. Create and start the container.
  - `host# /opt/docker/run-container plex`
5. Connect to the container and use **socat** to redirect port 8080 to port 32400.
  - `host# docker exec -t -i plex /bin/bash`
  - `container# socat TCP-LISTEN:8080,fork TCP:127.0.0.1:32400`
6. Open a web browser and navigate to **http://host:8080/web**, accept the license agreement and claim the server by logging into your Plex account.
7. Navigate to **Remote Access** under **Settings** and click the **Show Advanced** button to reveal the port mapping for remote access.
  a. Check **Manually specify public port** and set the value to **8080**.
  b. Click **Apply**.  The server should become publicly accessible.
8. Once you have claimed the server, use **CTRL+C** to stop **socat** and exit from the container.
  - `container# exit`
9. Follow the directions from the [ecloudfs](https://hub.docker.com/r/joshhogle/ecloudfs) image for mounting folders for storing media inside the container.
10. Re-create and start the container.
  - `host# /opt/docker/run-container plex`

You should now be able to connect to your Plex server from the main Plex application online at http://plex.tv.

In the future, you can update the container by simply re-running the **/opt/docker/run-container plex** command. It will automatically pull the latest version of the container from Docker Hub and replace it without affecting your data or configurations.

#### Container Configuration File Format
~~~~
#
# This is the Docker image name on Docker Hub
#
IMAGE_NAME=joshhogle/plexmediaserver

#
# Which tag should we grab the image for
#
IMAGE_TAG=latest

#
# What you want to call the container on the host
#
CONTAINER_NAME=plex

#
# Expose port 32400 in the container as 8080 on the host
#
PORTS="8080:32400"

#
# We don't need to set any environment variables for the container
#
ENV=""

#
# We don't need to set the container's hostname to the same as the Docker host
#
USE_HOSTNAME=false

#
# We need to enable privileged commands for mounting and unmounting Amazon
# Cloud Drive and Google Drive filesystems
#
OPTIONS="--privileged"

#
# This is a space-delimited list of volumes that should be mounted from the
# host into the container.
#
# Each volume should be specified as host_folder:container_folder where
# host_folder is the full path of the folder on the host and container_folder
# is the full path within the container in which to mount the host folder.
#
VOLUMES="/opt/docker/plex/data:/var/lib/plexmediaserver /opt/docker/plex/mount.d:/etc/mount.d /opt/docker/plex/acd:/var/lib/acd /opt/docker/plex/gdrive:/var/lib/gdrive /mnt/data/public:/mnt/local/public /mnt/data/private:/mnt/local/.private"
~~~~
You can use this file as-is.  If you want to mount local folders within the container, you will need to adjust the **VOLUMES** value appropriately.  Please make sure you refer to the **ecloudfs** documentation for this.

## Backing Up Plex
Once you have configured Plex per the instructions above, you simply need to backup the **/opt/docker/plex** folder and subfolders to save your Plex configuration.  You should also back up any host folders in which you are storing  media files.

#### Version / Tag History
**1.0.0-1**: _(Released June 11, 2016)_
- Initial release of container
- Plex Media Server v0.9.16.6.1993-5089475 (Released April 22, 2016)
