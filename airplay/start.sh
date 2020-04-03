#!/usr/bin/env bash

if [[ -z "$BLUETOOTH_DEVICE_NAME" ]]; then
  BLUETOOTH_DEVICE_NAME=$(printf "balenaSound %s" $(hostname | cut -c -4))
fi
#ALSA config mixervon usb second card as default if available
if [[ -f /proc/asound/cards ]]; then
  let card=$(cat /proc/asound/cards | grep ]: | wc -l)-1
  case "$card" in
    0)
      mixer_control_name="PCM";
      export BLUE_SPEAKERS="${BLUE_SPEAKERS:-hw:0}"
      ;;
    *)
      echo -e "\
defaults.pcm.card $card\n\
defaults.ctl.card $card" | tee /etc/asound.conf
      mixer_control_name="Master";
      export BLUE_SPEAKERS="${BLUE_SPEAKERS:-hw:$card}"
  ;;
  esac
fi
sed -i -E \
-e "s/(output_device\ =\ )\".*\"/\\1\"${BLUE_SPEAKERS}\"/" \
-e "s/(mixer_control_name\ =\ )\".*\"/\\1\"${mixer_control_name}\"/" \
/etc/shairport-sync.conf
SAMPLE_RATE=${SAMPLE_RATE:-48000}
sed -E "s/(^.*rate )([^ ]*)(.*)/\\1${SAMPLE_RATE}\\3/" /usr/src/.asoundrc | tee ~/.asoundrc
exec shairport-sync -a "$BLUETOOTH_DEVICE_NAME" | printf "Device is discoverable as \"%s\"\n" "$BLUETOOTH_DEVICE_NAME"
