#!/usr/bin/env bash
# shellcheck disable=SC2034
true

dialogGlobalParams="--backtitle Installation --ascii-lines"
# Ask if module is to be enabled if not defined
#    askModule <Variable> <Description> [default answer]
function askModule {
    # Define standard behaviour (default yes)
    askPrompt="[Y/n]"
    nonDefaultMatch="Nn"
    defaultValue=true
    nonDefaultValue=false
    dialogParam=""

    # Define alternative behaviour (default no)
    if [ "$3" == "n" ]; then
        askPrompt="[y/N]"
        nonDefaultMatch="Yy"
        nonDefaultValue=true
        defaultValue=false
        dialogParam=" --defaultno "
    fi

    # This reads variable repersented by the string
    eval "res=\$$1"

    if [ "$(checkModule 'WITH_DIALOG')" ]; then
        if [ -z "$res" ] || [ "$res" != "true" ] && [ "$res" != "false" ]; then
            # Do not stop exec on non 0 return values
            set +e
            # shellcheck disable=SC2086
            dialog $dialogGlobalParams $dialogParam --title "$2" --yesno "Install $2?" 6 55
            response=$?
            # Return to previous setting
            set -e

            case $response in
                0) res="true";;
                1) res="false";;
                255) exit;;
        	esac
        fi
    else
        if [ -z "$res" ] || [ "$res" != "true" ] && [ "$res" != "false" ]; then
	
        # Clear buffer before asking
        read -t 1 -n 10000 discard || true

            read -p "Install $2 $askPrompt? " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[$nonDefaultMatch]$ ]]; then
                res=$nonDefaultValue
            else
                res=$defaultValue
            fi
        fi
    fi
    if [ "$res" == "true" ]; then
        echo -e "\e[1;32m$2 will be enabled\e[0m"
    else
        echo -e "\e[1;31m$2 will be skipped\e[0m"
    fi
    eval "$1=\$res"
}

# Check to see if module is enabled
#    checkModule <Variable>
function checkModule {
     eval "res=\$$1"
     if [ -n "$res" ] && [ "$res" == "true" ]; then
        echo "1"
    else
        echo ""
    fi
}

# Ask user to choose from a selection of items
# list is \n delimited. Each line formated as
#      "x text"
#       x - single capital character that will be returned
#       text - description of item
#
#    askSelection <list> <message>
#
# Result is stored in $dialogREPLY
dialogREPLY=""
function askSelection {
    selection=$2
    dialogREPLY=""
    if [ "$(checkModule 'WITH_DIALOG')" ]; then
    
    	# Clear buffer before asking
        read -t 1 -n 10000 discard || true
	
        selection=$(echo -e "$selection" | while read -r selected; do
                    selectedItem="${selected:0:1}"
                    selectedText="${selected:2}"
                    echo "$selectedItem \"$selectedText\""
            done)
        echo "$selection" > /tmp/selectionList

        # shellcheck disable=SC2086
        dialog $dialogGlobalParams --menu "$1" 15 55 8 --file /tmp/selectionList 2> /tmp/res
        rm -f selectionList
        response=$(cat /tmp/res)
        rm -f /tmp/res

        # Return if canceled
        if [[ "$response" == "" ]]; then
            exit 1
        fi

        # Set response variable
        dialogREPLY="$response"
    else
        isValid=""
        while [[ "$isValid" == "" ]]; do
	
            # Clear buffer before asking
            read -t 1 -n 10000 discard || true
	
            echo -e "$1"
            echo -------------------
            echo -e "$2"
            echo -------------------
            read -p "Selection:  " -n 1 -r
            echo ""
            if [[ ! "$REPLY" == "" ]]; then
                REPLY=$(echo "$REPLY" | awk '{print toupper($0)}')

                # Clear buffer before asking
	            read -t 1 -n 10000 discard || true
		
                isValid=$(echo -e "$selection" | while read -r selected; do
                    if [[ "${selected:0:1}" == "$REPLY" ]]; then
                        echo 1
                    fi
                done)
            fi
        done
        dialogREPLY="$REPLY"
    fi
}

function detectBoard {

    BOARD_MODEL="Unknown"
    BOARD_NAME="Unknown"
    BOARD_OS="Unknown"

    # Check for x86
    ARCH="$(uname -m)"
    case "$ARCH" in
    x86_64)
        BOARD_MODEL="amd64"
        BOARD_NAME="Generic AMD64"
    ;;
    i386 | i586 | i686 )
        BOARD_MODEL="i386"
        BOARD_NAME="Generic x86"
    esac

    if [[ "${BOARD_MODEL}" == "Unknown" ]]; then
        # Use tr to remove null byte generating warning
        if [ -f "/sys/firmware/devicetree/base/model" ]; then
            BOARD_NAME=$(tr -d '\0' < /sys/firmware/devicetree/base/model)
        else
            BOARD_NAME=$(grep Hardware /proc/cpuinfo | awk '{print $3}' | head -n 1)
        fi
    fi
    # Check for armbian identification
    if [ -f "/etc/armbian-image-release" ]; then
        BOARD_OS="Armbian"
        BOARD_MODEL="$(grep "BOARD=" /etc/armbian-image-release | awk -F '=' '{print $2}' | tr -d \")"
        BOARD_NAME="$(grep BOARD_NAME /etc/armbian-image-release | awk -F '=' '{print $2}' | tr -d \" )"
        BOARD_NEON=true
    fi
    if [[ "$BOARD_NAME" == "Raspberry Pi"* ]]; then
        BOARD_OS="Raspbian"
        # Check for default password is still set for user pi
        # If it is force password before reboot
        # shellcheck disable=SC2016
        if [[ "$BOARD_NAME" == "Raspberry Pi 4"* ]]; then
            BOARD_MODEL="raspberrypi4"
            BOARD_NEON=true
        fi
        if [[ "$BOARD_NAME" == "Raspberry Pi 3"* ]]; then
            BOARD_MODEL="raspberrypi3"
            BOARD_NEON=true
        fi
        if [[ "$BOARD_NAME" == "Raspberry Pi 2"* ]]; then
            BOARD_MODEL="raspberrypi2"
            BOARD_NEON=true
        fi
        if [[ "$BOARD_NAME" == "Raspberry Pi Model A"* || "$BOARD_NAME" == "Raspberry Pi Model B"* ]]; then
            BOARD_MODEL="raspberrypi1"
            BOARD_NEON=false
        fi
        if [[ "$BOARD_NAME" == *"Zero"* ]]; then
            BOARD_MODEL="raspberrypizero"
            BOARD_NEON=false
        fi
    fi
}
