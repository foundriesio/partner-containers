#!/bin/sh -e

rm /opt/gst -rf
mkdir /opt/gst
cp /apps/bin/* /opt/gst/
cp /src/models/* /opt/gst/
chmod +x /opt/gst/gst-*
sshpass -p "fio" ssh -o StrictHostKeyChecking=no fio@127.0.0.1 'echo "fio" | sudo WAYLAND_USER=weston XDG_RUNTIME_DIR=/run/user/63 WAYLAND_DISPLAY=wayland-1 -S '''$@''''
