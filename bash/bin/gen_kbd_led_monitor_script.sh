#!/usr/bin/env bash

#   Generates a scripts to monitor leds devices brightness.
#   Those scripts are used to be used into Waybar custom modules.
#
#   USAGE: gen_kbd_led_mon.sh [-h|-v] -d DEVICE [--event|--path|--led] [-t TYPE] [--script-path] [--script-name]
#
#   REQUIRES:
#
#   DESCRIPTION: 
#   Generates a scripts to monitor leds devices brightness.
#   Like /sys/class/<inputX>::capslock which indicates the
#   capslock state of the keyboard linked to <inputX>.
#   Those scripts are designed to be executed by a Waybar
#   custom modules. The output of the scripts is a json
#   object:
#   {
#       "text": "LED_STATUS"
#       "alt":  "LED_STATUS"
#       "class": "LED_STATUS"
#   }
#   Also, it is simple to extract those value with jq to be
#   used in other places.
#   Keep in mind that devices might not always be assigned to the same ID (like a keyboard to the same inputX ID). That is why it is better to generate script on the fly that can dynamically find the corresponding led using a static identifier (like '/dev/input/by-path/<device>')
#



### INIT ###
declare -r myname='gen_kbd_led_mon_script'
declare -r myver='0.1'

usage() {
    cat << EOF
${myname} v${myver}

Generates a scripts to miitor led devices brightness.

Find a longer description in comments of this script.

Usage: ${myname} [-h|-v] -d DEVICE [--event|--path|--led] [-t TYPE] [--script-path] [--script-name] 

Options:
    --version                   show program's version number and exit
    -h, --help                  show this help message and exit
    -d, --device DEVICE_PATH    path to the device (usually a led or an input device link to the led) 
    --event,--path,--led        Type of device path given by the --device option:
                                    - event: /dev/input/eventX
                                    - path: /dev/input/by-path/<device>
                                    - led: /sys/class/led or /sys/devices/<device>/<input>
                                If none of those flag is positionned, then it must be a device found 
                                in /sys/devices/ that as some led in it (like 
                                '/sys/devices/platform/i8042/serio0/input/input6/input6::capslock'). 
    -t, --type LED_TYPE         There can be different led tied to an input device, like 
                                'inputX::capslock' or 'inputX::numlock'.
                                LED_TYPE can match anything in the form of 'inputX::LED_TYPE' led.
                                Default: 'capslock'
    --script-path PATH          PATH to the script to be generated.
                                Default: '/tmp' 
    --script-name FILENAME      FILENAME of the script to be generated.
                                Default: 'kbd_led_mon_LED_TYPE.sh'

EOF

    exit 0
}

version() {
    echo "${myname} ${myver}"
    exit 0
}

err() {
    echo "$1" >&2
    exit 1
}



### VARIABLES ###
declare led_type="capslock"
declare led
declare device
declare device_type="input"
declare input_device
declare input_event
declare input_by_path
declare script_path="/tmp"
declare script_name=



### ARG PARSING ###
while [[ $1 ]]; do
    if [[ ${1:0:2} = -- ]]; then
        option="${1:2}"
    elif [[ $1 =~ ^-[hailt]$ ]]; then
        option="${1:1}"
    fi
    case "${option}" in
        h|help) usage ;;
        version) version ;;
        event|path|led)
            [[ $device_type == "input" ]] || err "Multiple input entry type selected."
            device_type="$option"
            shift 1 ;;
        d|device)
            [[ $2 ]] || err "Missing arg for input."
            device="$2"
            shift 2 ;;
        t|type)
            [[ $2 ]] || err "Missing led type."
            led_type="$2"
            shift 2 ;;
        script-name)
            [[ $2 ]] || err "Missing script name."
            script_name="$2"
            shift 2
            ;;
        script-path)
            [[ $2 ]] || err "Missing script path."
            script_path="$2"
            shift 2
            ;;
            
        *) err "'$1' is an invalid argument." ;;
    esac
done



### FUNCTIONS ###

## Find the input device from the input event
function find_input_device_by_event {

    # Check if the event exists and is a character special file 
    test -c "$input_event" || err "input-event '$input_event' is not a character special file."

    # Extract the event filename from the path
    event=$(basename "$input_event")

    # Search for the device link to the event
    input_device=$(find /sys/devices -name "$event" 2>/dev/null | xargs dirname)

    # Check if an input device has been found
    if [[ -z "$input_device" ]]; then
        err "Cound not related input event."
    fi
}


## Find the input device from the input device by-path path
## First find the related input event
## Then find the related device from the event
function find_input_device_by_path {
    
    # Check if the by-path exists and is a symlink
    test -L "$input_by_path" || err "input-device-path '$input_by_path' is not a symbolic link"

    # Resolve symlink to canonically and recursively
    input_event=$(readlink -e "$input_by_path")

    # Check if an input_event is found
    test -n "$input_event" || err "Could not find related event for input device by-path"

    # Proceed to find the the input device from the event
    find_input_device_by_event
}


## Find the corresponding led
function find_led {
    led=$(find "$input_device" -name "*::$led_type" 2>/dev/null)
}


## Validate the path of the found led
function is_led_path_valid {
    test -d "$led" || err "Could not find '$led' directory."
    test -e "$led/brightness" || err "Cound not find '$led/brightness' regular file."
}



### SANITY CHECKS ###

## Check the script path
test -d "$script_path" || err "Script path '$script_path' does not exist."

if [ -z "$script_name" ]; then
    script_name="kbd_led_mon_$led_type.sh"
fi

## Try to find the corresponding led
case "$device_type" in
    event)
        input_event="$device"
        find_input_device_by_event 
        find_led
        ;;
    input)
        find_led
        ;;
    led) ;;
    path) 
        input_by_path="$device"
        find_input_device_by_path
        find_led
        ;;
    *) err "Device type: '$device_type' unknown."
esac

is_led_path_valid
led_brightness_filepath="$led/brightness"


### EXEC ###
set -e

script_filepath="$script_path/$script_name"
touch "$script_filepath"
chmod 750 "$script_filepath" 

# Overwrite any existing script with the this filepath
cat << SCRIPTEND > "$script_filepath"
#!/usr/bin/env bash

# Script generated by $0 the $(date "+%d/%m/%Y at %H:%M:%S")

while true; do
    led_status=\$(cat $led_brightness_filepath)
    read -r -d '' output <<EOF

SCRIPTEND

cat << 'SCRIPTEND' >> "$script_filepath"
{
    "text": "$led_status",
    "alt": "$led_status",
    "class": "$led_status"
}
EOF

echo $output | jq --unbuffered --compact-output
    sleep 1
done

SCRIPTEND


echo "Script generated at $script_filepath."

