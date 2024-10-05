#!/usr/bin/env bash
# Reload sound after crash
# Kill all pulseaudio process
systemctl --user stop pipewire.socket
systemctl --user stop pipewire-pulse.socket
systemctl --user stop pipewire.service
systemctl --user stop pipewire-pulse.service

# Check for remaining process
ps -aux | grep -i audio

# Reload module
sudo modprobe -r snd_hda_intel
sudo modprobe snd_hda_intel

# Start pulseaudio
systemctl --user start pipewire.socket
systemctl --user start pipewire-pulse.socket

# Don't forget to restart apps using audio 
