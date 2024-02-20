#!/usr/bin/env bash
#######################################################################################
#                                                                                     #
#  Gentoo-Linux-Installer (GLI) v1.0.0 - Unofficial Installer for Gentoo Linux        #
#                                                                                     #
#  By                                                                                 #
#  WhitedonSAP (whitedon) - ayrtonarantes0987654321ayrt008@gmail.com                  #
#                                                                                     #
#######################################################################################

#################################### Colors ###########################################

#black="$(tput setaf 0)"
#blackb="$(tput bold ; tput setaf 0)"

### Advices/Errors
red="$(tput setaf 1)"
#redb="$(tput bold ; tput setaf 1)"

### Confirms/Success
green="$(tput setaf 2)"
#greenb="$(tput bold ; tput setaf 2)"

### Questions
yellow="$(tput setaf 3)"
#yellowb="$(tput bold ; tput setaf 3)"

### Default Text
blue="$(tput setaf 4)"
#blueb="$(tput bold ; tput setaf 4)"

### Steps
#magenta="$(tput setaf 5)"
magentab="$(tput bold ; tput setaf 5)"

### Options
cyan="$(tput setaf 6)"
#cyanb="$(tput bold ; tput setaf 6)"

#white="$(tput setaf 7)"
#whiteb="$(tput bold ; tput setaf 7)"

### NoColor
nc="$(tput sgr0)"

############################### Installer Variables ###################################

### Chroot path
glchroot='/mnt/gentoo'

### Disk select list
hddevsopts="$(lsblk | grep disk | awk '{print $1}')"

### CPU_FLAGS_x86 to the machine
cpuflagsselect="$(cpuid2cpuflags | cut -c 16-)"

### Check if Bios UEFI or Bios Legacy is actived
efivars="$(ls /sys/firmware/efi/efivars > /dev/null 2>&1; echo $?)"

### Mirror to download (Default the first mirror on GENTOO_MIRRORS flag)
mirrorselect="$(tail -1 /etc/portage/make.conf | awk '{print $1}' | cut -c 17- | sed 's/..$//')"

### Check if GENTOO_MIRRORS have https/http mirror
checkhttps="$(tail -1 /etc/portage/make.conf | grep -oE 'https|http' | awk 'NR==1')"

############################## Starting Installation ##################################

#######
clear
sleep 2
echo -e "\n${magentab}Welcome to Gentoo Linux Installer!!!${nc}\n"
sleep 2
#######

if [[ "$checkhttps" = 'https' ]]; then
  echo -e "\n${green}Mirrors https/http detected on make.conf!!!\nProcceding...${nc}"
else
  echo -e "\n${red}You have not selected one https or http mirror!!!\nAdd it with mirrorselect tool and execute the installer again...${nc}"
  if [[ $(grep -o 'GENTOO_MIRRORS' < /etc/portage/make.conf) != "" ]]; then
    sed -i '$d' /etc/portage/make.conf && sed -i '$d' /etc/portage/make.conf
    #tac /etc/portage/make.conf | sed '1,2d; 3s/,$//' | tac > tmp && mv tmp /etc/portage/make.conf
  fi
  exit
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Testing internet...${nc}\n"
sleep 2
#######

while true; do
  if ! curl -s https://www.google.com/ > /dev/null 2>&1
  then
    echo -e "\n${red}No Internet connection detected! Check your network settings and try again!${nc}"
    echo
    read -p "Connect to internet and press 'Enter' to try again"
    continue
  else
    echo -e "\n${green}Internet connection detected!!!${nc}"
    break
  fi
done

#######
#clear
sleep 2
echo -e "\n${magentab}Choose the Architecture...${nc}\n"
sleep 2
printf "\n${blue}
  ###################################################################
  #       #                                                         #
  # amd64 #         Architecture x86_64 (64 bits)                   #
  #       #                                                         #
  ###################################################################
  #       #                                                         #
  #  x86  #          Architecture x86 (32 bits)                     #
  #       #                                                         #
  ###################################################################\n\n${nc}"
echo -e "\n${yellow}Which Architecture would you like to use?${nc}"
echo
read -p "Amd64(a/A) or x86(x/X): " archselect
if [ "$archselect" = 'amd64' ] || [ "$archselect" = 'a' ]; then
  stage_arch='x86_64 (64 bits)'
elif [ "$archselect" = 'x86' ] || [ "$archselect" = 'x' ]; then
  stage_arch='x86 (32 bits)'
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Choose the System Init...${nc}\n"
sleep 2
printf "\n${blue}
  ###################################################################
  #         #                                                       #
  # OpenRC  #               System Init OpenRC                      #
  #         #                                                       #
  ###################################################################
  #         #                                                       #
  # Systemd #               System Init Systemd                     #
  #         #                                                       #
  ###################################################################\n\n${nc}"
echo -e "\n${yellow}Which System Init would you like to use?${nc}"
echo
read -p "OpenRC(o/O) or Systemd(s/S): " initselect
if [ "$initselect" = 'o' ] || [ "$initselect" = 'O' ]; then
  stage_init='openrc'
elif [ "$initselect" = 's' ] || [ "$initselect" = 'S' ]; then
  stage_init='systemd'
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Choose the Stage3...${nc}\n"
sleep 2

if [ "$stage_arch" = 'x86_64 (64 bits)' ] && [ "$stage_init" = 'openrc' ]; then
  printf "\n${blue}
  ###################################################################
  #                Architecture x86_64 (64 bits)                    #
  #                           OpenRC                                #
  ###################################################################
  #                     Stages for Glibc/GCC                        #
  #-----------------------------------------------------------------#
  # 1)  Stage3 amd64 - OpenRC/Glibc/GCC                             #
  # 2)  Stage3 amd64 Desktop - OpenRC/Glibc/GCC                     #
  # 3)  Stage3 amd64 NoMultilib - OpenRC/Glibc/GCC                  #
  # 4)  Stage3 amd64 x32 - OpenRC/Glibc/GCC                         #
  # 5)  Stage3 amd64 Hardened - OpenRC/Glibc/GCC                    #
  # 6)  Stage3 amd64 NoMultilib Hardened - OpenRC/Glibc/GCC         #
  # 7)  Stage3 amd64 Hardened SELinux - OpenRC/Glibc/GCC            #
  # 8)  Stage3 amd64 NoMultilib Hardened SELinux - OpenRC/Glibc/GCC #
  #-----------------------------------------------------------------#
  #                    Stages for Glibc/LLVM                        #
  #-----------------------------------------------------------------#
  # 9)  Stage3 amd64 - OpenRC/Glibc/LLVM                            #
  #-----------------------------------------------------------------#
  #                    Stages for Musl/GCC                          #
  #-----------------------------------------------------------------#
  # 10) Stage3 amd64 - OpenRC/Musl/GCC                              #
  # 11) Stage3 amd64 Hardened - OpenRC/Musl/GCC                     #
  #-----------------------------------------------------------------#
  #                    Stages for Musl/LLVM                         #
  #-----------------------------------------------------------------#
  # 12) Stage3 amd64 - OpenRC/Musl/LLVM                             #
  ###################################################################\n\n${nc}"
elif [ "$stage_arch" = 'x86_64 (64 bits)' ] && [ "$stage_init" = 'systemd' ]; then
  printf "\n${blue}
  ###################################################################
  #                Architecture x86_64 (64 bits)                    #
  #                           Systemd                               #
  ###################################################################
  #                    Stages for Glibc/GCC                         #
  #-----------------------------------------------------------------#
  # 13)  Stage3 amd64 - Systemd/Glibc/GCC                           #
  # 14)  Stage3 amd64 Desktop - Systemd/Glibc/GCC                   #
  # 15)  Stage3 amd64 Mergedusr - Systemd/Glibc/GCC                 #
  # 16)  Stage3 amd64 Desktop Mergedusr - Systemd/Glibc/GCC         #
  # 17)  Stage3 amd64 x32 - Systemd/Glibc/GCC                       #
  # 18)  Stage3 amd64 x32 Mergedusr - Systemd/Glibc/GCC             #
  # 19)  Stage3 amd64 NoMultilib - Systemd/Glibc/GCC                #
  # 20)  Stage3 amd64 NoMultilib Mergedusr - Systemd/Glibc/GCC      #
  #-----------------------------------------------------------------#
  #                    Stages for Glibc/LLVM                        #
  #-----------------------------------------------------------------#
  # 21)  Stage3 amd64 - Systemd/Glibc/LLVM                          #
  # 22) Stage3 amd64 Mergedusr - Systemd/Glibc/LLVM                 #
  ###################################################################\n\n${nc}"
elif [ "$stage_arch" = 'x86 (32 bits)' ] && [ "$stage_init" = 'openrc' ]; then
  printf "\n${blue}
  ###################################################################
  #                Architecture x86 (32 bits)                       #
  #                           OpenRC                                #
  ###################################################################
  #                     Stages for Glibc/GCC                        #
  #-----------------------------------------------------------------#
  # 23) Stage3 x86-i486 - OpenRC/Glibc/GCC                          #
  # 24) Stage3 x86-i686 - OpenRC/Glibc/GCC                          #
  # 25) Stage3 x86-i686 Hardened - OpenRC/Glibc/GCC                 #
  #-----------------------------------------------------------------#
  #                     Stages for Musl/GCC                         #
  #-----------------------------------------------------------------#
  # 26) Stage3 x86-i686 - OpenRC/Musl/GCC                           #
  ###################################################################\n\n${nc}"
elif [ "$stage_arch" = 'x86 (32 bits)' ] && [ "$stage_init" = 'systemd' ]; then
  printf "\n${blue}
  ###################################################################
  #                Architecture x86 (32 bits)                       #
  #                           Systemd                               #
  ###################################################################
  #                   Stages for Glibc/GCC                          #
  #-----------------------------------------------------------------#
  # 27) Stage3 x86-i486 - Systemd/Glibc/GCC                         #
  # 28) Stage3 x86-i486 Mergedusr - Systemd/Glibc/GCC               #
  # 29) Stage3 x86-i686 - Systemd/Glibc/GCC                         #
  # 30) Stage3 x86-i686 Mergedusr - Systemd/Glibc/GCC               #
  ###################################################################\n\n${nc}"
fi

read -p "Enter your option: " stageselect
echo -e "\n${green}Stage selected, continuing...${nc}"

#######
#clear
sleep 2
echo -e "\n${magentab}Choose the device...${nc}\n"
sleep 2
#######

for i in $hddevsopts
do
  echo " >>> ${i}"
done
echo
read -p "Choose the device: " hddevselect
if echo "$hddevsopts" | grep "\<$hddevselect\>" > /dev/null 2>&1; then
  hddevselect="/dev/$hddevselect"
fi
echo -e "\n${green}Device ${hddevselect} selected!!!${nc}"

#######
#clear
sleep 2
echo -e "\n${magentab}Create the partitions...${nc}\n"
sleep 2
#######

echo -e "\n${blue}To continue, have the partitions according to the following scheme:${nc}"
sleep 2

if [ "$efivars" -eq '0' ]; then
  echo -e "\n${green}Bios UEFI detected!!!${nc}"
  boot_mode="uefi"
  echo -e "\n\n${cyan}EFI partition (if it doesn't exist)${nc} ${red}------>${nc} ${cyan}EF00 +256M${nc}"
else
  echo -e "\n${green}Bios Legacy detected!!!${nc}"
  boot_mode="legacy"
  echo -e "\n${yellow}Would you like to use MBR or GPT partition scheme?${nc}"
  echo
  read -p "MBR(m) or GPT(g)? " partitionscheme
  if [ "$partitionscheme" = 'M' ] || [ "$partitionscheme" = 'm' ]; then
    echo -e "\n${blue}For MBR scheme:${nc}"
    echo -e "\n\n${cyan}Bios boot partition${nc} ${red}---------------------->${nc} ${cyan}EF02 +1M${nc}"
    echo -e "\n${cyan}System Boot partition${nc} ${red}-------------------->${nc} ${cyan}8300 +256M${nc}"
  elif [ "$partitionscheme" = 'G' ] || [ "$partitionscheme" = 'g' ]; then
    echo -e "\n${blue}For GPT scheme:${nc}"
    echo -e "\n\n${cyan}System Boot partition${nc} ${red}-------------------->${nc} ${cyan}8300 +256M${nc}"
  fi
fi
echo -e "\n${cyan}Swap partition${nc} ${red}--------------------------->${nc} ${cyan}8200 +(Your ram memory/2)${nc}"
echo -e "\n${cyan}System Root partition${nc} ${red}-------------------->${nc} ${cyan}8300 +(You decide the disk space)${nc}"
sleep 2

echo -e "\n\n${yellow}Would you like to create the partitions with cfdisk?${nc} ${red}(not necessary if they already exist)${nc}"
sleep 2
echo
read -p "Yes(y) or No(n)? " createpartselect
if [ "$createpartselect" = 'Y' ] || [ "$createpartselect" = 'y' ]; then
  echo -e "\n${yellow}Start with an in-memory zeroed partition table?${nc} ${red}('No' for keep partitions scheme)${nc}"
  echo
  read -p "Yes(y) or No(n)? " zeropartselect
  if [ "$zeropartselect" = 'Y' ] || [ "$zeropartselect" = 'y' ]; then
    sleep 2
    cfdisk -z "$hddevselect"
    sync
  elif [ "$zeropartselect" = 'N' ] || [ "$zeropartselect" = 'n' ]; then
    sleep 2
    cfdisk "$hddevselect"
    sync
  fi
fi
sleep 2

if [ "$boot_mode" = 'uefi' ] && ! [[ $(fdisk -l "$hddevselect" -o type | grep -i 'EFI') ]]; then
  echo -e "\n${red}You are booting in UEFI mode but not EFI partition was created, make sure you select the EFI System type for your EFI partition!!!${nc}"
  sleep 2
  cfdisk "$hddevselect"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Set up the partitions...${nc}\n"
sleep 2
#######

echo -e "\n${blue}Now configure the partitions:${nc}"
echo
fdisk -l "$hddevselect"
echo
sleep 2
if [ "$boot_mode" = 'uefi' ]; then
  echo -e "\n${blue}Type the EFI partition:${nc}"
  echo
  read -p "--->>> " efi_part
elif [ "$boot_mode" = 'legacy' ]; then
  echo -e "\n${blue}Type the Boot partition:${nc}"
  echo
  read -p "--->>> " boot_part
fi
sleep 2
echo -e "\n${blue}Type the Swap partition (or none):${nc}"
echo
read -p "--->>> " swap_part
sleep 2
echo -e "\n${blue}Type the Root partition:${nc}"
echo
read -p "--->>> " root_part

#######
#clear
sleep 2
echo -e "\n${magentab}Formatting partitions...${nc}\n"
sleep 2
#######

echo -e "\n${yellow}What file system would you like to use?${nc}"
echo -e "\n\n${cyan}--->>> ext4\n\n--->>> xfs\n\n--->>> jfs\n\n--->>> f2fs\n\n--->>> btrfs${nc}"
echo
read -p "Type the filesystem name: " filesystemselect

if [ "$boot_mode" = 'uefi' ]; then
  echo -e "\n${blue}Do you want to format EFI partition?${nc} ${red}(Do not do this if you already have another system installed!!!)${nc}"
  echo
  read -p "Yes(y) or No(n)? " efiformat
  if [ "$efiformat" = 'Y' ] || [ "$efiformat" = 'y' ]; then
    echo
    mkfs.fat -c -F 32 "$efi_part"
  elif [ "$efiformat" = 'N' ] || [ "$efiformat" = 'n' ]; then
    echo -e "\n${green}Not formatting EFI partition!!!${nc}"
  fi
elif [ "$boot_mode" = 'legacy' ]; then
  echo
  if [ "$filesystemselect" = 'ext4' ] || [ "$filesystemselect" = 'xfs' ] || [ "$filesystemselect" = 'jfs' ] || [ "$filesystemselect" = 'f2fs' ]; then
    mkfs.ext4 -c -F "$boot_part"
  elif [ "$filesystemselect" = 'btrfs' ]; then
    mkfs.btrfs -f "$boot_part"
  fi
fi
echo
if [ "$swap_part" != 'none' ]; then
  mkswap -c "$swap_part"
  swapon "$swap_part"
fi
echo
if [ "$filesystemselect" = 'ext4' ]; then
  mkfs.ext4 -c -L "Gentoo Linux" -F "$root_part"
elif [ "$filesystemselect" = 'xfs' ]; then
  mkfs.xfs -L "Gentoo Linux" -f "$root_part"
elif [ "$filesystemselect" = 'jfs' ]; then
  mkfs.jfs -q -c -L "Gentoo Linux" "$root_part"
elif [ "$filesystemselect" = 'f2fs' ]; then
  mkfs.f2fs -l "Gentoo Linux" -f "$root_part"
elif [ "$filesystemselect" = 'btrfs' ]; then
  mkfs.btrfs -L "Gentoo Linux" -f "$root_part"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Configuring mount points and mounting partitions...${nc}\n"
sleep 2
#######

if [[ $(ls "$glchroot" > /dev/null 2>&1) = "$glchroot" ]]; then
  echo -e "\n${green}Directory $glchroot detected!!!${nc}"
  sleep 2
else
  echo -e "\n${green}Directory $glchroot not detected!!!\nCreating it...${nc}"
  sleep 2
  mkdir -p "$glchroot"
fi

if [ "$filesystemselect" = 'ext4' ] || [ "$filesystemselect" = 'xfs' ] || \
[ "$filesystemselect" = 'jfs' ] || [ "$filesystemselect" = 'f2fs' ]; then
  if [ "$boot_mode" = 'uefi' ]; then
    mount "$root_part" "$glchroot"
  else
    mount "$root_part" "$glchroot"
    mkdir -p "$glchroot/boot"
    mount "$boot_part" "$glchroot/boot"
  fi
elif [ "$filesystemselect" = 'btrfs' ]; then
  mount "$root_part" "$glchroot"
  if [ "$boot_mode" = 'uefi' ]; then
    btrfs subvol create "$glchroot/@"
    btrfs subvol create "$glchroot/@home"
    umount -lR "$glchroot"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@ "$root_part" "$glchroot"
    mkdir -p "$glchroot"/{boot/efi,home}
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@home "$root_part" "$glchroot/home"
    mount "$efi_part" "$glchroot/boot/efi"
  elif [ "$boot_mode" = 'legacy' ]; then
    btrfs subvol create "$glchroot/@"
    btrfs subvol create "$glchroot/@home"
    umount -lR "$glchroot"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@ "$root_part" "$glchroot"
    mkdir -p "$glchroot"/{boot,home}
    mount -t btrfs -o defaults,noatime,compress=zstd "$boot_part" "$glchroot/boot"
    mount -t btrfs -o defaults,noatime,compress=zstd,subvol=@home "$root_part" "$glchroot/home"
  fi
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Downloading and extracting Gentoo stage3...${nc}\n"
sleep 2
#######

cd "$glchroot"

### x86_64 (64 bits) OpenRC/Glibc/GCC
if [ "$stageselect" = '1' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '2' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-desktop-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '3' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-nomultilib-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-nomultilib-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '4' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-x32-openrc/"
  wget -r -nd --no-parent -A 'stage3-x32-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '5' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-hardened-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-hardened-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '6' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-hardened-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-hardened-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '7' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-hardened-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-hardened-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '8' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-hardened-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-hardened-openrc-*.tar.xz*' "$stagelink"
fi

### x86_64 (64 bits) OpenRC/Glibc/LLVM
if [ "$stageselect" = '9' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-llvm-openrc/"
  wget -r -nd --no-parent -A 'stage3-amd64-llvm-openrc*.tar.xz*' "$stagelink"
fi

### x86_64 (64 bits) OpenRC/Musl/GCC
if [ "$stageselect" = '10' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-musl/"
  wget -r -nd --no-parent -A 'stage3-amd64-musl-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '11' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-musl-hardened/"
  wget -r -nd --no-parent -A 'stage3-amd64-musl-hardened-*.tar.xz*' "$stagelink"
fi

### x86_64 (64 bits) OpenRC/Musl/LLVM
if [ "$stageselect" = '12' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-musl-llvm/"
  wget -r -nd --no-parent -A 'stage3-amd64-musl-llvm-*.tar.xz*' "$stagelink"
fi

### x86_64 (64 bits) Systemd/Glibc/GCC
if [ "$stageselect" = '13' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-systemd/"
  wget -r -nd --no-parent -A 'stage3-amd64-systemd-[0-9]*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '14' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd/"
  wget -r -nd --no-parent -A 'stage3-amd64-desktop-systemd-[0-9]*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '15' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-systemd-mergedusr/"
  wget -r -nd --no-parent -A 'stage3-amd64-systemd-mergedusr-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '16' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-desktop-systemd-mergedusr/"
  wget -r -nd --no-parent -A 'stage3-amd64-desktop-systemd-mergedusr-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '17' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-x32-systemd/"
  wget -r -nd --no-parent -A 'stage3-x32-systemd-[0-9]*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '18' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-x32-systemd-mergedusr/"
  wget -r -nd --no-parent -A 'stage3-x32-systemd-mergedusr-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '19' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-nomultilib-systemd/"
  wget -r -nd --no-parent -A 'stage3-amd64-nomultilib-systemd-[0-9]*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '20' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-nomultilib-systemd-mergedusr/"
  wget -r -nd --no-parent -A 'stage3-amd64-nomultilib-systemd-mergedusr-*.tar.xz*' "$stagelink"
fi

### x86_64 (64 bits) Systemd/Glibc/LLVM
if [ "$stageselect" = '21' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-llvm-systemd/"
  wget -r -nd --no-parent -A 'stage3-amd64-llvm-systemd-[0-9]*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '22' ]; then
  stagelink="$mirrorselect/releases/amd64/autobuilds/current-stage3-amd64-llvm-systemd-mergedusr/"
  wget -r -nd --no-parent -A 'stage3-amd64-llvm-systemd-mergedusr-*.tar.xz*' "$stagelink"
fi

### x86 (32 bits) OpenRC/Glibc/GCC
if [ "$stageselect" = '23' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i486-openrc/"
  wget -r -nd --no-parent -A 'stage3-i486-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '24' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i686-openrc/"
  wget -r -nd --no-parent -A 'stage3-i686-openrc-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '25' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i686-hardened-openrc/"
  wget -r -nd --no-parent -A 'stage3-i686-hardened-openrc-*.tar.xz*' "$stagelink"
fi

### x86 (32 bits) OpenRC/Musl/GCC
if [ "$stageselect" = '26' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i686-musl/"
  wget -r -nd --no-parent -A 'stage3-i686-musl-*.tar.xz*' "$stagelink"
fi

### x86 (32 bits) Systemd/Glibc/GCC
if [ "$stageselect" = '27' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i486-systemd/"
  wget -r -nd --no-parent -A 'stage3-i486-systemd-[0-9]*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '28' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i486-systemd-mergedusr/"
  wget -r -nd --no-parent -A 'stage3-i486-systemd-mergedusr-*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '29' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i686-systemd/"
  wget -r -nd --no-parent -A 'stage3-i686-systemd-[0-9]*.tar.xz*' "$stagelink"
elif [ "$stageselect" = '30' ]; then
  stagelink="$mirrorselect/releases/x86/autobuilds/current-stage3-i686-systemd-mergedusr/"
  wget -r -nd --no-parent -A 'stage3-i686-systemd-mergedusr-*.tar.xz*' "$stagelink"
fi

echo -e "\n${blue}Downloading gpg key from gentoo.org...${nc}\n"
wget -O - https://qa-reports.gentoo.org/output/service-keys.gpg | gpg --quiet --import
echo
gpg --verify --output - stage3-*.tar.xz.sha256 | sha256sum -c
echo -e "\n${blue}Extracting Gentoo Stage3...${nc} ${red}(Wait a while)${nc}"
tar xpf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
rm -rf stage3-*.tar.xz*
cd - > /dev/null 2>&1
echo -e "\n${green}Stage installed with Sucessfull!!!${nc}"

#######
#clear
sleep 2
echo -e "\n${magentab}Copying files...${nc}\n"
sleep 2
#######

mkdir -p "$glchroot/etc/portage/repos.conf"
cp "$glchroot/usr/share/portage/config/repos.conf" "$glchroot/etc/portage/repos.conf/gentoo.conf"
cp --dereference /etc/resolv.conf "$glchroot/etc/"

if [ "$stage_init" = 'openrc' ]; then
  cp openrc/make.conf "$glchroot/etc/portage/make.conf"
elif [ "$stage_init" = 'systemd' ]; then
  cp systemd/make.conf "$glchroot/etc/portage/make.conf"
fi
tail -1 /etc/portage/make.conf >> "$glchroot/etc/portage/make.conf"

#######
#clear
sleep 2
echo -e "\n${magentab}Configuring make.conf...${nc}\n"
sleep 2
#######

if [[ $(uname -m) = 'x86_64' ]]; then
  archformirror='amd64'
  sed -i 's/xACCEPT_KEYWORDSx/amd64/' "$glchroot/etc/portage/make.conf"
  sed -i 's/xCHOSTx/x86_64/' "$glchroot/etc/portage/make.conf"
elif [[ $(uname -m) = 'i486' ]] || [[ $(uname -m) = 'i686' ]]; then
  archformirror='x86'
  sed -i 's/xACCEPT_KEYWORDSx/x86/' "$glchroot/etc/portage/make.conf"
  if [[ $(uname -m) = 'i486' ]]; then
    sed -i 's/xCHOSTx/i486-pc-linux-gnu/' "$glchroot/etc/portage/make.conf"
  elif [[ $(uname -m) = 'i686' ]]; then
    sed -i 's/xCHOSTx/i686-pc-linux-gnu/' "$glchroot/etc/portage/make.conf"
  fi
fi

sed -i 's/xCPU_FLAGS_X86x/'"$cpuflagsselect"'/' "$glchroot/etc/portage/make.conf"
sed -i 's/xMAKEOPTSx/'"$(nproc)"'/' "$glchroot/etc/portage/make.conf"

if [[ $(lspci | grep VGA | awk 'NR==1{print $5, $6}') = 'Intel Corporation' ]] || [[ $(lspci | grep VGA | awk 'NR==2{print $5, $6}') = 'Intel Corporation' ]]; then
  cpu_microcode='intel-microcode'
  echo -e "\n${green}Intel CPU detected!!!${nc}"
  if [[ $(lspci | grep VGA | awk 'NR==1{print $5, $6}') = 'NVIDIA Corporation' ]] || [[ $(lspci | grep VGA | awk 'NR==2{print $5, $6}') = 'NVIDIA Corporation' ]]; then
    echo -e "\n${green}Nvidia GPU detected!!!${nc}"
    echo -e "\n${yellow}Which Nvidia drivers would you like to use?${nc}"
    echo
    read -p "Open Source(o) or Proprietary(p): " videocardsselect
    if [ "$videocardsselect" = 'O' ] || [ "$videocardsselect" = 'o' ]; then
      echo -e "\n${green}Adding Intel CPU and NVIDIA GPU Open Source driver to make.conf...${nc}"
      sed -i 's/xVIDEO_CARDSx/intel nouveau/' "$glchroot/etc/portage/make.conf"
    elif [ "$videocardsselect" = 'P' ] || [ "$videocardsselect" = 'p' ]; then
      echo -e "\n${green}Adding Intel CPU and NVIDIA GPU Proprietary driver to make.conf...${nc}"
      sed -i 's/xVIDEO_CARDSx/intel nvidia/' "$glchroot/etc/portage/make.conf"
    fi
  elif [[ $(lspci | grep VGA | awk 'NR==1{print $5, $6, $7}') = 'Advanced Micro Devices,' ]] || [[ $(lspci | grep VGA | awk 'NR==2{print $5, $6, $7}') = 'Advanced Micro Devices,' ]]; then
    echo -e "\n${green}AMD GPU detected!!!${nc}"
    echo -e "\n${green}Adding Intel CPU and AMD GPU driver to make.conf...${nc}"
    sed -i 's/xVIDEO_CARDSx/intel amdgpu/' "$glchroot/etc/portage/make.conf"
  else
    echo -e "\n${green}No dedicated GPU detected, just adding Intel CPU to make.conf...${nc}"
    sed -i 's/xVIDEO_CARDSx/intel/' "$glchroot/etc/portage/make.conf"
  fi
elif [[ $(lspci | grep VGA | awk 'NR==1{print $5, $6, $7}') = 'Advanced Micro Devices,' ]] || [[ $(lspci | grep VGA | awk 'NR==2{print $5, $6, $7}') = 'Advanced Micro Devices,' ]]; then
  echo -e "\n${green}AMD CPU detected!!!${nc}"
  if [[ $(lspci | grep VGA | awk 'NR==1{print $5, $6}') = 'NVIDIA Corporation' ]] || [[ $(lspci | grep VGA | awk 'NR==2{print $5, $6}') = 'NVIDIA Corporation' ]]; then
    echo -e "\n${green}Nvidia GPU detected!!!${nc}"
    echo -e "\n${yellow}Which Nvidia drivers would you like to use?${nc}"
    echo
    read -p "Open Source(o) or Proprietary(p): " videocardsselect
    if [ "$videocardsselect" = 'O' ] || [ "$videocardsselect" = 'o' ]; then
      echo -e "\n${green}Adding AMD CPU and NVIDIA GPU Open Source driver to make.conf...${nc}"
      sed -i 's/xVIDEO_CARDSx/radeon radeonsi nouveau/' "$glchroot/etc/portage/make.conf"
    elif [ "$videocardsselect" = 'P' ] || [ "$videocardsselect" = 'p' ]; then
      echo -e "\n${green}Adding AMD CPU and NVIDIA GPU Proprietary driver to make.conf...${nc}"
      sed -i 's/xVIDEO_CARDSx/radeon radeonsi nvidia/' "$glchroot/etc/portage/make.conf"
    fi
  elif [[ $(lspci | grep VGA | awk 'NR==1{print $5, $6, $7}') = 'Advanced Micro Devices,' ]] && [[ $(lspci | grep VGA | awk 'NR==2{print $5, $6, $7}') = 'Advanced Micro Devices,' ]]; then
    echo -e "\n${cyan}AMD dedicated GPU detected!!!${nc}"
    echo -e "\n${green}Adding AMD CPU and AMD GPU driver to make.conf...${nc}"
    sed -i 's/xVIDEO_CARDSx/amdgpu radeon radeonsi/' "$glchroot/etc/portage/make.conf"
  else
    echo -e "\n${green}No dedicated GPU detected, adding AMD CPU and AMD integrated GPU to make.conf...${nc}"
    sed -i 's/xVIDEO_CARDSx/amdgpu radeon radeonsi/' "$glchroot/etc/portage/make.conf"
  fi
else
  echo -e "\n${green}A virtual machine has been detected!!! Adding to make.conf...${nc}"
  sed -i 's/xVIDEO_CARDSx/vmware virtualbox/' "$glchroot/etc/portage/make.conf"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Generating fstab...${nc}\n"
sleep 2
#######

echo -e "### File generated by genfstab\n" > "$glchroot/etc/fstab"

if [ "$boot_mode" = 'uefi' ]; then
  genfstab -U "$glchroot" >> "$glchroot/etc/fstab"
elif [ "$boot_mode" = 'legacy' ]; then
  genfstab -L "$glchroot" >> "$glchroot/etc/fstab"
fi

# remove subvolid for work with snapshots
if [ "$filesystemselect" = 'btrfs' ]; then
  sed -i 's/,subvolid=\<[0-9]*\>//g' "$glchroot/etc/fstab"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Mounting partitions...${nc}\n"
sleep 2
#######

if [ "$stage_init" = 'openrc' ]; then
  mount --types proc /proc "$glchroot/proc"
  mount --rbind /sys "$glchroot/sys"
  mount --rbind /dev "$glchroot/dev"
  mount --bind /run "$glchroot/run"
elif [ "$stage_init" = 'systemd' ]; then
  mount --types proc /proc "$glchroot/proc"
  mount --rbind /sys "$glchroot/sys"
  mount --make-rslave "$glchroot/sys"
  mount --rbind /dev "$glchroot/dev"
  mount --make-rslave "$glchroot/dev"
  mount --bind /run "$glchroot/run"
  mount --make-slave "$glchroot/run"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Downloading portage tree...${nc}\n\n"
sleep 2
#######

chroot "$glchroot" emerge-webrsync

echo -e "\n${yellow}Do you want to update the Gentoo ebuild repository to the latest version?${nc}"
echo
read -p "Yes(y) or No(n)? " updateselect
echo
if [ "$updateselect" = 'Y' ] || [ "$updateselect" = 'y' ]; then
  chroot "$glchroot" emerge --sync
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Choosing the profile...${nc}\n"
sleep 2
#######

chroot "$glchroot" eselect profile list
echo
echo -e "\n  [0]  ${cyan}Keep current profile${nc}"
echo
read -p "Enter the number corresponding to the profile: " profileselect
echo
if [ "$profileselect" = '0' ]; then
  echo -e "\n${blue}Keeping default profile...${nc}"
else
  chroot "$glchroot" eselect profile set "$profileselect"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Configuring make.conf and package.use files...${nc}\n"
sleep 2
#######

chroot "$glchroot" touch /etc/portage/package.use/gentoo
if [ "$cpu_microcode" != '' ]; then
  echo -e "##### Gentoo USE Flags per Packages #####\n\n##### KERNEL #####\n\nsys-firmware/intel-microcode initramfs\nsys-kernel/installkernel dracut grub" >> "$glchroot/etc/portage/package.use/gentoo"
else
  echo -e "##### Gentoo USE Flags per Packages #####\n\n##### KERNEL #####\n\nsys-kernel/installkernel dracut grub\nsys-kernel/linux-firmware initramfs" >> "$glchroot/etc/portage/package.use/gentoo"
fi

echo -e "\n${yellow}Do you want to install unstable packages?${nc}"
echo
read -p "Yes(y) or No(n)? " testing
echo
if [ "$testing" = 'Y' ] || [ "$testing" = 'y' ]; then
  sed -i 's/#ACCEPT_KEYWORDS/ACCEPT_KEYWORDS/' "$glchroot/etc/portage/make.conf"
fi

echo -e "\n${yellow}Would you like to manually add something to the make.conf file?${nc}"
echo
read -p "Yes(y) or No(n)? " makeselect
echo
if [ "$makeselect" = 'Y' ] || [ "$makeselect" = 'y' ]; then
  nano -w "$glchroot/etc/portage/make.conf"
fi

echo -e "\n${yellow}Use the host binary package and always download bin packages?${nc} ${red}(Note: Not all packages will be binary, some will be compiled anyway)${nc}"
echo
read -p "Yes(y) or No(n)? " binarypack
echo
if [ "$binarypack" = 'Y' ] || [ "$binarypack" = 'y' ]; then
  sed -i 's/#FEATURES=/FEATURES=/g' "$glchroot/etc/portage/make.conf"
  # work for only 17.1 profile for while
  sed -i '/sync-uri = /c\sync-uri = '"$mirrorselect/releases/$archformirror/binpackages/17.1/$(ld.so --help | grep 'supported' | awk 'NR==1{print $1}')"'' "$glchroot/etc/portage/binrepos.conf/gentoobinhost.conf"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Emerging @world...${nc}\n"
sleep 2
#######

chroot "$glchroot" emerge -aquDN --with-bdeps=y @world

#######
#clear
sleep 2
echo -e "\n${magentab}Depcleaning...${nc}\n"
sleep 2
#######

chroot "$glchroot" emerge -aq --depclean

#######
#clear
sleep 2
echo -e "\n${magentab}Configuring localtime...${nc}\n"
sleep 2
#######

echo -e "\n${blue}Open another terminal and type:${nc}\n\n${cyan}ls /usr/share/zoneinfo${nc}\n\n${blue}And choose a timezone for the system${nc}"
sleep 2
echo
read -p "Enter the corresponding timezone (e.g: America/Sao_Paulo, Europe/Brussels): " timezoneselect
echo
if [ "$stage_init" = 'openrc' ]; then
  echo '"'"$timezoneselect"'"' > "$glchroot/etc/timezone"
  chroot "$glchroot" emerge --config sys-libs/timezone-data
elif [ "$stage_init" = 'systemd' ]; then
  chroot "$glchroot" ln -sf /usr/share/zoneinfo/"$timezoneselect" /etc/localtime
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Configuring locale...${nc}\n"
sleep 2
#######

echo -e "\n${blue}Set up the locale.gen:${nc}"
echo
read -p "Enter a language for the system (Enter for en_US.UTF-8): " localegenselect
echo
if [ "$localegenselect" != '' ]; then
  echo ''"$localegenselect"' UTF-8' >> "$glchroot/etc/locale.gen"
else
  sed -i 's/#en_US.UTF-8/en_US.UTF-8/' "$glchroot/etc/locale.gen"
fi

echo -e "\n${blue}Generating locale${nc}"
echo

chroot "$glchroot" locale-gen

echo -e "\n${blue}Select the locale${nc}"
sleep 2
echo

chroot "$glchroot" eselect locale list
echo
read -p "Enter the default locale: " localeselect
echo
chroot "$glchroot" eselect locale set "$localeselect"
sed -i 's/xLINGUASx/'"$(chroot $glchroot eselect locale list | grep '[*]' | awk '{print $2}' | sed 's/.utf8//')"'/' "$glchroot/etc/portage/make.conf"
sed -i 's/xL10Nx/'"$(chroot $glchroot eselect locale list | grep '[*]' | awk '{print $2}' | sed 's/.utf8//' | sed 's/_/-/')"'/' "$glchroot/etc/portage/make.conf"

#######
#clear
sleep 2
echo -e "\n${magentab}Updating variables...${nc}\n"
sleep 2
#######

chroot "$glchroot" env-update && source /etc/profile

#######
#clear
sleep 2
echo -e "\n${magentab}Installing firmware...${nc}\n"
sleep 2
#######

chroot "$glchroot" emerge -q sys-kernel/linux-firmware

#######
#clear
sleep 2
echo -e "\n${magentab}Installing kernel-bin...${nc}\n"
sleep 2
#######

if [ "$filesystemselect" = 'xfs' ]; then
  chroot "$glchroot" emerge -q sys-fs/xfsprogs sys-kernel/gentoo-kernel-bin
elif [ "$filesystemselect" = 'jfs' ]; then
  chroot "$glchroot" emerge -q sys-fs/jfsutils sys-kernel/gentoo-kernel-bin
elif [ "$filesystemselect" = 'f2fs' ]; then
  chroot "$glchroot" emerge -q sys-fs/f2fs-tools sys-kernel/gentoo-kernel-bin
elif [ "$filesystemselect" = 'btrfs' ]; then
  chroot "$glchroot" emerge -q sys-fs/btrfs-progs sys-kernel/gentoo-kernel-bin
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Configuring the password...${nc}\n"
sleep 2
#######

sed -i 's/everyone/none/' "$glchroot/etc/security/passwdqc.conf"
chroot "$glchroot" passwd

#######
#clear
sleep 2
echo -e "\n${magentab}Setting up hostname and keymap...${nc}\n"
sleep 2
#######

if [ "$stage_init" = 'openrc' ]; then
  echo -e "\n${blue}Set up the keymap${nc}"
  sleep 2
  echo
  read -p "Enter keyboard layout (e.g: us, br-abnt2): " keyboardselect
  sed -i 's/keymap="us"/keymap="'"$keyboardselect"'"/' "$glchroot/etc/conf.d/keymaps"
  echo -e "\n${blue}Set up the hostname${nc}"
  echo
  sleep 2
  read -p "Enter a hostname for the system: " hostnameselect
  sed -i 's/localhost/'"$hostnameselect"'/' "$glchroot/etc/conf.d/hostname"
  chroot "$glchroot" touch /etc/conf.d/net
  echo -e "\n${blue}Set up the domain${nc}"
  echo
  sleep 2
  read -p "Enter a domain for the network: " domainselect
  echo -e '# Set the dns_domain_lo variable to the selected domain name\ndns_domain_lo="'"$domainselect"'"' >> "$glchroot/etc/conf.d/net"
  sed -i 's,127.0.0.1\slocalhost,127.0.0.1       '"$hostnameselect"'.'"$domainselect"' '"$hostnameselect"' localhost,' "$glchroot/etc/hosts"
elif [ "$stage_init" = 'systemd' ]; then
  chroot "$glchroot" systemd-machine-id-setup
  chroot "$glchroot" systemd-firstboot --prompt
  chroot "$glchroot" systemctl preset-all
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Installing basic apps...${nc}\n"
sleep 2
#######

if [ "$stage_init" = 'openrc' ]; then
  chroot "$glchroot" emerge -q --noreplace app-admin/sudo app-portage/genlop app-portage/gentoolkit app-shells/bash-completion app-shells/gentoo-bashcomp app-admin/sysklogd sys-power/acpid sys-process/cronie sys-apps/mlocate net-misc/networkmanager sys-fs/udev sys-boot/grub net-misc/chrony
elif [ "$stage_init" = 'systemd' ]; then
  chroot "$glchroot" emerge -q --noreplace app-admin/sudo app-portage/genlop app-portage/gentoolkit app-shells/bash-completion app-shells/gentoo-bashcomp sys-power/acpid net-misc/networkmanager sys-apps/mlocate sys-boot/grub
fi

echo -e "\n${yellow}Would you like install some program?${nc}\n"
read -p "Yes(y) or No(n)? " installopt
echo
if [ "$installopt" = 'Y' ] || [ "$installopt" = 'y' ]; then
  read -p "Type the name of program (or for several programs use backspace to separate them): " programname
  emerge -q "$programname"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Enabling services...${nc}\n"
sleep 2
#######

if [ "$stage_init" = 'openrc' ]; then
  chroot "$glchroot" rc-update add sysklogd default
  chroot "$glchroot" rc-update add cronie default
  chroot "$glchroot" rc-update add NetworkManager default
  chroot "$glchroot" rc-update add acpid default
  chroot "$glchroot" rc-update add udev sysinit
  chroot "$glchroot" rc-update add chronyd default
elif [ "$stage_init" = 'systemd' ]; then
  chroot "$glchroot" systemctl disable systemd-resolved.service
  chroot "$glchroot" systemctl enable NetworkManager.service
  chroot "$glchroot" systemctl enable acpid.service
fi

if [ "$stage_init" = 'openrc' ]; then
  #######
  #clear
  sleep 2
  echo -e "\n${magentab}Setting up the hardware clock...${nc}\n"
  sleep 2
  #######

  echo -e "\n${yellow}Do you want to set the hardware clock to local?${nc}"
  echo
  read -p "Yes(y) or No(n)? " clockselect
  if [ "$clockselect" = 'Y' ] || [ "$clockselect" = 'y' ]; then
    sed -i 's/clock="UTC"/clock="local"/' "$glchroot/etc/conf.d/hwclock"
  elif [ "$clockselect" = 'N' ] || [ "$clockselect" = 'n' ]; then
    echo "rtconutc" >> "$glchroot/etc/chrony/chrony.conf"
  fi
  echo "pool pool.ntp.org iburst auto_offline" >> "$glchroot/etc/chrony/chrony.conf"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Installing and configuring grub...${nc}\n"
sleep 2
#######

sed -i '/#GRUB_GFXMODE=/c\GRUB_GFXMODE=auto' "$glchroot/etc/default/grub"
sed -i '/#GRUB_GFXPAYLOAD_LINUX=/c\GRUB_GFXPAYLOAD_LINUX=keep' "$glchroot/etc/default/grub"
sed -i '/#GRUB_BACKGROUND=/c\GRUB_BACKGROUND=/boot/grub/gentoo-wallpaper.png' "$glchroot/etc/default/grub"

if [ "$stage_init" = 'systemd' ]; then
  sed -i '/#GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"' "$glchroot/etc/default/grub"
fi

if [ "$boot_mode" = 'uefi' ]; then
  echo -e "\n${yellow}Are you installing the system on a USB flash drive?${nc}\n"
  read -p "Yes(y) or No(n)? " usbgrub
  echo -e "\n${yellow}Remove old entries of bootloader?${nc}\n"
  read -p "Yes(y) or No(n)? " gruboldremove
  if [ "$usbgrub" = 'Y' ] || [ "$usbgrub" = 'y' ]; then
    if [ "$gruboldremove" = 'Y' ] || [ "$gruboldremove" = 'y' ]; then
      chroot "$glchroot" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Gentoo Linux" --removable --recheck
    else
      chroot "$glchroot" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Gentoo Linux" --removable
    fi
  elif [ "$usbgrub" = 'N' ] || [ "$usbgrub" = 'n' ]; then
    if [ "$gruboldremove" = 'Y' ] || [ "$gruboldremove" = 'y' ]; then
      chroot "$glchroot" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Gentoo Linux" --recheck
    else
      chroot "$glchroot" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Gentoo Linux"
    fi
  fi
elif [ "$boot_mode" = 'legacy' ]; then
  chroot "$glchroot" grub-install "$hddevselect"
fi

cp grub/gentoo-wallpaper.png "$glchroot/boot/grub/"
chroot "$glchroot" grub-mkconfig -o /boot/grub/grub.cfg

#######
#clear
sleep 2
echo -e "\n${magentab}Creating users...${nc}\n"
sleep 2
#######

echo -e "\n${yellow}Would you like to create a user?${nc}"
echo
read -p "Yes(y) or No(n) " createuser
echo
if [ "$createuser" = 'Y' ] || [ "$createuser" = 'y' ]; then
  read -p "Type a name to the user: " nameuser
  chroot "$glchroot" groupadd "$nameuser"
  chroot "$glchroot" useradd -g "$nameuser" -d "/home/$nameuser" -s "/bin/bash" -G "$nameuser,wheel,users,video,audio,portage" -m "$nameuser"
  chroot "$glchroot" chown -R "$nameuser":"$nameuser" "/home/$nameuser"
  echo -e "\n$nameuser ALL=(ALL:ALL) ALL NOPASSWD: ALL" >> "$glchroot/etc/sudoers"
  echo -e "\n${blue}Type a passwd for the user:${nc} ${green}$nameuser${nc}"
  chroot "$glchroot" passwd "$nameuser"
elif [ "$createuser" = 'N' ] || [ "$createuser" = 'n' ]; then
  echo -e "\n${red}Not creating users...${nc}"
fi

#######
#clear
sleep 2
echo -e "\n${magentab}Installation finished!!!${nc}\n"
sleep 2
#######

#######
#clear
sleep 2
echo -e "\n${magentab}Umounting System to reboot...${nc}\n"
sleep 2
#######

cd
umount -l "$glchroot"/dev{/shm,/pts,}
umount -R "$glchroot"

#######
#clear
sleep 2
echo -e "\n${magentab}Reboot any time, have fun!!!${nc}\n"
sleep 5
#######
