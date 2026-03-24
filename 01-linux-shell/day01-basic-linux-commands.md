## `01-linux-shell/day01-basic-linux-commands.md`

```md
# Day 01 - Basic Linux Commands for DevOps

## Objective
Learn frequently used Linux commands for file operations, navigation, and basic troubleshooting.

---

### 1. Print Current Directory
pwd
Shows the current working directory.

### 2.List Files and Directories
ls -l
Shows detailed listing including:

permissions
owner
group
size
modification date

### 3. Change Directory
cd /var/log
Moves into the specified directory

### 4. Create a Directory
mkdir logs_backup
Creates a new directory.

### 5. Create an Empty File
touch app.log
Creates an empty file if it does not exist.

### 6. View File Content
cat app.log
Displays the full content of a file.

### 7. View File with Pagination
less /var/log/messages
Used for reading large files page by page.

### 8. Copy Files
cp app.log app.log.bak
Creates a backup copy of the file

### 9. Move / Rename Files
mv app.log app_old.log
Renames or moves a file.

### 10. Remove Files
rm -f app_old.log
Deletes a file forcefully.

### 11. Search Text in File
grep -i error /var/log/messages
Searches for the word "error" ignoring case.

### 12. Count Lines in File
wc -l app.log
Returns the total number of lines in a file.

### 13. Show Last Lines of a Log File
tail -f /var/log/messages
Monitors log file updates in real time.

### 14. Find Files
find /var/log -name "*.log"
Finds all .log files under /var/log.

Real-world Use Cases

These commands are used daily for:

Navigating servers
Reading logs
Backing up files
Searching errors
Verifying configuration files
Performing quick troubleshooting