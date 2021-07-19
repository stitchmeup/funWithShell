#!/usr/bin/env bash

# Enable or disable intel cpu turbo boost 

Usage(){
    echo "Usage :   turbo_or_not_turbo MODE"
    echo "MODE  :   d, disable : disable turbo boost"
    echo "          e, enable : enable turbo boost"
    echo "Warning : requires to be launched as root"
}

if [[ "$EUID" != 0 ]]; then
    echo "You must be root!"
    echo "QUITTING"
    exit 2
fi

case "$1" in
    d|disable)
        echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
        ;;
    e|enable)
        echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo
        ;;
    *)
        Usage
        exit 1
        ;;
esac
