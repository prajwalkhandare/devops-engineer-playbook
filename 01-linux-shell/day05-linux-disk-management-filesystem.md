# 💽 Day 05 — Linux Disk Management & Filesystem Commands

> **Role Context:** Essential knowledge for DevOps Engineers, Cloud Support Engineers & Linux Administrators.  
> **Difficulty:** ⭐⭐⭐☆☆ Intermediate  
> **Series:** Linux for DevOps — 30 Days Challenge

---

## 📋 Table of Contents

- [Why This Matters](#-why-this-matters)
- [df — Check Disk Space](#-df--check-disk-space)
- [du — Check Directory Size](#-du--check-directory-size)
- [df vs du — Key Difference](#-df-vs-du--key-difference)
- [lsblk — List Block Devices](#-lsblk--list-block-devices)
- [blkid — Check UUIDs](#-blkid--check-uuids)
- [Mounting & Unmounting](#-mounting--unmounting)
- [Partitioning & Formatting](#-partitioning--formatting)
- [/etc/fstab — Persistent Mounts](#-etcfstab--persistent-mounts)
- [Inode Exhaustion](#-inode-exhaustion)
- [Open Deleted Files](#-open-deleted-files-trap)
- [Real-World Scenarios](#-real-world-production-scenarios)
- [Troubleshooting Playbook](#-troubleshooting-playbook)
- [Interview Q&A](#-interview-questions--answers)
- [Quick Command Reference](#-quick-command-reference)

---

## 🔥 Why This Matters

Disk issues are among the **most common production incidents**. Here's what you'll face in the real world:

| Problem | Impact |
|---|---|
| Disk 100% full | Application crashes, logs stop writing |
| Inode exhaustion | Can't create files even with free space |
| Missing mount point | Services fail to start |
| Bad `/etc/fstab` entry | Server boots into emergency mode |
| Open deleted files | Disk space not released after deletion |
| New cloud volume unformatted | Attached disk not usable |

---

## 📊 `df` — Check Disk Space

`df` reports **filesystem-level** disk usage.

```bash
# Basic usage
df

# Human-readable (KB/MB/GB)
df -h

# Show filesystem type
df -Th

# Check a specific mount point
df -h /data

# Check inode usage
df -i
```

### Sample Output — `df -h`
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       20G   12G  7.0G  64% /
tmpfs           487M     0  487M   0% /dev/shm
/dev/xvdb        50G   10G   38G  21% /data
```

### Column Reference

| Column | Meaning |
|---|---|
| `Size` | Total partition size |
| `Used` | Space consumed |
| `Avail` | Space available |
| `Use%` | Usage percentage |
| `Mounted on` | Mount point path |

> ⚠️ **Alert threshold:** If `Use%` hits **85%+**, investigate immediately. At **100%**, applications will fail.

---

## 📁 `du` — Check Directory Size

`du` reports **directory/file-level** disk usage — your detective tool for finding what's eating space.

```bash
# Current directory size
du -sh .

# Specific directory
du -sh /var/log

# All subdirectories under /var/log
du -sh /var/log/*

# Top space consumers under /var — sorted largest first
du -sh /var/* | sort -hr | head

# Find the biggest files
find /var/log -type f -exec du -h {} + | sort -hr | head
```

### Sample Output — `du -sh /var/log/*`
```
1.2G    /var/log/journal
800M    /var/log/nginx
120M    /var/log/syslog
40M     /var/log/auth.log
```

---

## ⚖️ `df` vs `du` — Key Difference

> This is a **classic interview question**.

| | `df` | `du` |
|---|---|---|
| **Scope** | Filesystem / partition level | Directory / file level |
| **Use case** | "Is the disk full?" | "What's consuming the space?" |
| **Example** | `df -h /` → root partition usage | `du -sh /var/*` → find largest folder |
| **Blind spot** | Doesn't show per-directory detail | Can miss open deleted files |

**Workflow:** `df -h` first → if high → `du -sh /var/* \| sort -hr` to drill down.

---

## 🧱 `lsblk` — List Block Devices

```bash
# Show all disks and partitions
lsblk

# Include filesystem type, UUID, and mount point
lsblk -f
```

### Sample Output — `lsblk`
```
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0  20G  0 disk
└─xvda1 202:1    0  20G  0 part /
xvdb    202:16   0  50G  0 disk
└─xvdb1 202:17   0  50G  0 part /data
```

Use `lsblk` to:
- ✅ Verify a new cloud disk (EBS, Azure Disk) is attached
- ✅ Identify partition layout
- ✅ Confirm mount points

---

## 🔑 `blkid` — Check UUIDs

```bash
sudo blkid
```

### Sample Output
```
/dev/xvda1: UUID="1a2b3c4d-1111-2222-3333-444455556666" TYPE="xfs"
/dev/xvdb1: UUID="aabbccdd-7777-8888-9999-000011112222" TYPE="ext4"
```

> 🔐 **UUID** is the stable identifier used in `/etc/fstab`. Device names like `/dev/xvdb1` can change on reboot. UUID never changes.

---

## 🔌 Mounting & Unmounting

### Mount a filesystem manually

```bash
# 1. Create the mount point
sudo mkdir -p /data

# 2. Mount the partition
sudo mount /dev/xvdb1 /data

# 3. Verify
df -h
lsblk
```

### Unmount

```bash
sudo umount /data
# or
sudo umount /dev/xvdb1
```

### Check what's using a busy mount point

```bash
# List open files on mount point
sudo lsof +D /data

# List processes using mount point
sudo fuser -m /data
```

> ⚠️ `umount` will fail with `target is busy` if any process has open files there. Kill or stop those processes first.

### View all active mounts

```bash
mount
mount | grep /data
findmnt
```

---

## 🛠️ Partitioning & Formatting

> ⚠️ **Production Warning:** These commands are destructive. Double-check your target device before running.

### Step 1 — Create a partition

```bash
sudo fdisk /dev/xvdb
```

Inside `fdisk`:
| Key | Action |
|---|---|
| `n` | New partition |
| `p` | Primary partition |
| `Enter` | Accept defaults |
| `w` | Write and exit |

### Step 2 — Create a filesystem

```bash
# ext4 format
sudo mkfs.ext4 /dev/xvdb1

# xfs format (common in RHEL/CentOS/Amazon Linux)
sudo mkfs.xfs /dev/xvdb1
```

> ❌ `mkfs` **erases all existing data** on the partition. Use only on new or intentionally wiped disks.

---

## 📌 `/etc/fstab` — Persistent Mounts

Manual mounts disappear after reboot. Use `/etc/fstab` to make them permanent.

```bash
# View current fstab
cat /etc/fstab
```

### Example entry

```
UUID=aabbccdd-7777-8888-9999-000011112222  /data  ext4  defaults,nofail  0  0
```

### Field Reference

| Field | Value | Meaning |
|---|---|---|
| Device | `UUID=...` | Stable disk identifier |
| Mount point | `/data` | Where to mount |
| Filesystem | `ext4` | Filesystem type |
| Options | `defaults,nofail` | Mount options |
| Dump | `0` | Backup utility flag |
| Pass | `0` | `fsck` check order |

> 💡 `nofail` is critical — it prevents the server from getting stuck in emergency mode if the disk is unavailable on boot.

### ✅ Always validate before reboot

```bash
sudo mount -a
```

If this runs without error → your `fstab` entry is correct. **Never skip this step in production.**

---

## 🔢 Inode Exhaustion

Inodes store file metadata. When all inodes are used, **new files cannot be created** — even if disk space is available.

```bash
# Check inode usage
df -i
```

### Sample Output
```
Filesystem      Inodes  IUsed   IFree IUse% Mounted on
/dev/xvda1     1310720 1310720      0  100% /
```

> 🚨 `IUse% = 100%` means zero files can be created. Applications will crash, logs will stop.

### Find directories with huge file counts

```bash
# Total files under /var
find /var -xdev -type f | wc -l

# File count in /var/log
find /var/log -type f | wc -l
```

Common culprits: session files, temp files, cache files, mail spools with thousands of tiny files.

---

## 👻 Open Deleted Files Trap

> One of the most **misunderstood production issues**.

**Scenario:** You deleted large log files. `du` shows they're gone. But `df` still shows 95% usage. What's happening?

When a file is deleted but a running process still has it open, the OS **cannot free the disk space** until the process closes or restarts.

```bash
# Find open deleted files
sudo lsof | grep deleted
```

### Fix

```bash
# Option 1: Restart the offending service (e.g., nginx, java, etc.)
sudo systemctl restart nginx

# Option 2: Gracefully stop the process, then start it
```

After restart, `df -h` should show the freed space.

---

## 🏭 Real-World Production Scenarios

### Scenario A — New AWS EBS Volume

```bash
# 1. Verify disk is visible
lsblk

# 2. Partition
sudo fdisk /dev/xvdb

# 3. Format
sudo mkfs.xfs /dev/xvdb1

# 4. Mount
sudo mkdir -p /data
sudo mount /dev/xvdb1 /data

# 5. Make persistent
sudo blkid                  # get UUID
sudo vi /etc/fstab          # add entry
sudo mount -a               # validate
```

---

### Scenario B — Root Filesystem at 100%

```bash
df -h                                   # confirm which partition is full
du -sh /var/* | sort -hr | head        # find largest dirs
du -sh /var/log/* | sort -hr | head    # drill into logs
sudo lsof | grep deleted               # check open deleted files
```

Actions:
- Compress or remove old logs
- Configure log rotation (`logrotate`)
- Extend the EBS volume and resize the filesystem

---

### Scenario C — Server Boots into Emergency Mode

**Cause:** Bad `/etc/fstab` entry (wrong UUID, wrong filesystem type).

```bash
# Fix from emergency shell:
sudo vi /etc/fstab         # correct the entry
sudo mount -a              # test it
reboot
```

**Prevention:** Always run `sudo mount -a` after editing fstab.

---

### Scenario D — df and du Output Mismatch

```
df -h  → 95% used
du -sh /var/* → only shows 20G total
```

**Root cause:** Open deleted files.  
**Fix:** `sudo lsof | grep deleted` → restart the holding process.

---

## 🔍 Troubleshooting Playbook

### Disk full alert received

```bash
df -h
df -i
du -sh /var/* | sort -hr | head
du -sh /tmp/* | sort -hr | head
sudo lsof | grep deleted
```

### Mount point missing after reboot

```bash
mount | grep /data
cat /etc/fstab
sudo blkid
# Fix UUID if wrong
sudo mount -a
```

### `umount` says target is busy

```bash
sudo lsof +D /data
sudo fuser -m /data
# Stop the blocking process, then retry:
sudo umount /data
```

### Application failing despite free space

```bash
df -h /data        # check space
df -i /data        # check inodes
ls -ld /data       # check permissions
mount | grep /data # check mount options (read-only?)
```

---

## 🎯 Interview Questions & Answers

<details>
<summary><b>Q1. What is the difference between <code>df</code> and <code>du</code>?</b></summary>

`df` shows disk usage at the **filesystem/partition level** — how much of `/` or `/data` is used overall.  
`du` shows disk usage at the **directory/file level** — which specific folder is consuming space.  
In a disk full investigation, use `df -h` first to confirm, then `du -sh /var/* | sort -hr` to pinpoint the culprit.
</details>

<details>
<summary><b>Q2. Why is UUID preferred over device name in /etc/fstab?</b></summary>

Device names like `/dev/xvdb1` can change after a reboot or when disks are added/removed, especially in cloud environments. UUID is assigned at format time and remains stable. Using UUID prevents mount failures caused by device renaming.
</details>

<details>
<summary><b>Q3. Disk shows 100% usage but <code>du</code> doesn't explain it. Why?</b></summary>

A large file was deleted but a running process still has it open. The OS cannot free the space until the file handle is released. Check with `sudo lsof | grep deleted` and restart the holding process.
</details>

<details>
<summary><b>Q4. What is inode exhaustion and how do you detect it?</b></summary>

Each file requires an inode to store its metadata. When all inodes are consumed, new files cannot be created — even if disk space is available. Detect with `df -i`. Look for `IUse%` at or near 100%.
</details>

<details>
<summary><b>Q5. How do you make a mount persistent after reboot?</b></summary>

Add an entry to `/etc/fstab` using the filesystem UUID. Always validate with `sudo mount -a` before rebooting to confirm the entry is correct.
</details>

<details>
<summary><b>Q6. How would you attach and use a new EBS volume in AWS?</b></summary>

1. `lsblk` — verify disk is visible  
2. `fdisk /dev/xvdb` — partition it  
3. `mkfs.xfs /dev/xvdb1` — format it  
4. `mkdir -p /data && mount /dev/xvdb1 /data` — mount it  
5. `blkid` → edit `/etc/fstab` → `mount -a` — make it persistent
</details>

<details>
<summary><b>Q7. umount says "target is busy". How do you fix it?</b></summary>

Find what's using the mount point:  
`sudo lsof +D /data` or `sudo fuser -m /data`  
Stop or move away from the blocking process/shell, then retry `umount`.
</details>

---

## ⚡ Quick Command Reference

```bash
# ── DISK SPACE ──────────────────────────────────────
df -h                              # human-readable disk usage
df -Th                             # with filesystem type
df -i                              # inode usage
df -h /data                        # specific mount point

# ── DIRECTORY SIZE ──────────────────────────────────
du -sh /var/log                    # size of a directory
du -sh /var/log/*                  # size of all subdirs
du -sh /var/* | sort -hr | head    # top consumers

# ── BLOCK DEVICES ───────────────────────────────────
lsblk                              # list disks and partitions
lsblk -f                           # with filesystem and UUID
sudo blkid                         # show UUIDs

# ── MOUNT / UNMOUNT ─────────────────────────────────
mount                              # show all mounts
mount | grep /data                 # filter specific mount
findmnt                            # tree view of mounts
sudo mkdir -p /data                # create mount point
sudo mount /dev/xvdb1 /data        # mount partition
sudo umount /data                  # unmount

# ── BUSY MOUNT DEBUGGING ────────────────────────────
sudo lsof +D /data                 # open files on mount
sudo fuser -m /data                # processes using mount

# ── PARTITION & FORMAT ──────────────────────────────
sudo fdisk /dev/xvdb               # partition a disk
sudo mkfs.ext4 /dev/xvdb1          # format as ext4
sudo mkfs.xfs /dev/xvdb1           # format as xfs

# ── FSTAB ───────────────────────────────────────────
cat /etc/fstab                     # view fstab
sudo mount -a                      # validate fstab entries

# ── INODE & FILE COUNT ──────────────────────────────
find /var -xdev -type f | wc -l    # total file count
find /var/log -type f | wc -l      # file count in log dir

# ── OPEN DELETED FILES ──────────────────────────────
sudo lsof | grep deleted           # detect ghost space consumers

# ── LARGEST FILES ───────────────────────────────────
find /var/log -type f -exec du -h {} + | sort -hr | head

# ── MISC ────────────────────────────────────────────
free -m                            # memory usage
```

---

## 📚 Best Practices Summary

- 🔍 Monitor `df -h` and `df -i` regularly — both space **and** inodes
- 🏷️ Always use **UUID** in `/etc/fstab`, never device names
- ✅ Always run `sudo mount -a` after editing fstab — before rebooting
- 👻 If `df` and `du` disagree — check `lsof | grep deleted`
- 🔒 Use `nofail` mount option for non-critical disks
- 🗂️ Separate mount points for `/`, `/var`, `/data`, `/logs` in production
- 🔄 Configure `logrotate` to prevent log-driven disk exhaustion
- ⚠️ Never run `mkfs` on a disk without confirming it's the right one

---

*Part of the **Linux for DevOps — 30 Days Challenge** series.*  
*Contributions and corrections welcome via Pull Request.*