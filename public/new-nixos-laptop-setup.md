# NixOS Installation Guide

## Phase 1: Preparation & Hardware Configuration

### 1. Set Installation Variables

Identify the user that will own the persistent home directory and the hostname of the new machine.

```bash
export INST_USER="YOUR_USERNAME"
export TARGET_HOST="YOUR_NEW_HOST_NAME"
```

### 2. Clone Your Dotfiles Locally

Clone your configuration into the live USB's temporary memory so you can generate the hardware config and set the disk ID.

```bash
cd ~
git clone [https://github.com/tapayne88/dotfiles.git](https://github.com/tapayne88/dotfiles.git)
cd dotfiles
```

### 3. Generate Hardware Configuration

Because Disko handles all mounts declaratively, use the `--no-filesystems` flag. This correctly detects your CPU microcode and necessary storage/input kernel modules from the physical hardware buses without needing the drives to be formatted first.

```bash
sudo nixos-generate-config --no-filesystems --show-hardware-config > "hosts/${TARGET_HOST}/hardware-configuration.nix"
```

### 4. Identify and Set Your Hardware Disk ID

Find the persistent hardware ID of your target installation drive (look for `ata-` or `nvme-` prefixes).

```bash
ls -l /dev/disk/by-id/
```

Open your host's configuration file and update the `mainDevice` variable to match the discovered ID:

```nix
hostSettings.mainDevice = "/dev/disk/by-id/YOUR-DISCOVERED-ID";
```

Stage the changes so Nix Flakes can evaluate them in the next step:

```bash
git add .
```

---

## Phase 2: Disk Partitioning & Formatting

Disko handles the GPT partition table, LUKS encryption, Btrfs subvolumes, and mounting in a single command.

> **Warning:** The `destroy,format,mount` mode will completely wipe the target drive. You will be prompted to enter and verify your new LUKS passphrase during this process.

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake ".#${TARGET_HOST}"
```

Once this finishes, your drive is fully partitioned, encrypted, and mounted to `/mnt`.

---

## Phase 3: Configuration & Identity

### 1. Create Password Hashes

Store password hashes securely in the newly mounted persistent partition.

```bash
sudo mkdir -p /mnt/persist/passwords

echo -n "$(nix-shell -p mkpasswd --run "mkpasswd -m sha-512")" | sudo tee /mnt/persist/passwords/root
echo -n "$(nix-shell -p mkpasswd --run "mkpasswd -m sha-512")" | sudo tee "/mnt/persist/passwords/${INST_USER}"

sudo chmod 700 /mnt/persist/passwords
sudo chmod 600 /mnt/persist/passwords/*
```

> Ensure your host configuration defines:
>
> ```nix
> users.users.root.hashedPasswordFile = "/persist/passwords/root";
> users.users.<username>.hashedPasswordFile = "/persist/passwords/YOUR_USERNAME";
> ```

### 2. Move the Repository to Persistent Storage

Move your configured, locally-edited dotfiles repository from the live environment's RAM into the persistent home directory where it will live permanently.

```bash
sudo mkdir -p "/mnt/persist/home/${INST_USER}"
sudo cp -r ~/dotfiles "/mnt/persist/home/${INST_USER}/dotfiles"
sudo chown -R 1000:100 "/mnt/persist/home/${INST_USER}"
```

---

## Phase 4: Install NixOS

### 1. Stage Final Changes

Navigate to the permanent repository location and ensure all files (including the newly generated hardware configuration) are staged for the Flake installer.

```bash
cd "/mnt/persist/home/${INST_USER}/dotfiles"
git add .
```

### 2. Install

Install NixOS directly from the Flake.

```bash
sudo nixos-install \
    --flake ".#${TARGET_HOST}" \
    --no-root-passwd
```

### 3. Reboot

Unmount all filesystems and restart into the new installation.

```bash
cd /
sudo umount -R /mnt
sudo reboot
```
