#!/usr/bin/env bash
set -e

argin="$1"
if [[ "$argin" == "--help" || "$argin" == "-h" || "$argin" == "" ]]; then
    printf "Description: Edit the given DISK_IMAGE file dumped from the SD card of a Qingyun 1000 board.\n"
    printf "Usage: %s DISK_IMAGE | -h | --help\n" "$0"
    printf "    -h, --help    print this help and exit\n"
    printf "Examples:\n"
    printf "    %s qingyun1000.img\n" "$0"
    printf "    %s -h\n" "$0"
    printf "    %s --help\n" "$0"
    exit 0
elif [[ ! -f "$argin" ]]; then
    >&2 echo "The given disk image file '$argin' does not exist!"
    exit 1
fi
disk_img="$argin"

dep_pkgs="qemu-user-static"
echo "Check if $dep_pkgs exist..."
if [[ $(dpkg -l dep_pkgs &> /dev/null) -ne 0 ]]; then
    echo "$dep_pkgs not found. Please install them with the package manager."
    exit 1
fi
echo "[OK]"

echo "Finding the first unused loop device..."
echo "sudo permission is required."
loop_dev="$(sudo losetup -f)"
echo "[OK]"
echo "Associating loop device '$loop_dev' with image file '$disk_img'..."
sudo losetup --partscan "$loop_dev" "$disk_img"
echo "[OK]"

# try
set +e; ( set -e;

    echo "Getting the partition info of '$loop_dev'..."
    lsblk "$loop_dev"
    partitions_num=$(($(lsblk -pno NAME,MOUNTPOINT "$loop_dev" | grep -c ' ')-1))
    if [[ "$partitions_num" -ne 3 ]]; then
        >&2 echo "The given disk image file '$disk_img' must has 3 partitions!"
        exit 1
    fi

    root_mntpnt=$(mktemp -d)
    echo "Mounting '/' (${loop_dev}p1) partition to '$root_mntpnt'..."
    sudo mount "${loop_dev}p1" "$root_mntpnt"
    sudo mount --bind /dev  "${root_mntpnt}/dev"
    sudo mount --bind /sys  "${root_mntpnt}/sys"
    sudo mount --bind /proc "${root_mntpnt}/proc"
    sudo mount --bind /run  "${root_mntpnt}/run"
    echo "[OK]"

    copied_qemu=
    qemu_path=/usr/bin/qemu-aarch64-static
    if [[ ! -f "${root_mntpnt}/${qemu_path}" ]]; then
        sudo cp $qemu_path "${root_mntpnt}/${qemu_path}"
        copied_qemu=1
    fi

    # try
    set +e; ( set -e;

        cmd_after_chroot=" \
            set -e;
            . ~/.bashrc; \
            home_mntpnt=/home; \
            echo \"Mounting '/home' (${loop_dev}p3) partition to \$home_mntpnt...\"; \
            sudo mount \"${loop_dev}p3\" \"\$home_mntpnt\"; \
            echo \"[OK]\"; \
            echo \"========== Welcome to the inner world! ==========\"; \
            set +e; ( set -e; su -l HwHiAiUser ); set -e; \
            echo \"========== Goodbye from the inner world! ==========\"; \
            echo \"Unmounting '/home' (${loop_dev}p3) partition from \$home_mntpnt...\"; \
            umount \"\$home_mntpnt\"; \
            echo \"[OK]\"; \
            "
        sudo chroot "${root_mntpnt}" qemu-aarch64-static /bin/bash -c "$cmd_after_chroot"

    # catch
    ); set -e;

    echo "Unmounting '/' (${loop_dev}p1) partition from '$root_mntpnt'..."
    if [[ $copied_qemu -eq 1 ]]; then
        sudo rm -f "${root_mntpnt}/${qemu_path}"
    fi
    sudo umount "${root_mntpnt}/dev"
    sudo umount "${root_mntpnt}/sys"
    sudo umount "${root_mntpnt}/proc"
    sudo umount "${root_mntpnt}/run"
    sudo umount "$root_mntpnt"
    rm -rf "$root_mntpnt"
    echo "[OK]"

# catch
); set -e;

echo "Detaching loop device '$loop_dev' from image file '$disk_img'..."
sudo losetup -d "$loop_dev"
echo "[OK]"

echo "Script execution finished."
