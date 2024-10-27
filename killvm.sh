#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <VM_ID>"
    exit 1
}

# Check if VM ID is provided
if [ -z "$1" ]; then
    usage
fi

VM_ID=$1

# Identify the process ID holding the lock on the VM
LOCK_FILE="/var/lock/qemu-server/lock-$VM_ID.conf"
PID=$(fuser $LOCK_FILE 2>/dev/null)

if [ -z "$PID" ]; then
    echo "No process is holding the lock on VM $VM_ID."
    read -p "Do you want to proceed with killing the VM process and stopping the VM anyway? (y/n): " choice
    case "$choice" in
        y|Y ) echo "Proceeding with killing the VM process and stopping the VM.";;
        n|N ) echo "Exiting without making any changes."; exit 0;;
        * ) echo "Invalid input. Exiting."; exit 1;;
    esac
else
    echo "Process ID $PID is holding the lock on VM $VM_ID."
    # Kill the process
    kill $PID
    if [ $? -eq 0 ]; then
        echo "Successfully killed process $PID."
    else
        echo "Failed to kill process $PID."
        exit 1
    fi
fi

# Stop the VM
qm stop $VM_ID
if [ $? -eq 0 ]; then
    echo "Successfully stopped VM $VM_ID."
else
    echo "Failed to stop VM $VM_ID."
    exit 1
fi

echo "All tasks completed successfully."
