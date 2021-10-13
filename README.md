# PhoreDocker
Create a docker container that can be used to build and run the Phore (https://phore.io/) client.  This is intended to allow an easy way to run the wallet on a Raspberry Pi (recommended Raspberry Pi 4 8GB), but could be useful to run on any 64-bit linux installation to not have to worry about dependencies of that exact OS.

![image](https://user-images.githubusercontent.com/6404377/118014460-405c1000-b321-11eb-94b2-fa8196c57efe.png)

## Dependencies
* 64-bit OS installed on the Pi (currenlty using Ubuntu 21.04).  Recommended to run off an external USB hard drive and not a SD card.
* Docker installed (https://docs.docker.com/engine/install/).  Note - Docker is included in Ubuntu 21.04.
* x11docker installed (https://github.com/mviereck/x11docker#shortest-way-for-first-installation).
* xclip to copy/paste into/out of the container: `sudo apt-get install xclip`

## Usage

### Build the image

Execute `sudo ./buildPhore.sh` to setup a Docker image that does the following:
* Fetch and extract the latest tarball source file from the Phore GitHub
* Setup all build and runtime dependencies for Phore
* Compile the Phore source
* Create a final image tagged as ubuntu/phore:latest, with only the files necessary to launch Phore.
* Note - compilation will take several hours on a Raspberry Pi.

You can execute a `docker system prune` after building to free up space from the intermediate images of the build if desired.

### Run the image

Execute `sudo ./runPhore.sh` to launch a container with the ubuntu/phore image using x11docker with the data folder in the same directory shared as the home folder for the container.  

The first time it is launched the Phore application will prompt for the data folder.  Choosing the default will create a hidden .Phore folder inside the shared data folder, and will be used the next time the Phore application is launched.  

After syncing the blockchain, exit Phore and the x11docker window will close.  If you have an existing wallet.dat file, you can replace the data/.Phore/wallet.dat file with yours.  Remember to keep your wallet.dat file safe!

### Notes

There are some visual odditities present when using x11docker.  There might be some other settings to play with to help with these, but it is usable as is.

* The title bar is not visibile in the application, meaning the 'X' buttons to close the application or any dialogs are not available.  To close dialogs, the Cancel button or the Esc key can be used.
* The runPhore.sh script uses two options for x11docker: `-d` to indicate the image contains a desktop OS, and `--clipboard` to allow copy/paste into and out of the container and host.

### Advanced build

An alternative to building directly on the Raspberry Pi is to build on Windows or Mac using Docker Desktop and the buildx command (https://docs.docker.com/desktop/multi-arch/) to create an arm64 image, then load the image onto the Pi.

To build arm64: `docker buildx build --platform linux/arm64 -t ubuntu/phore .`

To load the image onto the Pi, there are a couple options:
* Push the image to a personal docker repository , then pull it to the Pi and tag it as ubuntu/phore:latest
* Docker save the image to a tar file, and docker load the tar file on the Pi
