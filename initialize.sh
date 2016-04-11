#!/usr/bin/env bash
set -e

# maximum number of tries to detect a running dokku
MAXCOUNT=120
# wait time between tries to detect a running dokku
SLEEPTIME=2

CHANNEL=${CHANNEL:=development}

trap "vagrant destroy -f" SIGINT SIGTERM EXIT

i=1
while true; do
    echo -e "\n\n$(date)\tSTARTING DROPLET\n\n"
    VAGRANT_RESULT=$(vagrant up --provider=aws)
    echo -e "\n\nINSTALLING PLATFORM CHANNEL ${CHANNEL}."

    CMDLINE="curl https://raw.githubusercontent.com/experimental-platform/platform-configure-script/master/platform-configure.sh | sudo CHANNEL=${CHANNEL} PLATFORM_INSTALL_REBOOT=true sh"
    vagrant ssh -c "${CMDLINE}" && echo -e "\n\nINSTALLATION SUCCESSFUL!\n" && break || echo -e "\n\nERROR status: $?\n"
    # try this only twice, more will timeout and forcefully quit by travis, which leaves running AWS instances behind.
    if [[ ${i} -gt 2 ]]; then
        echo -e "\n\n\nERROR: Couldn't install test platform.\n"
        exit 42
    fi
    i=$[$i+1]
    # TODO: re-enable after debug session # vagrant ssh -c "journalctl -x" || true
    echo -e "\n\n\nERROR DURING THE INSTALLATION OF PLATFORM CHANNEL ${CHANNEL} (${i}. time).\n"
    vagrant destroy -f
    echo -ne "Sleeping 10 seconds..."
    sleep 10
    echo -e " trying again."
done

COUNTER=0
while true ; do
    COUNTER=$((COUNTER + 1))
    sleep ${SLEEPTIME}
    HOSTIP=$(vagrant ssh-config | awk '/HostName/ {print $2}')
    echo -en "\n\n$(date)\t(${COUNTER}) Waiting for connection to ${HOSTIP}"
    nc -z $HOSTIP 8022  2>/dev/null | true
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        echo -e "\n\n$(date)\tDROPLET STATUS IS OKAY\n\n"
        break
    fi
    if [[ ${COUNTER} -gt ${MAXCOUNT} ]]; then
        echo -e "\n\n\n\n$(date)\tCONNECTION TIMEOUT... let's continue anyway...\n\n\n\n"
        break
    fi
done
