# NixOS Installation Guide

## Phase 1: Disk Preparation

### 1. Set Installation Variables

Identify your target installation drive (for example `/dev/nvme0n1` or `/dev/sda`) and the username that will own the persistent home directory.

```bash
export INST_DISK="/dev/YOUR_DISCOVERED_DRIVE"
export INST_USER="YOUR_USERNAME"
```

### 2. Form the GPT Partition Table

Clear any existing partition signatures and create:

- A **512 MiB EFI System Partition (ESP)**
- A **LUKS-encrypted partition** using the remaining space

```bash
sudo parted "$INST_DISK" -- mklabel gpt
sudo parted "$INST_DISK" -- mkpart ESP fat32 1MiB 512MiB
sudo parted "$INST_DISK" -- set 1 esp on
sudo parted "$INST_DISK" -- mkpart primary 512MiB 100%

# Refresh partition tables
sudo udevadm settle
```

### 3. Determine Partition Names

Partition naming depends on the drive type.

#### NVMe / eMMC

Uses a `p` separator:

- `/dev/nvme0n1p1`
- `/dev/nvme0n1p2`

#### SATA / SCSI

Uses a numeric suffix:

- `/dev/sda1`
- `/dev/sda2`

Inspect the partition layout:

```bash
lsblk "$INST_DISK"
```

Assign the partition paths:

```bash
export BOOT_PART="${INST_DISK}p1" # Use "${INST_DISK}1" for SATA drives
export LUKS_PART="${INST_DISK}p2" # Use "${INST_DISK}2" for SATA drives
```

---

# Phase 2: Encrypted Storage & Filesystem Layout

## 1. Create the LUKS Container

```bash
# Initialize the encrypted container
sudo cryptsetup luksFormat "$LUKS_PART"

# Open it as /dev/mapper/cryptroot
sudo cryptsetup open "$LUKS_PART" cryptroot
```

## 2. Create the Btrfs Filesystem

Format the encrypted mapping and create the required subvolumes.

```bash
sudo mkfs.btrfs -L system /dev/mapper/cryptroot
sudo mount /dev/mapper/cryptroot /mnt

# Create subvolumes
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@persist
sudo btrfs subvolume create /mnt/@log
sudo btrfs subvolume create /mnt/@swap

# Disable Copy-on-Write for swap
sudo chattr +C /mnt/@swap

# Unmount
sudo umount /mnt
```

## 3. Create the Temporary Root Filesystem

Format the EFI partition, create a tmpfs root, and mount the Btrfs subvolumes.

```bash
sudo mkfs.vfat -F 32 -n boot "$BOOT_PART"

# Mount an ephemeral root in RAM
sudo mount -t tmpfs -o size=2G,mode=755 none /mnt

# Create mount points
sudo mkdir -p /mnt/{boot,nix,persist,var/log,swap}

# Mount partitions
sudo mount "$BOOT_PART" /mnt/boot
sudo mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
sudo mount -o subvol=@persist,compress=zstd,noatime /dev/mapper/cryptroot /mnt/persist
sudo mount -o subvol=@log,compress=zstd,noatime /dev/mapper/cryptroot /mnt/var/log
sudo mount -o subvol=@swap,noatime /dev/mapper/cryptroot /mnt/swap
```

---

# Phase 3: Configuration & Identity

## 1. Create Password Hashes

Store password hashes in the persistent partition before installation.

```bash
sudo mkdir -p /mnt/persist/passwords

echo -n "$(nix-shell -p mkpasswd --run "mkpasswd -m sha-512")" | sudo tee /mnt/persist/passwords/root
echo -n "$(nix-shell -p mkpasswd --run "mkpasswd -m sha-512")" | sudo tee "/mnt/persist/passwords/${INST_USER}"

sudo chmod 700 /mnt/persist/passwords
sudo chmod 600 /mnt/persist/passwords/*
```

> Ensure your configuration defines:
>
> ```nix
> users.users.root.hashedPasswordFile = "/persist/passwords/root";
> users.users.<username>.hashedPasswordFile = "/persist/passwords/YOUR_USERNAME";
> ```
>
> where `<username>` matches the value of `INST_USER`.

## 2. Clone Your Configuration Repository

```bash
sudo mkdir -p "/mnt/persist/home/${INST_USER}"
sudo chown -R 1000:100 "/mnt/persist/home/${INST_USER}"

git clone https://github.com/tapayne88/dotfiles.git \
    "/mnt/persist/home/${INST_USER}/dotfiles"
```

## 3. Generate the Hardware Configuration

```bash
# Generate the hardware configuration
sudo nixos-generate-config --root /mnt --dir /tmp

# Copy it into your repository
cp /tmp/hardware-configuration.nix \
    "/mnt/persist/home/${INST_USER}/dotfiles/hosts/YOUR_NEW_HOST_NAME/"
```

---

# Phase 4: Install NixOS

## 1. Select the Flake Output

Inspect the available host definitions.

```bash
cd "/mnt/persist/home/${INST_USER}/dotfiles"
grep -A5 "nixosConfigurations" flake.nix
```

Select the hostname to install.

```bash
export TARGET_HOST="YOUR_MATCHING_HOSTNAME"
```

## 2. Stage Changes & Install

Because Nix Flakes ignore untracked files, stage the generated hardware configuration before installing.

```bash
git add .

sudo nixos-install \
    --flake ".#${TARGET_HOST}" \
    --no-root-passwd
```

## 3. Reboot

Unmount all filesystems and restart into the new installation.

```bash
cd /
sudo umount -R /mnt
sudo reboot
```
