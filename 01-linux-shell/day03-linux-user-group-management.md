# 🐧 Day 03 — Linux User and Group Management

> **Role:** DevOps Engineer / Linux Administrator  
> **Topic:** User & Group Management in Production Linux Environments

---

## 📌 Table of Contents

1. [Introduction](#introduction)
2. [Why It Matters](#why-it-matters)
3. [Check Current User Info](#check-current-user-info)
4. [Create a New User](#create-a-new-user)
5. [Set a Password](#set-a-password)
6. [User Management Commands](#user-management-commands)
7. [Delete a User](#delete-a-user)
8. [Group Management](#group-management)
9. [Important System Files](#important-system-files)
10. [Sudo Access Management](#sudo-access-management)
11. [Real-World Production Use Cases](#real-world-production-use-cases)
12. [Troubleshooting Scenarios](#troubleshooting-scenarios)
13. [Security Best Practices](#security-best-practices)
14. [Interview Questions & Answers](#interview-questions--answers)
15. [Quick Command Reference](#quick-command-reference)

---

## Introduction

User and group management is one of the most critical responsibilities of a Linux administrator. In production environments, managing users correctly ensures **proper access control**, **security**, and **accountability**.

As a DevOps Engineer or Linux Administrator, you will frequently:

- Create users for developers
- Assign them to specific groups
- Grant sudo access
- Disable access when needed
- Troubleshoot permission-related issues

---

## Why It Matters

In real production servers, multiple users may access the same Linux system. Different teams need different levels of access:

| Team | Access Level |
|------|-------------|
| DevOps | Admin / Sudo |
| Developers | Application group |
| QA | Read / Limited |
| Security | Audit / Read |
| Support | Limited sudo |

### 🏭 Real-World Scenarios

- Creating a deployment user for **CI/CD pipelines**
- Adding developers to a **shared application group**
- Giving **limited sudo access** to support engineers
- Disabling user accounts during **security audits**
- **Removing ex-employee access** from servers immediately

---

## Check Current User Info

### Who am I?

```bash
whoami
```

```
ec2-user
```

### Check UID, GID, and Groups

```bash
id
```

```
uid=1000(ec2-user) gid=1000(ec2-user) groups=1000(ec2-user),10(wheel)
```

### Check Groups of a Specific User

```bash
groups ec2-user
```

```
ec2-user : ec2-user wheel
```

---

## Create a New User

```bash
sudo useradd devopsuser
```

**Verify the user was created:**

```bash
id devopsuser
```

### Create with Home Directory

```bash
sudo useradd -m devopsuser2
```

```bash
ls -ld /home/devopsuser2
```

### Create with a Custom Shell

```bash
sudo useradd -s /bin/bash appuser
```

```bash
grep appuser /etc/passwd
```

---

## Set a Password

After creating a user, always assign a password:

```bash
sudo passwd devopsuser
```

```
Changing password for user devopsuser.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
```

---

## User Management Commands

### View User Details from `/etc/passwd`

```bash
grep devopsuser /etc/passwd
```

```
devopsuser:x:1001:1001::/home/devopsuser:/bin/bash
```

| Field | Value | Meaning |
|-------|-------|---------|
| 1 | `devopsuser` | Username |
| 2 | `x` | Password (stored in `/etc/shadow`) |
| 3 | `1001` | UID |
| 4 | `1001` | GID |
| 5 | *(empty)* | Comment/Info |
| 6 | `/home/devopsuser` | Home directory |
| 7 | `/bin/bash` | Login shell |

### Rename a User

```bash
sudo usermod -l newdevopsuser devopsuser
```

### Change Home Directory

```bash
sudo usermod -d /home/newhome -m newdevopsuser
```

> `-d` → new home path | `-m` → move contents

### 🔒 Lock a User Account

```bash
sudo passwd -l newdevopsuser
```

### 🔓 Unlock a User Account

```bash
sudo passwd -u newdevopsuser
```

### Set Account Expiry Date

```bash
sudo chage -E 2026-12-31 newdevopsuser
```

> Useful for **temporary or contract-based users**.

### Check Password Expiry Info

```bash
sudo chage -l newdevopsuser
```

---

## Delete a User

```bash
# Delete user only
sudo userdel tempuser

# Delete user AND home directory
sudo userdel -r tempuser
```

> ⚠️ **Be careful in production.** Consider locking the account first before permanent deletion.

---

## Group Management

Groups allow efficient permission management across multiple users — instead of assigning permissions per user, assign them to a group.

### Create a Group

```bash
sudo groupadd devops
```

```bash
grep devops /etc/group   # Verify
```

### Add User to a Group

```bash
sudo usermod -aG devops newdevopsuser
```

> ⚠️ **Always use `-aG` together.**  
> `-a` = append | `-G` = supplementary group  
> **Never use `-G` without `-a`** — it will overwrite existing groups!

```bash
groups newdevopsuser   # Verify
```

### Change Primary Group

```bash
sudo usermod -g devops newdevopsuser
```

```bash
id newdevopsuser   # Verify
```

### Remove User from a Group

```bash
sudo gpasswd -d newdevopsuser devops
```

### Delete a Group

```bash
sudo groupdel devops
```

> ⚠️ Ensure no critical user depends on the group before deleting.

---

## Important System Files

Linux stores all user and group data in key files under `/etc`.

### `/etc/passwd` — User Account Info

```bash
cat /etc/passwd
```

**Example entry:**
```
devopsuser:x:1001:1001::/home/devopsuser:/bin/bash
```

Contains: username, password placeholder, UID, GID, comment, home dir, shell.

---

### `/etc/shadow` — Encrypted Passwords

```bash
sudo cat /etc/shadow
```

**Example entry:**
```
devopsuser:$6$randomhashvalue:19800:0:99999:7:::
```

Contains: encrypted password hash, password aging details, expiry settings.

> 🔐 **Only root can read this file.**

---

### `/etc/group` — Group Info

```bash
cat /etc/group
```

**Example entry:**
```
devops:x:1002:newdevopsuser
```

Contains: group name, password placeholder, GID, group members.

---

## Sudo Access Management

> 💡 In production, **do not give blanket root access**. Use `sudo` with controlled permissions.

### Ubuntu / Debian — Add to `sudo` Group

```bash
sudo usermod -aG sudo newdevopsuser
```

### RHEL / CentOS / Amazon Linux — Add to `wheel` Group

```bash
sudo usermod -aG wheel newdevopsuser
```

### Verify sudo Access

```bash
su - newdevopsuser
sudo whoami
```

Expected output: `root`

### Edit Sudoers File Safely

```bash
sudo visudo
```

> ✅ Always use `visudo` — it **validates syntax before saving** and prevents breaking sudo access entirely.

---

## Real-World Production Use Cases

### ✅ Use Case 1: Onboarding a New Developer

```bash
sudo useradd -m -s /bin/bash developer1
sudo passwd developer1
sudo groupadd appteam
sudo usermod -aG appteam developer1
sudo usermod -aG wheel developer1
```

---

### 🚫 Use Case 2: Offboarding (Employee Left)

**Step 1: Lock the account first**

```bash
sudo passwd -l developer1
sudo chage -E 0 developer1
```

**Step 2: Later, permanently remove**

```bash
sudo userdel -r developer1
```

---

### 📁 Use Case 3: Shared Application Directory

```bash
sudo groupadd appgroup
sudo usermod -aG appgroup user1
sudo usermod -aG appgroup user2
sudo chown -R root:appgroup /opt/myapp
sudo chmod -R 775 /opt/myapp
```

> This is an extremely common pattern in production environments.

---

## Troubleshooting Scenarios

### ❌ Scenario 1: User Cannot Run sudo Commands

**Possible Causes:**
- User not in `wheel` or `sudo` group
- Sudoers misconfiguration
- Session not refreshed after group addition

**Checks:**

```bash
groups username
sudo visudo
id username
```

**Fix:**

```bash
sudo usermod -aG wheel username
# Ask the user to log out and log back in
```

---

### ❌ Scenario 2: User Created But Cannot Log In

**Possible Causes:**
- Password not set
- Shell is `/sbin/nologin`
- Account is locked
- Home directory missing

**Checks & Fixes:**

```bash
grep username /etc/passwd
sudo passwd -S username
ls -ld /home/username

# Fixes
sudo passwd username
sudo usermod -s /bin/bash username
sudo useradd -m username
```

---

### ❌ Scenario 3: Group Permissions Not Applying

Linux group changes require a new session.

```bash
# Log out and log back in, OR:
newgrp groupname
```

---

### ❌ Scenario 4: Accidentally Removed All Supplementary Groups

```bash
# ❌ WRONG — overwrites existing groups
sudo usermod -G devops username

# ✅ CORRECT — appends to existing groups
sudo usermod -aG devops username
```

---

## Security Best Practices

| # | Practice |
|---|----------|
| 1 | Follow the **Least Privilege Principle** |
| 2 | Give sudo access **only when necessary** |
| 3 | Use **groups** instead of per-user permission management |
| 4 | **Lock accounts** before deleting in production |
| 5 | Review **inactive users** regularly |
| 6 | Avoid **direct root login** where possible |
| 7 | Use **SSH keys** instead of passwords for critical servers |
| 8 | Always use **`visudo`** for sudoers edits |
| 9 | **Audit** `/etc/passwd`, `/etc/shadow`, `/etc/group` periodically |

---

## Interview Questions & Answers

**Q1. How do you create a new user in Linux?**

```bash
sudo useradd username
sudo passwd username
```

`useradd` creates the account; `passwd` sets the password.

---

**Q2. What is the difference between `/etc/passwd` and `/etc/shadow`?**

| File | Contents | Readable By |
|------|----------|-------------|
| `/etc/passwd` | Username, UID, GID, home dir, shell | All users |
| `/etc/shadow` | Encrypted password hashes, aging info | Root only |

---

**Q3. How do you add a user to a group?**

```bash
sudo usermod -aG groupname username
```

`-aG` appends to the supplementary group without removing existing memberships.

---

**Q4. How do you give sudo access to a user?**

```bash
# Ubuntu/Debian
sudo usermod -aG sudo username

# RHEL/CentOS/Amazon Linux
sudo usermod -aG wheel username
```

---

**Q5. How do you lock a user account?**

```bash
sudo passwd -l username
```

---

**Q6. How do you delete a user and their home directory?**

```bash
sudo userdel -r username
```

---

**Q7. Why is `visudo` preferred over editing `/etc/sudoers` directly?**

Because `visudo` **validates syntax before saving**. A syntax error in `/etc/sudoers` can break sudo access for the entire system.

---

**Q8. What happens if you use `usermod -G` without `-a`?**

It **replaces** the user's supplementary groups instead of appending — which can accidentally remove critical group memberships like `wheel` or `docker`.

---

## Quick Command Reference

```bash
# ── User Info ──────────────────────────────────────
whoami                              # Current user
id                                  # UID, GID, groups
groups username                     # List groups of a user

# ── Create Users ───────────────────────────────────
sudo useradd username               # Basic create
sudo useradd -m username            # With home directory
sudo useradd -m -s /bin/bash user   # With home + bash shell
sudo passwd username                # Set password

# ── Modify Users ───────────────────────────────────
sudo usermod -l newname oldname     # Rename
sudo usermod -d /new/home -m user   # Change home dir
sudo usermod -aG groupname user     # Add to group (append!)
sudo usermod -g groupname user      # Change primary group

# ── Lock / Unlock ──────────────────────────────────
sudo passwd -l username             # Lock account
sudo passwd -u username             # Unlock account

# ── Password Expiry ────────────────────────────────
sudo chage -l username              # View expiry info
sudo chage -E 2026-12-31 username   # Set expiry date

# ── Delete Users ───────────────────────────────────
sudo userdel username               # Delete user only
sudo userdel -r username            # Delete user + home dir

# ── Groups ─────────────────────────────────────────
sudo groupadd groupname             # Create group
sudo groupdel groupname             # Delete group
sudo gpasswd -d username groupname  # Remove user from group

# ── System Files ───────────────────────────────────
grep username /etc/passwd           # User info
sudo cat /etc/shadow                # Password hashes (root only)
grep groupname /etc/group           # Group info

# ── Sudo ───────────────────────────────────────────
sudo visudo                         # Safely edit sudoers
```

---

## Summary

Linux user and group management is a **core system administration skill** and is extremely important in DevOps and production support roles.

### What We Covered

| Topic | Key Takeaway |
|-------|-------------|
| User creation | `useradd` + `passwd` |
| Home & shell | Use `-m` and `-s` flags |
| Group management | Always use `-aG` to append |
| System files | `/etc/passwd`, `/etc/shadow`, `/etc/group` |
| Sudo access | `wheel` (RHEL) / `sudo` (Ubuntu) group |
| Production patterns | Lock first, delete later |
| Troubleshooting | Check groups, shell, password, session |
| Security | Least privilege, SSH keys, audit regularly |

> 🎯 Mastering this topic will help you confidently handle Linux administration tasks in real environments and clearly explain practical scenarios in interviews.

---

*📅 Day 03 of Linux Administration Series*