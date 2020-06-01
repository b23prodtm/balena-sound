#!/usr/bin/env bash

# ENTRYPOINT https://www.balena.io/docs/reference/base-images/base-images/#how-the-images-work-at-runtime
# Check OS we are running on.  NetworkManager only works on Linux.
if [[ "$OSTYPE" != "linux"* ]]; then
    echo "ERROR: This application only runs on Linux."
    exit 1
fi

# Save the path to THIS script (before we go changing dirs)
TOPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
# The top of our source tree is the parent of this scripts dir
cd $TOPDIR

# Sometimes it takes a couple of seconds to connect the wifi,..
# sleep 15

# Use the venv
source $TOPDIR/venv/bin/activate
# Start our application
/usr/bin/entry.sh "$@"
