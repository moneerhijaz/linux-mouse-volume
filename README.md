# Mouse volume control for Linux/X11

Hold a mouse side button and move vertically to adjust the current audio volume. Bash polls the pointer position, captures the starting volume, and clamps the result to 0–100%.

## Setup

Requires an **X11 session**, Bash, `xinput`, `xdotool`, and either `pactl` (preferred) or `amixer`. Native Wayland control is not implemented.

```bash
sudo apt install xinput xdotool pulseaudio-utils alsa-utils
xinput list
# Replace 9 with your actual pointer device ID:
xinput test 9
```

Edit `MOUSE_ID` and `SIDE_BUTTON` in `mouse_volume.sh` using observed values. Device IDs can change after reconnect/reboot. `PIXELS_PER_PERCENT=4` and `SLEEP=0.005` control sensitivity and polling.

```bash
bash -n mouse_volume.sh
bash mouse_volume.sh
```

Start at a low volume. Hold the configured button, move up/down, then release. Ctrl+C stops the loop. This script changes the default audio sink and does not restore the original volume on exit.

Validation: shell syntax can be checked without a desktop; pointer and audio behavior require a real X11 session and were not exercised in this review. [License](LICENSE). [Windows counterpart](https://github.com/moneerhijaz/windows-mouse-volume).
