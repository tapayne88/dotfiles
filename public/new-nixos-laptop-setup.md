# NixOS Installation Guide

## Phase 1: Preparation & Hardware Configuration

### 1. Set Installation Variables

Identify the user that will own the persistent home directory and the hostname of the new machine.

```bash
export INST_USER="YOUR_USERNAME"
export TARGET_HOST="YOUR_NEW_HOST_NAME"
```

### 2. Create a new branch

Create a new branch on this repo and copy over one of the existing [nixos/modules/hosts](https://github.com/tapayne88/dotfiles/blob/05e4d70ca5118114181fb54bb9b8a15448fb856c/nixos/modules/hosts) entries. Update it to match the `TARGET_HOST` name above and adjust any of the other elements. The following will need updating to ensure they align with the information from the following steps:

- nixos-hardware module used in [`default.nix`](https://github.com/tapayne88/dotfiles/blob/05e4d70ca5118114181fb54bb9b8a15448fb856c/nixos/modules/hosts/framework-13-pro/default.nix#L12)
- `hostSettings.mainDevice`
- `hostSettings.internalMonitor.name`

> **Suggestion:** Name the branch `$TARGET_HOST`, the following steps will make this assumption.

### 3. Generate Hardware Configuration

Because Disko handles all mounts declaratively, use the `--no-filesystems` flag. This correctly detects your CPU microcode and necessary storage/input kernel modules from the physical hardware buses without needing the drives to be formatted first.

```bash
sudo nixos-generate-config \
  --no-filesystems \
  --dir "${TARGET_HOST}"
```

The configuration in the generated config should be copied over to the branch started in the previous step.

### 4. Identify and Set Your Hardware Disk ID

Find the persistent hardware ID of your target installation drive (look for `ata-` or `nvme-` prefixes).

```bash
ls -l /dev/disk/by-id/
```

Open your host's configuration file on your branch and update the `mainDevice` variable to match the discovered ID:

```nix
hostSettings.mainDevice = "/dev/disk/by-id/YOUR-DISCOVERED-ID";
```

**N.B.** You'll also need to set the other required fields on `hostSettings`.

### 5. Push Changes to GitHub

Because the installation commands pull directly from GitHub, you must commit and push your changes to the remote branch so the installer can see them.

---

## Phase 2: Disk Partitioning, Formatting & Installation

### 1. Disk Partitioning

Disko handles the GPT partition table, LUKS encryption, Btrfs subvolumes, and mounting in a single command.

> **Warning:** The `destroy,format,mount` mode will completely wipe the target drive. You will be prompted to enter and verify your new LUKS passphrase during this process.

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run 'github:nix-community/disko/latest#disko' -- \
  --mode destroy,format,mount \
  --flake "github:tapayne88/dotfiles/${TARGET_HOST}?dir=nixos#${TARGET_HOST}"
```

Once this finishes, your drive is fully partitioned, encrypted, and automatically mounted to `/mnt`.

### 2. Installation

Install NixOS with the standard installer. This two-step approach avoids pulling everything into RAM.

```bash
sudo nixos-install \
  --flake "github:tapayne88/dotfiles/${TARGET_HOST}?dir=nixos#${TARGET_HOST}" \
  --no-root-passwd
```

---

## Phase 3: Configuration & Identity

### 1. Create Password Hashes

Since Disko already mounted the filesystems, we can write the passwords directly to the persistent directory. Store password hashes securely in the newly mounted persistent partition.

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

### 2. Reboot

Unmount all filesystems and restart into the new installation.

```bash
cd /
sudo umount -R /mnt
sudo reboot
```
