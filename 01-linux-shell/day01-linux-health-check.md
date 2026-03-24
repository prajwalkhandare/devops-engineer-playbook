# Day 01 - Linux Health Check Commands

## Objective
Learn the basic Linux commands used to check server health during production troubleshooting and routine validation.

---

## 1. Check CPU and Running Processes

```bash
top
Purpose

Displays:

CPU usage
Memory usage
Load average
Running processes

Real-world Use

Used when:

Server is slow
CPU is high
Need to identify heavy processes

## 2. Check Memory Usage
free -m

Purpose

Shows:

Total memory
Used memory
Free memory
Swap usage

Real-world Use

Used when:

Application is slow
Server is running out of memory
Checking swap usage


## 3. Check Disk Usage
df -h

Purpose

Displays disk usage of mounted file systems in human-readable format.

Real-world Use

Used when:

Disk is full
Logs are growing
Application fails due to no space left on device

### 4. Check Directory Size
du -sh /var/log

Purpose

Shows the total size of a specific directory.

Real-world Use

Used to find:

Large log folders
Space-consuming directories
Unusual disk growth

### 5. Check System Uptime and Load
uptime

Purpose

Shows:

Current time
System uptime
Number of users
Load averages (1, 5, 15 minutes)
Real-world Use

Used for:

Checking server stability
Understanding system load trend

### 6. Check Running Processes
ps -ef

Purpose

Lists all running processes in full format.

Real-world Use

Used to:

Find application process
Verify service is running
Check parent-child processes

### 7. Check Listening Ports
ss -tulnp

Purpose

Shows:

Listening ports
Protocols (TCP/UDP)
Process associated with each port
Real-world Use

Used when:

Application is not reachable
Need to confirm service is listening on expected port
Troubleshooting port conflicts

### 8. Check Last Login / Reboot History
last

Purpose

Shows login history and reboot records.

Real-world Use

Useful for:

Checking recent access
Verifying reboot time after patching or outage


Sample Troubleshooting Flow

If application is not reachable:

Check process using ps -ef
Check service status using systemctl status <service>
Check listening port using ss -tulnp
Check disk using df -h
Check memory using free -m
Check logs using journalctl -xe or app logs


