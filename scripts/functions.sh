#!/bin/bash
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
     if [ ! -z "$res" ] && [ "$res" == "true" ]; then
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
#    askSelection <list> <message> <default>
#
# Result is stored in $dialogREPLY
dialogREPLY=""
function askSelection {
    selection=$1
    dialogREPLY=""
    default="$3"
    if [ "$(checkModule 'WITH_DIALOG')" ]; then
        selection=$(echo -e "$selection" | while read -r selected; do
                    selectedItem="${selected:0:1}"
                    selectedText="${selected:2}"
                    if [[ "${selected:0:1}" == "$default" ]]; then
                        echo "$selectedItem \"$selectedText\" on"
                    else
                        echo "$selectedItem \"$selectedText\" off"
                    fi
            done)
        echo "$selection" > /tmp/selectionList

        # shellcheck disable=SC2086
        dialog $dialogGlobalParams --radiolist "$2" 15 55 8  --file /tmp/selectionList 2> /tmp/res
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
            echo "$2"
            echo -------------------
            echo -e "$1"
            echo -------------------
            read -p "Selection:  " -n 1 -r
            echo ""
            if [[ "$REPLY" == "" ]] && [[ "$default" != "" ]]; then
                REPLY="$default"
                isValid=1
            else
                REPLY=$(echo "$REPLY" | awk '{print toupper($0)}')

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
