This mouse_scroll.sh file allows you to change volume using your mouse.

1. Ensure all packages are installed.

      `sudo apt update && sudo apt install xinput xdotool pulseaudio-utils alsa-utils`

2. Find mouse ID and side button.

   a. find mouse pointer ID using `xinput list` then find side button number using `xinput test[ID]`


3. Download file and make it executable

      `chmod +x mouse_scroll.sh`

4. Execute.

      `./mouse_scroll.sh`
