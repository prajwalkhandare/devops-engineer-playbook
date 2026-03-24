# 🐧 Day 01 — Basic Linux Commands for DevOps

> **Learn frequently used Linux commands for file operations, navigation, and basic troubleshooting.**

These commands are used daily for:
`Server Navigation` · `Reading Logs` · `Backing Up Files` · `Searching Errors` · `Quick Troubleshooting`

---

## 📋 Table of Contents

| # | Command | Purpose |
|---|---------|---------|
| 1 | [`pwd`](#1-print-current-directory) | Print current directory |
| 2 | [`ls -l`](#2-list-files-and-directories) | List files and directories |
| 3 | [`cd`](#3-change-directory) | Change directory |
| 4 | [`mkdir`](#4-create-a-directory) | Create a directory |
| 5 | [`touch`](#5-create-an-empty-file) | Create an empty file |
| 6 | [`cat`](#6-view-file-content) | View file content |
| 7 | [`less`](#7-view-file-with-pagination) | View file with pagination |
| 8 | [`cp`](#8-copy-files) | Copy files |
| 9 | [`mv`](#9-move--rename-files) | Move / Rename files |
| 10 | [`rm`](#10-remove-files) | Remove files |
| 11 | [`grep`](#11-search-text-in-file) | Search text in file |
| 12 | [`wc -l`](#12-count-lines-in-file) | Count lines in file |
| 13 | [`tail -f`](#13-monitor-log-file-in-real-time) | Monitor log file in real time |
| 14 | [`find`](#14-find-files) | Find files |

---

## 1. Print Current Directory

```bash
pwd
```

**What it does:**
- Shows the full path of your current working directory

**When to use it:**
- Confirm where you are in the filesystem before running commands
- Avoid mistakes when creating or deleting files

---

## 2. List Files and Directories

```bash
ls -l
```

**What it shows:**
- File permissions
- Owner and group
- File size
- Last modification date
- File/directory names

**When to use it:**
- Browse directory contents
- Check file permissions
- Verify file ownership

---

## 3. Change Directory

```bash
cd /var/log
```

**What it does:**
- Moves into the specified directory

**Handy shortcuts:**

```bash
cd ~       # Go to home directory
cd ..      # Go one level up
cd -       # Go back to previous directory
```

---

## 4. Create a Directory

```bash
mkdir logs_backup
```

**What it does:**
- Creates a new directory at the specified path

**Tip:** Use `-p` to create nested directories in one go:
```bash
mkdir -p /opt/app/logs
```

---

## 5. Create an Empty File

```bash
touch app.log
```

**What it does:**
- Creates an empty file if it does not exist
- Updates the timestamp if the file already exists

**When to use it:**
- Quickly create placeholder or log files
- Reset a file's modification timestamp

---

## 6. View File Content

```bash
cat app.log
```

**What it does:**
- Displays the full content of a file in the terminal

**When to use it:**
- Read small config or log files
- Quickly verify file contents

> ⚠️ Avoid using `cat` on very large files — use `less` instead.

---

## 7. View File with Pagination

```bash
less /var/log/messages
```

**What it does:**
- Opens large files page by page without loading everything into memory

**Useful keys inside `less`:**

| Key | Action |
|-----|--------|
| `Space` | Next page |
| `b` | Previous page |
| `/keyword` | Search forward |
| `q` | Quit |

---

## 8. Copy Files

```bash
cp app.log app.log.bak
```

**What it does:**
- Creates a copy of the file at the specified destination

**Tip:** Copy entire directories with `-r`:
```bash
cp -r /opt/app /opt/app_backup
```

---

## 9. Move / Rename Files

```bash
mv app.log app_old.log
```

**What it does:**
- Renames a file if destination is in the same directory
- Moves a file if destination is a different path

**Example — Move to another directory:**
```bash
mv app.log /var/log/app.log
```

---

## 10. Remove Files

```bash
rm -f app_old.log
```

**What it does:**
- Deletes a file forcefully without prompting

**Remove an entire directory:**
```bash
rm -rf /tmp/old_logs
```

> ⚠️ **Be careful with `rm -rf`** — there is no recycle bin. Deleted files cannot be recovered.

---

## 11. Search Text in File

```bash
grep -i error /var/log/messages
```

**What it does:**
- Searches for the word `error` (case-insensitive) inside the file

**Useful `grep` options:**

```bash
grep -i "error" /var/log/messages       # Case-insensitive search
grep -n "error" /var/log/messages       # Show line numbers
grep -r "error" /var/log/               # Search recursively in a directory
grep -v "info" /var/log/messages        # Exclude lines matching "info"
```

---

## 12. Count Lines in File

```bash
wc -l app.log
```

**What it does:**
- Returns the total number of lines in a file

**When to use it:**
- Check how many log entries exist
- Verify file is not empty
- Count records in a data file

---

## 13. Monitor Log File in Real Time

```bash
tail -f /var/log/messages
```

**What it does:**
- Streams live updates to the log file as new lines are written

**Tip:** View last N lines without live monitoring:
```bash
tail -n 50 /var/log/messages    # Show last 50 lines
```

**When to use it:**
- Monitor application logs during deployment
- Watch for errors in real time
- Debug issues as they happen

---

## 14. Find Files

```bash
find /var/log -name "*.log"
```

**What it does:**
- Searches recursively for all `.log` files under `/var/log`

**More useful examples:**

```bash
find /var/log -name "*.log"              # Find by name pattern
find /opt/app -type f -name "*.conf"     # Find config files only
find /tmp -mtime +7                      # Files older than 7 days
find /var/log -size +100M                # Files larger than 100MB
```

---

## 🔧 Real-World Use Cases

| Task | Command |
|------|---------|
| Navigate to log directory | `cd /var/log` |
| Check available log files | `ls -l` |
| Monitor live logs | `tail -f /var/log/messages` |
| Search for errors | `grep -i error /var/log/messages` |
| Backup a config file | `cp nginx.conf nginx.conf.bak` |
| Check current location | `pwd` |
| Find large log files | `find /var/log -size +100M` |
| Count log entries | `wc -l /var/log/messages` |

---

> 💡 **Tip:** These 14 commands cover 80% of your daily Linux work as a DevOps engineer. Master them and you'll navigate any server confidently!
