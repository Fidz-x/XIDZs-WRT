#!/bin/bash

. ./scripts/INCLUDE.sh

rename_firmware() {
    echo -e "${STEPS} Renaming firmware files..."

    # Validasi dan setup direktori
    local firmware_dir="$GITHUB_WORKSPACE/$WORKING_DIR/compiled_images"
    [[ ! -d "$firmware_dir" ]] && error_msg "Invalid firmware directory: ${firmware_dir}"
    cd "${firmware_dir}" || error_msg "Failed to change directory to ${firmware_dir}"

    # Set default values
    local op_base="${OP_BASE:-OpenWrt}"
    local branch="${BRANCH:-main}"
    local tunnel="${TUNNEL:-default}"
    local count=0

    # Pola pencarian dan penggantian (dioptimasi)
    declare -A patterns=(
        # Raspberry Pi
        ["-bcm27xx-bcm2710-rpi-3-ext4-factory"]="RaspberryPi_3B-Ext4_Factory"
        ["-bcm27xx-bcm2710-rpi-3-ext4-sysupgrade"]="RaspberryPi_3B-Ext4_Sysupgrade"
        ["-bcm27xx-bcm2710-rpi-3-squashfs-factory"]="RaspberryPi_3B-Squashfs_Factory"
        ["-bcm27xx-bcm2710-rpi-3-squashfs-sysupgrade"]="RaspberryPi_3B-Squashfs_Sysupgrade"
        ["-bcm27xx-bcm2711-rpi-4-ext4-factory"]="RaspberryPi_4B-Ext4_Factory"
        ["-bcm27xx-bcm2711-rpi-4-ext4-sysupgrade"]="RaspberryPi_4B-Ext4_Sysupgrade"
        ["-bcm27xx-bcm2711-rpi-4-squashfs-factory"]="RaspberryPi_4B-Squashfs_Factory"
        ["-bcm27xx-bcm2711-rpi-4-squashfs-sysupgrade"]="RaspberryPi_4B-Squashfs_Sysupgrade"
        ["-bcm27xx-bcm2712-rpi-5-ext4-factory"]="RaspberryPi_5-Ext4_Factory"
        ["-bcm27xx-bcm2712-rpi-5-ext4-sysupgrade"]="RaspberryPi_5-Ext4_Sysupgrade"
        ["-bcm27xx-bcm2712-rpi-5-squashfs-factory"]="RaspberryPi_5-Squashfs_Factory"
        ["-bcm27xx-bcm2712-rpi-5-squashfs-sysupgrade"]="RaspberryPi_5-Squashfs_Sysupgrade"
        
        # Orange Pi Allwinner
        ["-h5-orangepi-pc2-"]="OrangePi_PC2"
        ["-h5-orangepi-prime-"]="OrangePi_Prime"
        ["-h5-orangepi-zeroplus-"]="OrangePi_ZeroPlus"
        ["-h5-orangepi-zeroplus2-"]="OrangePi_ZeroPlus2"
        ["-h6-orangepi-1plus-"]="OrangePi_1Plus"
        ["-h6-orangepi-3-"]="OrangePi_3"
        ["-h6-orangepi-3lts-"]="OrangePi_3LTS"
        ["-h6-orangepi-lite2-"]="OrangePi_Lite2"
        ["-h616-orangepi-zero2-"]="OrangePi_Zero2"
        ["-h618-orangepi-zero2w-"]="OrangePi_Zero2W"
        ["-h618-orangepi-zero3-"]="OrangePi_Zero3"
        
        # Orange Pi Rockchip
        ["-rk3566-orangepi-3b-"]="OrangePi_3B"
        ["-rk3588s-orangepi-5-"]="OrangePi_5"
        
        # Orange Pi Official
        ["-xunlong_orangepi-r1-plus-lts-squashfs-sysupgrade"]="OrangePi-R1-Plus-LTS-squashfs"
        ["-xunlong_orangepi-r1-plus-lts-ext4-sysupgrade"]="OrangePi-R1-Plus-LTS-ext4"
        ["-xunlong_orangepi-r1-plus-squashfs-sysupgrade"]="OrangePi-R1-Plus-squashfs"
        ["-xunlong_orangepi-r1-plus-ext4-sysupgrade"]="OrangePi-R1-Plus-ext4"
        ["-xunlong_orangepi-pc2-squashfs-sdcard"]="OrangePi-PC2-squashfs"
        ["-xunlong_orangepi-pc2-ext4-sdcard"]="OrangePi-PC2-ext4"
        ["-xunlong_orangepi-zero-plus-squashfs-sdcard"]="OrangePi-Zero-Plus-squashfs"
        ["-xunlong_orangepi-zero-plus-ext4-sdcard"]="OrangePi-Zero-Plus-ext4"
        ["-xunlong_orangepi-zero2-squashfs-sdcard"]="OrangePi-Zero2-squashfs"
        ["-xunlong_orangepi-zero2-ext4-sdcard"]="OrangePi-Zero2-ext4"
        ["-xunlong_orangepi-zero3-squashfs-sdcard"]="OrangePi-Zero3-squashfs"
        ["-xunlong_orangepi-zero3-ext4-sdcard"]="OrangePi-Zero3-ext4"
        
        # NanoPi FriendlyARM
        ["-friendlyarm_nanopi-r2c-ext4-sysupgrade"]="NanoPi-R2C-ext4"
        ["-friendlyarm_nanopi-r2c-plus-ext4-sysupgrade"]="NanoPi-R2C-Plus-ext4"
        ["-friendlyarm_nanopi-r2s-ext4-sysupgrade"]="NanoPi-R2S-ext4"
        ["-friendlyarm_nanopi-r3s-ext4-sysupgrade"]="NanoPi-R3S-ext4"
        ["-friendlyarm_nanopi-r4s-ext4-sysupgrade"]="NanoPi-R4S-ext4"
        ["-friendlyarm_nanopi-r5s-ext4-sysupgrade"]="NanoPi-R5S-ext4"
        ["-friendlyarm_nanopi-r6s-ext4-sysupgrade"]="NanoPi-R6S-ext4"
        ["-friendlyarm_nanopi-neo2-ext4-sysupgrade"]="NanoPi-Neo2-ext4"
        ["-friendlyarm_nanopi-neo-plus2-ext4-sysupgrade"]="NanoPi-Neo-Plus2-ext4"
        ["-friendlyarm_nanopi-r1s-h5-ext4-sysupgrade"]="NanoPi-R1S-H5-ext4"
        ["-friendlyarm_nanopi-r2c-squashfs-sysupgrade"]="NanoPi-R2C-squashfs"
        ["-friendlyarm_nanopi-r2c-plus-squashfs-sysupgrade"]="NanoPi-R2C-Plus-squashfs"
        ["-friendlyarm_nanopi-r2s-squashfs-sysupgrade"]="NanoPi-R2S-squashfs"
        ["-friendlyarm_nanopi-r3s-squashfs-sysupgrade"]="NanoPi-R3S-squashfs"
        ["-friendlyarm_nanopi-r4s-squashfs-sysupgrade"]="NanoPi-R4S-squashfs"
        ["-friendlyarm_nanopi-r5s-squashfs-sysupgrade"]="NanoPi-R5S-squashfs"
        ["-friendlyarm_nanopi-r6s-squashfs-sysupgrade"]="NanoPi-R6S-squashfs"
        ["-friendlyarm_nanopi-neo2-squashfs-sysupgrade"]="NanoPi-Neo2-squashfs"
        ["-friendlyarm_nanopi-neo-plus2-squashfs-sysupgrade"]="NanoPi-Neo-Plus2-squashfs"
        ["-friendlyarm_nanopi-r1s-h5-squashfs-sysupgrade"]="NanoPi-R1S-H5-squashfs"
        
        # Firefly
        ["-firefly_roc-rk3328-cc-ext4-sysupgrade"]="Firefly-RK3328-CC-ext4"
        ["-firefly_roc-rk3328-cc-squashfs-sysupgrade"]="Firefly-RK3328-CC-squashfs"
        ["-firefly_roc-rk3328-cc-"]="Firefly-RK3328"
        
        # Amlogic
        ["_s905x_"]="Amlogic-S905X-HG680P"
        ["_s905x-b860h_"]="Amlogic-S905X-B860H"
        ["_s922x-gtking_"]="Amlogic-S922X-GtKing"
        ["_s922x_"]="Amlogic-S922X-GtKing-Pro"
        ["_s922x-gtkingpro-h_"]="Amlogic-S922X-GtKing-Pro-H"
        ["_s922x-ugoos-am6_"]="Amlogic-S922X-UGOOS-AM6-Plus"
        ["_s912-nexbox-a1_"]="Amlogic-S912-Nexbox-A1-A95X"
        ["_s912-nexbox-a2_"]="Amlogic-S912-Nexbox-A95X-A2"
        ["_s905l2_"]="Amlogic-S905L2-MGV-M301A"
        ["_s905x2-x96max-2g_"]="Amlogic-S905X2-X96Max-2GB"
        ["_s905x2_"]="Amlogic-S905X2-X96Max-4GB"
        ["_s905x2-b860h-v5_"]="Amlogic-S905X2-B860Hv5"
        ["_s905x2-hg680-fj_"]="Amlogic-S905X2-HG680-FJ"
        ["_s905x3-x96air_"]="Amlogic-S905X3-X96Air-100M"
        ["_s905x3-x96air-gb_"]="Amlogic-S905X3-X96Air-1Gb"
        ["_s905x3-hk1_"]="Amlogic-S905X3-HK1BOX"
        ["_s905x3_"]="Amlogic-S905X3-X96MAX-100M"
        ["_s905x3-x96max_"]="Amlogic-S905X3-X96MAX-1Gb"
        ["_s905x3-a95xf3-gb_"]="Amlogic-S905X3-A95XF3-1Gb"
        ["_s905x3-a95xf3_"]="Amlogic-S905X3-A95XF3-100M"
        ["_s905x3-x88-pro-x3_"]="Amlogic-S905X3-X88-Pro-X3"
        ["_s905x4-advan_"]="Amlogic-S905X4-Advan"
        ["_s905w_"]="Amlogic-S905W-TX3-Mini"
        ["_s905w-x96-mini_"]="Amlogic-S905W-X96-Mini"
        
        # x86_64
        ["x86-64-generic-ext4-combined-efi"]="X86_64-Generic-Ext4-Combined-EFI"
        ["x86-64-generic-ext4-combined"]="X86_64-Generic-Ext4-Combined"
        ["x86-64-generic-ext4-rootfs"]="X86_64-Generic-Ext4-Rootfs"
        ["x86-64-generic-squashfs-combined-efi"]="X86_64-Generic-Squashfs-Combined-EFI"
        ["x86-64-generic-squashfs-combined"]="X86_64-Generic-Squashfs-Combined"
        ["x86-64-generic-squashfs-rootfs"]="X86_64-Generic-Squashfs-Rootfs"
        ["x86-64-generic-rootfs"]="X86_64-Generic-Rootfs"
    )

    # Fungsi untuk extract kernel version
    get_kernel() {
        [[ "$1" =~ k[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)? ]] && echo "${BASH_REMATCH[0]}"
    }

    # Fungsi rename file
    rename_file() {
        local file="$1" search="$2" replace="$3"
        local kernel=$(get_kernel "$file")
        local ext="${file##*.}"
        [[ "$file" =~ \.tar\.gz$ ]] && ext="tar.gz"
        [[ "$file" =~ \.img\.gz$ ]] && ext="img.gz"
        
        local new_name="${op_base}-${branch}-${replace}"
        [[ -n "$kernel" ]] && new_name+="-${kernel}"
        new_name+="-${tunnel}-Build-By-Fidz_Xidz-X.${ext}"
        
        echo -e "${INFO} $file → $new_name"
        if mv "$file" "$new_name" 2>/dev/null; then
            ((count++))
        else
            echo -e "${WARN} Failed to rename $file"
        fi
    }

    # Proses rename dengan pattern matching
    for search in "${!patterns[@]}"; do
        replace="${patterns[$search]}"
        
        # Proses semua jenis file sekaligus
        for file in *"${search}"*.{img.gz,tar.gz,zip} *"${search}"*; do
            [[ -f "$file" ]] && rename_file "$file" "$search" "$replace"
        done
    done

    # Proses file yang tersisa (fallback)
    for file in *.{img.gz,tar.gz,zip}; do
        if [[ -f "$file" && ! "$file" =~ ^${op_base}-${branch}- ]]; then
            local base="${file%.*}"
            [[ "$file" =~ \.(tar|img)\.gz$ ]] && base="${file%.*.*}"
            local kernel=$(get_kernel "$file")
            local ext="${file##*.}"
            [[ "$file" =~ \.tar\.gz$ ]] && ext="tar.gz"
            [[ "$file" =~ \.img\.gz$ ]] && ext="img.gz"
            
            local new_name="${op_base}-${branch}-${base}"
            [[ -n "$kernel" ]] && new_name+="-${kernel}"
            new_name+="-${tunnel}-Build-By-Fidz_Xidz-X.${ext}"
            
            echo -e "${INFO} Fallback: $file → $new_name"
            mv "$file" "$new_name" 2>/dev/null && ((count++))
        fi
    done

    sync
    echo -e "${SUCCESS} Renamed $count files successfully!"
    
    # List hasil
    echo -e "${INFO} Final files:"
    ls -1 *.{img.gz,tar.gz,zip} 2>/dev/null | head -10
    [[ $(ls *.{img.gz,tar.gz,zip} 2>/dev/null | wc -l) -gt 10 ]] && echo -e "${INFO} ... and more"
}

# Jalankan fungsi
rename_firmware