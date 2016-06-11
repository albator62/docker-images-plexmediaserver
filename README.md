## Plex Media Server
This container runs the [Plex Media Server](http://plex.tv) on Ubuntu and uses [Amazon Cloud Drive](http://amazon.com/clouddrive) for storing and retrieving media files.  The **acd_cli** utility is built into the image for you.

### What You Need
You'll need an Amazon Cloud Drive account to store media within Amazon.  You should also consider purchasing a Plex Pass from Plex for premium features.

### Initial Plex Setup
If this is the first time you are running the server, you'll need to trick the container into providing you *local* access to Plex so you can claim the server on your account.  These instructions assume that you want Plex to be publicly accessible via port 8080.  You can choose any port you like, however.  Just replace references to 8080 with the port of your choosing.

1. Choose a folder in which to store data for Plex.  This is **not** your media folder.  This is where you want to store your Plex configuration files.  These instructions assume you choose **/docker/plex/data** for this.
2. Create the folder and set the appropriate permissions for it.
  - `host# mkdir -p /docker/plex/data`
  - `host# chown 107:109 /docker/plex/data`
  - `host# chmod 750 /docker/plex/data`
3. Create a container exposing port 8080 from the container to the host.
  - `host# docker create --name plex -p 8080:8080 -v /docker/plex/data:/var/lib/plexmediaserver joshhogle/plexmediaserver:latest`
4. Start the container.
  - `host# docker start plex`
5. Connect to the container and use **socat** to redirect port 8080 to port 32400.
  - `host# docker exec -t -i plex /bin/bash`
  - `container# socat TCP-LISTEN:8080,fork TCP:127.0.0.1:32400`
6. Open a web browser and navigate to **http://host:8080/web**, accept the license agreement and claim the server by logging into your Plex account.
7. Navigate to **Remote Access** under **Settings** and click the **Show Advanced** button to reveal the port mapping for remote access.
  a. Check **Manually specify public port** and set the value to **8080**.
  b. Click **Apply**.  The server should become publicly accessible.
8. Once you have claimed the server, use **CTRL+C** to stop **socat** and exit from the container and destroy it.
  - `host# docker stop plex`
  - `host# docker rm plex`
9. Choose a local folder in which to store your media.  This is **only** used if you wish to store media on the local server.  It has nothing to do with Amazon at this point.  These instructions assume you choose **/docker/plex/media** for this.
10. Create the folder and set the appropriate permissions for it.
  - `host# mkdir -p /docker/plex/media`
  - `host# chown 107:109 /docker/plex/media`
11. Create the container with the correct settings as follows:
  - `host# docker create --name plex -p 8080:32400 -v /docker/plex/data:/var/lib/plexmediaserver -v /docker/plex/media:/media/local --privileged --restart always joshhogle/plexmediaserver:latest`
12. Start the new container.
  - `host# docker start plex`

You should now be able to connect to your Plex server from the main Plex application online at http://plex.tv.

### Initial Amazon Cloud Drive Setup
You must also initialize the Amazon Cloud Drive cache and settings if this is the first time you have run the container.

1. Connect to the container and use **su** to become the **plex** user.
  - `host# docker exec -t -i plex /bin/bash`
  - `container# su - plex`
2. Run an initial sync.
  - `container (plex)# acd_cli sync`
3. You will be prompted to log into an Amazon site to download an **oauth_data** file.  Complete the instructions that are provided on the screen.  You do not have to use the text browser to connect to the website.  You can simply copy the URL into your own browser and follow the link.  Once you have obtained the **oauth_data** file, continue to the next step.
4. Upload the **oauth_data** file obtained from Amazon to your server placing it in the **/docker/plex/.cache/acd_cli** folder.  Be sure to change the ownership and permissions on the file.
  - `host# chown 107:109 /docker/plex/.cache/acd_cli/oauth_data`
  - `host# chmod 600 /docker/plex/.cache/acd_cli/oauth_data`
5. Back inside the container, re-run **acd_cli sync** and make sure that it can update without issue.
6. Exit out of the shell as **plex** to become **root** again and restart Plex.
  - `container (plex)# exit`
  - `container# supervisorctl restart plexmediaserver`
  - `container# exit`

## Configuring Media Libraries
You should now be able to fully configure Plex from your own browser by either connecting directly to the host or by connecting through the Plex website.  Local media, which is stored on the local server and not within Amazon, will be accessible from within the **/media/local** folder within the container.  You can configure Plex to look in that folder and subfolders for media.  Amazon Cloud Drive media will be accessible from within the **/media/amazon** folder within the container.

## Backing Up Plex
Once you have configured Plex per the instructions above, you simply need to backup the **/docker/plex** folder and subfolders to save your Plex configuration and local media files.

## Updating Plex
To update to a new version of Plex:
- `docker pull joshhogle/plexmediaserver:latest`
- `docker stop plex`
- `docker rm plex`
- `docker create --name plex -p 8080:32400 -v /docker/plex/data:/var/lib/plexmediaserver -v /docker/plex/media:/media/local --privileged --restart always joshhogle/plexmediaserver:latest`
- `docker start plex`

You may wish to remove old, unused Docker images afterwards to save space as well.
