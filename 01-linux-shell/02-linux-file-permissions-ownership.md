# 🔐 Day 02 — Linux File Permissions, Ownership & Access Troubleshooting

> **Master Linux file permissions and ownership — the #1 cause of production access failures.**

Many real-world incidents happen because of:
`Permission Denied Errors` · `Scripts Not Executing` · `Services Can't Read Configs` · `Apps Can't Write Logs` · `Wrong Ownership After Deployments`

---

## 📋 Table of Contents

| # | Topic | Command |
|---|-------|---------|
| 1 | [Check File Permissions](#1-check-file-permissions) | `ls -l` |
| 2 | [Understand Permission Model](#2-understand-the-permission-model) | Concept |
| 3 | [Numeric Permission Values](#3-numeric-permission-values) | Concept |
| 4 | [Change File Permissions](#4-change-file-permissions) | `chmod` |
| 5 | [Change File Ownership](#5-change-file-ownership) | `chown` |
| 6 | [Change Group Ownership](#6-change-group-ownership) | `chgrp` |
| 7 | [Check Current User & Groups](#7-check-current-user-and-group-membership) | `whoami` · `id` |
| 8 | [Check Directory Permissions](#8-check-directory-permissions) | `ls -ld` |
| 9 | [Find Files by Permission](#9-find-files-with-specific-permissions) | `find` |
| 10 | [Default Permissions (umask)](#10-check-default-permissions-with-umask) | `umask` |
| 11 | [File Types in `ls -l`](#11-common-file-types-in-ls--l) | Reference |
| 🔥 | [Scenario 1 — Script Not Executing](#-scenario-1--script-not-executing) | Troubleshooting |
| 🔥 | [Scenario 2 — App Can't Write Logs](#-scenario-2--application-cannot-write-logs) | Troubleshooting |
| 🎯 | [Interview Tip](#-interview-tip) | Career |
| 🧪 | [Practice Tasks](#-practice-tasks) | Hands-on |

---

## 1. Check File Permissions

```bash
ls -l
```

**Sample output:**
```
-rwxr-xr-- 1 appuser appgroup 2048 Mar 25 10:30 deploy.sh
```

**Breaking it down:**

```
- rwx r-x r--
│ │   │   └── Others  → read only
│ │   └────── Group   → read + execute
│ └────────── Owner   → read + write + execute
└──────────── File type ( - = regular file )
```

**When to use it:**
- A script is not executable
- A config file is not readable by a service
- Need to verify file ownership after deployment

---

## 2. Understand the Permission Model

Linux permissions are split across **3 categories**, each with **3 possible rights:**

```
Category    Symbol    Meaning
──────────────────────────────
Owner       rwx       Who created / owns the file
Group       r-x       Users belonging to the file's group
Others      r--       Everyone else on the system
```

```
Permission    Symbol    Value
──────────────────────────────
Read          r         4
Write         w         2
Execute       x         1
No access     -         0
```

**When to use this knowledge:**
- Diagnosing `Permission denied` errors
- Script execution failures
- Service startup failures due to inaccessible config files

---

## 3. Numeric Permission Values

Each permission set is the **sum of r + w + x values.**

### Common Production Permissions

| Numeric | Symbolic | Owner | Group | Others | Use Case |
|---------|----------|-------|-------|--------|----------|
| `755` | `rwxr-xr-x` | rwx | r-x | r-x | Scripts, executable directories |
| `644` | `rw-r--r--` | rw- | r-- | r-- | Config files, text files |
| `700` | `rwx------` | rwx | --- | --- | Private scripts |
| `600` | `rw-------` | rw- | --- | --- | SSH keys, secrets, sensitive configs |
| `777` | `rwxrwxrwx` | rwx | rwx | rwx | ⚠️ Avoid — insecure, overly open |

> 💡 **Quick formula:** Owner + Group + Others → e.g. `7(rwx) + 5(r-x) + 5(r-x)` = `755`

---

## 4. Change File Permissions

```bash
chmod [permission] [file]
```

**Make a script executable:**
```bash
chmod +x deploy.sh
```

**Set permissions using numeric mode:**
```bash
chmod 755 deploy.sh        # Scripts and executables
chmod 644 app.conf         # Config files
chmod 600 secret.txt       # Sensitive files / SSH keys
chmod 700 private.sh       # Private scripts
```

**Recursive — apply to all files in a directory:**
```bash
chmod -R 755 /opt/myapp
```

**When to use it:**
- Script shows `Permission denied`
- Deployment created files with incorrect permissions
- Securing sensitive files after creation

---

## 5. Change File Ownership

```bash
chown [user]:[group] [file]
```

**Change owner only:**
```bash
chown appuser deploy.sh
```

**Change owner and group together:**
```bash
chown appuser:appgroup deploy.sh
```

**Recursive — change ownership of entire directory:**
```bash
chown -R appuser:appgroup /opt/myapp
```

**When to use it:**
- Application runs under a service account
- Deployment created files as `root` but service runs as `appuser`
- Log directory has wrong ownership
- Service cannot read or write files it needs

---

## 6. Change Group Ownership

```bash
chgrp [group] [file]
```

**Example:**
```bash
chgrp developers app.log
```

**When to use it:**
- Multiple users need shared access to a file
- Team-based file access model is required
- Shared directory in a multi-user environment

---

## 7. Check Current User and Group Membership

```bash
whoami        # Shows current logged-in username
id            # Shows UID, GID, and all group memberships
```

**Sample output of `id`:**
```
uid=1001(appuser) gid=1001(appgroup) groups=1001(appgroup),27(sudo),1002(developers)
```

**When to use it:**
- Troubleshooting `Permission denied` — confirm which user is running the command
- Verify if the user belongs to the required group
- Confirm service account identity before applying permissions

---

## 8. Check Directory Permissions

```bash
ls -ld /path/to/directory
```

**Example:**
```bash
ls -ld /var/log/myapp
```

**Sample output:**
```
drwxr-x--- 2 appuser appgroup 4096 Mar 25 11:00 /var/log/myapp
```

> ⚠️ `ls -l` lists files **inside** the directory. `ls -ld` shows permissions **of** the directory itself.

**When to use it:**
- Application cannot enter or traverse a directory
- Service cannot create files inside a directory
- Need to verify directory-level write access

---

## 9. Find Files with Specific Permissions

**Find all shell scripts and list their permissions:**
```bash
find /opt/myapp -type f -name "*.sh" -exec ls -l {} \;
```

**Find files with dangerously open `777` permissions:**
```bash
find /var/log -type f -perm 777
```

**Find files owned by a specific user:**
```bash
find /opt/myapp -user appuser
```

**Find files NOT owned by root (security check):**
```bash
find /etc -not -user root -type f
```

**When to use it:**
- Security audits
- Finding overly permissive files
- Verifying deployment artifacts
- Identifying incorrect ownership after releases

---

## 10. Check Default Permissions with umask

```bash
umask
```

**Sample output:**
```
0022
```

**How umask works:**

| umask | New File Default | New Directory Default |
|-------|------------------|-----------------------|
| `022` | `644` (rw-r--r--) | `755` (rwxr-xr-x) |
| `027` | `640` (rw-r-----) | `750` (rwxr-x---) |
| `077` | `600` (rw-------) | `700` (rwx------) |

**Change umask temporarily for current session:**
```bash
umask 027
```

**When to use it:**
- Newly created files have unexpected permissions
- Deployment user creates files that are too open or too restrictive
- Enforcing a consistent default security posture

---

## 11. Common File Types in `ls -l`

The **first character** in `ls -l` output tells you the file type:

| Symbol | Type | Example |
|--------|------|---------|
| `-` | Regular file | `-rwxr-xr-x` |
| `d` | Directory | `drwxr-xr-x` |
| `l` | Symbolic link | `lrwxrwxrwx` |
| `c` | Character device | `crw-rw-rw-` |
| `b` | Block device | `brw-rw----` |

---

## 🔥 Scenario 1 — Script Not Executing

**Error:**
```
bash: ./deploy.sh: Permission denied
```

**Troubleshooting steps:**

```bash
# Step 1 — Check file permissions
ls -l deploy.sh

# Step 2 — Add execute permission
chmod +x deploy.sh

# Step 3 — Fix ownership if wrong user
chown appuser:appgroup deploy.sh

# Step 4 — Run again
./deploy.sh
```

**Common root causes:**
- Script uploaded without the execute bit set
- File copied from Windows (no execute bit on Linux)
- File owned by `root` but executed as `appuser`

---

## 🔥 Scenario 2 — Application Cannot Write Logs

**Error in app logs:**
```
ERROR: Unable to open log file /var/log/myapp/app.log — Permission denied
```

**Troubleshooting steps:**

```bash
# Step 1 — Check log directory permissions
ls -ld /var/log/myapp

# Step 2 — Check individual log files
ls -l /var/log/myapp

# Step 3 — Fix ownership recursively
chown -R appuser:appgroup /var/log/myapp

# Step 4 — Set correct directory permissions
chmod -R 755 /var/log/myapp

# Step 5 — Restart the service
systemctl restart myapp
```

**Common root causes:**
- Log directory created by `root` during setup
- Service runs as a non-root user (correct) but directory isn't owned by it
- Wrong permissions applied after deployment
- Old log files from a previous account remain

---

## 🔁 Permission Troubleshooting Flow

> **Whenever you see `Permission denied` — follow this sequence:**

```
1. Check who you are
   └── whoami && id

2. Check file / directory permissions
   └── ls -l <file>  OR  ls -ld <directory>

3. Verify ownership
   └── Check owner and group in ls -l output

4. Fix permissions if needed
   └── chmod <permission> <file>

5. Fix ownership if needed
   └── chown <user>:<group> <file>

6. Re-test
   └── ./script.sh  OR  systemctl restart <service>
```

---

## 🎯 Interview Tip

When asked about Linux permissions in an interview, answer like this:

> *"Permission and ownership issues are among the most common problems in Linux production environments. My approach is to first identify the current user context using `whoami` and `id`, then inspect the file or directory with `ls -l` or `ls -ld`. Based on what I find, I correct permissions using `chmod` and ownership using `chown` or `chgrp`. In production, I've resolved issues like scripts missing the execute bit, applications unable to write logs because the directory was owned by root, and services failing because config files weren't accessible to the service account."*

---

## 🧪 Practice Tasks

Run these commands in your Linux VM and observe the output:

```bash
# Step 1 — Check your identity
whoami
id

# Step 2 — List files with permissions
ls -l

# Step 3 — Create a test file and check its permissions
touch testfile.txt
ls -l testfile.txt

# Step 4 — Apply different permissions and observe
chmod 644 testfile.txt && ls -l testfile.txt
chmod 755 testfile.txt && ls -l testfile.txt
chmod 600 testfile.txt && ls -l testfile.txt

# Step 5 — Create a directory and check its permissions
mkdir testdir
ls -ld testdir

# Step 6 — Check default permission mask
umask
```

---

## 📝 Day 02 Summary

| Topic | Command | Key Use |
|-------|---------|---------|
| View permissions | `ls -l` | Inspect files |
| View directory perms | `ls -ld` | Inspect directories |
| Change permissions | `chmod` | Fix access issues |
| Change ownership | `chown` | Fix owner/group |
| Change group | `chgrp` | Team-based access |
| Current user | `whoami` · `id` | Confirm identity |
| Find by permission | `find` | Audits & checks |
| Default permissions | `umask` | Secure defaults |

> 💡 **This is one of the most tested topics in DevOps, SRE, and Linux Admin interviews. Know it cold.**

