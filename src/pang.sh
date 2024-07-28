#!/bin/sh

# POSIX ping wrapper

# Display:
#  - average ping
#  - stylized output


# TODO
# - display IP
# - display more informations
# - geolocation ?
# - set minimum connection timeout
# - in case of timeout drop connection and keep sequencing
# - ascii art

version="0.1"


if [ -z "$1" ]; then
    printf "error: need destination IP (ipv4).\n\n"
    exit 1
fi

 
if [ -z "$2" ]; then
    speed=0.1
else
    speed="$2"
fi


if [ "$3" = "geo" ]; then
    # Need to check if curl returns error or not
    geodata="$(curl -s -4 -L --url https://ipinfo.io/"$1" | tr -d '"{},' | cut -d ' ' -f3- | head -n -1)"
    
    hostname="$(echo "$geodata" | grep hostname | cut -d ':' -f2-)"
    city="$(echo "$geodata" | grep city | cut -d ':' -f2-)"
    region="$(echo "$geodata" | grep region | cut -d ':' -f2-)"
    country="$(echo "$geodata" | grep country | cut -d ':' -f2-)"
    loc="$(echo "$geodata" | grep loc | cut -d ':' -f2-)"
    org="$(echo "$geodata" | grep org | cut -d ':' -f2-)"
    postal="$(echo "$geodata" | grep postal | cut -d ':' -f2-)"
    timezone="$(echo "$geodata" | grep timezone | cut -d ':' -f2-)"

    
fi

# Will have to check for correct IP
destination="$1"

min=0
avg=0
max=0
total=0

seq=0

while true; do
    clear

    data="$(ping -c 1 "$destination")"

    seq=$((seq+1))
    
    # I have to remove the decimal
    time="$(echo "$data" | grep -m 1 -o 'time=.*' | cut -d '=' -f2 | cut -d '.' -f1)"
    total=$((total+time))

    if [ "$seq" -gt 1 ]; then
        if [ "$time" -lt "$min" ]; then
            min="$time"
        fi
        
        if [ "$time" -gt "$max" ]; then
            max="$time"
        fi

        avg=$((total/seq))
    else
        avg="$time"
        min="$time"
        max="$time"
    fi

    loss=$(echo "$data" | grep 'loss' | cut -d ',' -f3 | cut -d ' ' -f2-)


    printf "\n\n"
    
    printf "IP: %s\n\n" "$destination"

    printf "Seq: %s\n\n" "$seq"
    
    printf "Time: %s ms\n\n" "$time"
    
    printf "Min: %s ms\n" "$min"
    printf "Avg: %s ms\n" "$avg"
    printf "Max: %s ms\n" "$max"

    printf "\n"

    printf "Loss: %s\n" "$loss"
    
    printf "%s\n" "$geodata"
    

    printf "\n"

    sleep "$speed"

done
