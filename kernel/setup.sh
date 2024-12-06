#!/bin/sh
# copied from KernelSU repo

set -eu

GKI_ROOT=$(pwd)

display_usage() {
    echo "Usage: $0 [--cleanup | <integration-options>]"
    echo "  --cleanup:              Cleans up previous modifications made by the script."
    echo "  <integration-options>:   Tells us how MemKernel should be integrated into kernel source (Y, M)."
    echo "  <driver-name>:          Optional argument, should be used after <integration-options>. if not mentioned random name will be used."
    echo "  -h, --help:             Displays this usage information."
    echo "  (no args):              Sets up or updates the MemKernel environment to the latest commit (integration as Y)."
}

initialize_variables() {
    if test -d "$GKI_ROOT/common/drivers"; then
         DRIVER_DIR="$GKI_ROOT/common/drivers"
    elif test -d "$GKI_ROOT/drivers"; then
         DRIVER_DIR="$GKI_ROOT/drivers"
    else
        DRIVER_DIR=""
    fi

    DRIVER_MAKEFILE=$DRIVER_DIR/Makefile
    DRIVER_KCONFIG=$DRIVER_DIR/Kconfig
}

# Reverts modifications made by this script (for all integration Y, M)
perform_cleanup() {
    echo "[+] Cleaning up..."
    if [ -n "$DRIVER_DIR" ]; then
        [ -L "$DRIVER_DIR/memkernel" ] && rm "$DRIVER_DIR/memkernel" && echo "[-] Symlink removed."
        grep -q "memkernel" "$DRIVER_MAKEFILE" && sed -i '/memkernel/d' "$DRIVER_MAKEFILE" && echo "[-] Makefile reverted."
        grep -q "drivers/memkernel/Kconfig" "$DRIVER_KCONFIG" && sed -i '/drivers\/memkernel\/Kconfig/d' "$DRIVER_KCONFIG" && echo "[-] Kconfig reverted."
    fi
    [ -d "$GKI_ROOT/MemKernel" ] && rm -rf "$GKI_ROOT/MemKernel" && echo "[-] MemKernel directory deleted."
}


# Generates and inserts a random 6 char string to MemKernel/kernel/entry.c as driver device name
insert_random_dev_name() {
    local random_name
    if [ -n "${1:-}" ]; then
        random_name="$1"
    else
        random_name=$(tr -dc 'a-z' </dev/urandom | (head -c 6))
    fi
    sed -i "s/#define DEVICE_NAME \".*\"/#define DEVICE_NAME \"$random_name\"/" "$GKI_ROOT/MemKernel/kernel/entry.c"
    sed -i "s|#define DEVICE_NAME \"/dev/.*\"|#define DEVICE_NAME \"/dev/$random_name\"|" "$GKI_ROOT/MemKernel/user/driver.hpp"
    echo -e "\e[36mDevice Name: $random_name\e[0m"
}

# Sets up or update MemKernel environment for all integration (Y, M)
setup_memkernel() {
    if [ -z "$DRIVER_DIR" ]; then
        echo '[ERROR] "drivers/" directory not found.'
        exit 127;
    fi
    
    echo "[+] Setting up MemKernel..."
    test -d "$GKI_ROOT/MemKernel" || git clone https://github.com/Poko-Apps/MemKernel && echo "[+] Repository cloned."
    cd "$GKI_ROOT/MemKernel"
    git stash && echo "[-] Stashed current changes."
    git checkout main && echo "[-] Switched to main branch."
    git pull && echo "[+] Repository updated."
    git checkout main && echo "[-] Switched to main branch."

    if [ "$1" = "M" ]; then
        sed -i 's/default y/default m/' kernel/Kconfig
    elif [ "$1" != "Y" ]; then
        echo "[ERROR] First argument not valid. should be any of these: Y, M"
        exit 128;
    fi
    cd "$DRIVER_DIR"
    ln -sf "$(realpath --relative-to="$DRIVER_DIR" "$GKI_ROOT/MemKernel/kernel")" "memkernel" && echo "[+] Symlink created."

    # Add entries in Makefile and Kconfig if not already existing
    grep -q "memkernel" "$DRIVER_MAKEFILE" || printf "\nobj-\$(CONFIG_MEMKERNEL) += memkernel/\n" >> "$DRIVER_MAKEFILE" && echo "[+] Modified Makefile."
    grep -q "source \"drivers/memkernel/Kconfig\"" "$DRIVER_KCONFIG" || sed -i "/endmenu/i\source \"drivers/memkernel/Kconfig\"" "$DRIVER_KCONFIG" && echo "[+] Modified Kconfig."

    if [ "$#" -ge 2 ]; then
        insert_random_dev_name "$2"
    else
        insert_random_dev_name
    fi
    echo '[+] Done.'
}


# Process command-line arguments
if [ "$#" -eq 0 ]; then
    initialize_variables
    setup_memkernel Y
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    display_usage
elif [ "$1" = "--cleanup" ]; then
    initialize_variables
    perform_cleanup
else
    initialize_variables
    setup_memkernel "$@"
fi