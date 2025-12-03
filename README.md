This mouse_volume.sh file allows you to change volume using your mouse.

1. Ensure all packages are installed

      `sudo apt update && sudo apt install xinput xdotool pulseaudio-utils alsa-utils`

2. Find mouse ID and side button

   Find mouse pointer ID using `xinput list` then find side button number using `xinput test[ID]`
   
   Edit `MOUSE_ID` and `SIDE_BUTTON` in the file


4. Download file and make it executable

      `chmod +x mouse_volume.sh`

5. Execute

      `./mouse_volume.sh`
