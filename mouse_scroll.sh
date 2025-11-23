#!/usr/bin/env bash

#######################################
# CONFIG
#######################################

# How many pixels of vertical movement = 1% volume change
PIXELS_PER_PERCENT=4

# Polling interval in seconds (very small for "instant" feel)
SLEEP=0.005

MOUSE_ID=9      # your Logitech M720 pointer device ID
SIDE_BUTTON=9   # your side button


#######################################
# DEPENDENCY CHECKS
#######################################

if ! command -v xdotool >/dev/null 2>&1; then
  echo "Error: xdotool is required (sudo apt install xdotool, etc.)"
  exit 1
fi

if ! command -v xinput >/dev/null 2>&1; then
  echo "Error: xinput is required (sudo apt install xinput, etc.)"
  exit 1
fi

if command -v pactl >/dev/null 2>&1; then
  VOLUME_BACKEND="pactl"
elif command -v amixer >/dev/null 2>&1; then
  VOLUME_BACKEND="amixer"
else
  echo "Error: neither pactl nor amixer found. Install one of them."
  exit 1
fi


#######################################
# VOLUME HELPERS
#######################################

get_volume() {
  case "$VOLUME_BACKEND" in
    pactl)
      # Extract % from: Volume: front-left: 32768 /  50% / ...
      pactl get-sink-volume @DEFAULT_SINK@ \
        | awk -F'/' 'NR==1 { gsub(/%/,"",$2); gsub(/ /,"",$2); print $2 }'
      ;;
    amixer)
      # Extract % from: Front Left: Playback 32768 [50%] ...
      amixer get Master \
        | awk -F'[][]' '/%/ {gsub(/%/,"",$2); print $2; exit}'
      ;;
  esac
}

set_volume_abs() {
  local vol="$1"
  # clamp 0–100
  if (( vol < 0 ));  then vol=0;   fi
  if (( vol > 100 )); then vol=100; fi

  case "$VOLUME_BACKEND" in
    pactl)
      pactl set-sink-volume @DEFAULT_SINK@ "${vol}%"
      ;;
    amixer)
      amixer set Master "${vol}%"
      ;;
  esac
}


#######################################
# INPUT HELPERS
#######################################

get_mouse_y() {
  xdotool getmouselocation --shell | awk -F= '/^Y=/ {print $2}'
}

button_is_down() {
  # returns 0 (true) if button is down, 1 (false) otherwise
  xinput --query-state "$MOUSE_ID" | grep -q "button\[$SIDE_BUTTON\]=down"
}


#######################################
# MAIN LOOP
#######################################

echo "Mouse volume control (absolute mapping) running."
echo "Mouse device ID: $MOUSE_ID, side button: $SIDE_BUTTON"
echo "Hold the side button and move mouse up/down to set volume."
echo "Press Ctrl+C to exit."

base_y=""
base_vol=""
button_was_down=0

trap 'echo; echo "Exiting mouse volume control."; exit 0' INT

while true; do
  if button_is_down; then
    y=$(get_mouse_y)
    [[ -z "$y" ]] && { sleep "$SLEEP"; continue; }

    if (( button_was_down == 0 )); then
      # Button just pressed: capture baseline mouse and volume
      base_y="$y"
      base_vol="$(get_volume)"
      # Fallback if we fail to read volume
      [[ -z "$base_vol" ]] && base_vol=50
      button_was_down=1
    else
      # Compute delta from starting position
      dy=$(( base_y - y ))   # up -> positive, down -> negative

      # Convert pixels to percentage
      # handle sign correctly with integer division
      if (( dy >= 0 )); then
        delta_percent=$(( dy / PIXELS_PER_PERCENT ))
      else
        # bash truncates toward 0, so we adjust for negative
        delta_percent=$(( -((-dy) / PIXELS_PER_PERCENT) ))
      fi

      new_vol=$(( base_vol + delta_percent ))
      set_volume_abs "$new_vol"
    fi
  else
    # Button not held: reset baseline
    button_was_down=0
    base_y=""
    base_vol=""
  fi

  sleep "$SLEEP"
done

