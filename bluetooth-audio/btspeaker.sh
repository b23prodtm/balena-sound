#!/usr/bin/env bash
set -e
PCM_BUFFER_TIME=${PCM_BUFFER_TIME:-300000}
MAC_ADDRESS=${BTSPEAKER_SINK:-00:00:00:00:00:00}
while [ "$#" -gt 0 ]; do case $1 in
  -[tT]*)
    shift; PCM_BUFFER_TIME=$1;;
  -[hH]*)
    echo -e "Usage: $0 [-t <PCM_BUFFER_TIME>] [device HCI]" && exit 0;;
  *)
    MAC_ADDRESS=$1;;
esac; shift; done
function btspeaker() {
  # pair on sink "bluetooth speaker" device
  sleep 2
  printf "Waiting for speakers %s...\n" "$1"
  case '$(printf "scan on\ndevices\nexit" | bluetoothctl | grep "$1" | wc -w)' in
    0) btspeaker $*;;
    *)
      printf "devices\npair %s\ntrust %s\nconnect %s\nscan off\nexit" "$1" "$1" "$1" | bluetoothctl
      sed -E "s/(^.*device )([^ ]*)(.*)/\\1\"$1\"\\3/" /usr/src/.asoundrc | tee ~/.asoundrc
      if [ $(aplay -D bluealsa /usr/share/sounds/alsa/Noise.wav > /dev/null) ]; then
        btspeaker $*
      fi
      ;;
  esac
}
btspeaker $MAC_ADDRESS
# loopback snd_usb_audio to blue-speaker
arecord -l
BTSPEAKER_INPUT=${BTSPEAKER_INPUT:-"hw:1,0"}
printf "Alsa sound loop from BTSPEAKER_INPUT=%s." "${BTSPEAKER_INPUT}"
function keepalive() {
  myprocess=$1
  shift
  mycmd=$*
  mylog="/tmp/balena/$myprocess.log"
  case "$(pidof $myprocess | wc -w)" in
    0)  printf "Keep alive pid %s %s:\nerrors log: %s" "$myprocess" "$mycmd" "$mylog"
        $myprocess $mycmd 2> $mylog &
        ;;
    1)  # all ok but check mylog for errors
        if [[ $(wc -l $mylog | awk '{print $1}') -ne 0 ]]; then
          echo "Errors caught"
          kill -9 $(pidof $myprocess | awk '{print $1}') &
          tee $mylog < /dev/null
        fi;;
    *)  printf "Removed double %s %s" "$myprocess" "$mycmd"
        kill -9 $(pidof $myprocess | awk '{print $1}') &
      ;;
  esac;
  sleep 1
  keepalive $myprocess $mycmd
}

keepalive alsaloop -P bluealsa -t $PCM_BUFFER_TIME -C $BTSPEAKER_INPUT --sync=5 -A0
