### Servers/Relays routes generator for DNSCrypt-proxy
### Generates routes to the dnscrypt-proxy.toml's format
### 
### routes = [
###     { server_name='anon-xxxx', via=['anon-aaaa', 'anon-dddd'] },
###     { server_name='anon-yyyy', via=['anon-cccc', 'anon-bbbb'] }
### ]

#!/usr/bin/env bash

#   Servers/Relays routes generator for DNSCrypt-proxy
#   Generates routes to the expected dnscrypt-proxy.toml's format from a list of relays
#
#   USAGE: serversRelaysRoutesDNSCrypt-proxy server1 server2 [server3 [server4] [...]]

### INIT ###
declare -r myname='serversRelaysRoutesDNSCrypt-proxy'
declare -r myver='1.0'

usage() {
    echo "${myname} v${myver}"
    echo
    echo "Servers/Relays routes generator for DNSCrypt-proxy"
    echo "Generates routes to the expected dnscrypt-proxy.toml's format from a list of relays"
    echo  
    echo "Usage: ${myname} server1 server2 [server3 [server4] [...]]"
    echo
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

getRandomRelay() {
    printf "%s\n" "${relaysList[$((RANDOM % relaysListLgth ))]}"
}

### VAR DECLARATION ###
declare -a relaysList
declare -a routes

# Retrieving relays
while [[ $1 ]]; do
    relaysList+=("$1")
    shift
done
relaysListLgth=${#relaysList[@]}
mapfile serversList < <(awk 'BEGIN { FPAT = "[a-z0-9._-]+" } { if ($1 ~ /^server_names/) { for (i= 2; i < NF; i++) { printf "%s\n", $i } } }' /etc/dnscrypt-proxy/dnscrypt-proxy.toml)

# Settings routes
printf "%s\n" "routes = [ "

for server in ${serversList[@]}; do
    randomRelays[0]=$(getRandomRelay) 
    randomRelays[1]=$(getRandomRelay)
    while [ "${randomRelays[0]}" = "${randomRelays[1]}" ]; do
        randomRelays[0]=$(getRandomRelay) 
        randomRelays[1]=$(getRandomRelay)
    done
    printf "%s" "   { server_name = '${server}', via=['${randomRelays[0]}', '${randomRelays[1]}'] }"
    if [ ! "${relay}" = "${relaysList[$((relaysListLgth - 1))]}" ]; then
        printf "%s\n" ", "
    else 
        printf "\n"
    fi
done
printf "%s\n" "]"
