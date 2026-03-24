# 🐧 Day 01 — Linux Basic Health Check Commands

> **Learn and practice the most commonly used Linux commands for basic server health checks and initial troubleshooting.**

These commands are heavily used in:
`Linux Administration` · `Production Support` · `DevOps` · `Cloud Operations` · `SRE Troubleshooting`

---

## 📋 Table of Contents

| # | Command | Purpose |
|---|---------|---------|
| 1 | [`top`](#1-check-cpu-usage-and-system-load) | CPU usage & system load |
| 2 | [`free -m`](#2-check-memory-usage) | Memory usage |
| 3 | [`df -h`](#3-check-disk-usage) | Disk usage |
| 4 | [`du -sh`](#4-check-directory-size) | Directory size |
| 5 | [`uptime`](#5-check-system-uptime-and-load) | System uptime & load |
| 6 | [`ps -ef`](#6-check-running-processes) | Running processes |
| 7 | [`ss -tulnp`](#7-check-listening-ports) | Listening ports |
| 8 | [`last`](#8-check-last-login--reboot-history) | Login & reboot history |
| ⭐ | [`systemctl status`](#-bonus--check-service-status) | Service status |

---

## 1. Check CPU Usage and System Load

```bash
top
```

**What it shows:**
- CPU usage per process
- Memory usage
- Load averages
- Running processes
- Top resource-consuming processes

**When to use it:**
- Server is slow or unresponsive
- CPU usage is spiking
- Need to identify heavy processes
- System performance is degraded

---

## 2. Check Memory Usage

```bash
free -m
```

**What it shows:**
- Total / Used / Free memory (in MB)
- Buff/cache usage
- Swap usage

**When to use it:**
- Application is slow
- Server is running out of memory
- Swap is being heavily used
- Need to confirm available RAM

---

## 3. Check Disk Usage

```bash
df -h
```

**What it shows:**
- Total disk size
- Used and available space
- Mounted filesystem paths

**When to use it:**
- Disk is full
- Logs are growing rapidly
- Application fails with `No space left on device`
- Need to verify root filesystem usage

---

## 4. Check Directory Size

```bash
du -sh /var/log
```

**What it shows:**
- Total size of a specific directory (human-readable)

**When to use it:**
- Identify large log folders
- Spot space-consuming directories
- Investigate unusual disk growth
- Check log accumulation issues

---

## 5. Check System Uptime and Load

```bash
uptime
```

**What it shows:**
- Current time
- How long the system has been running
- Number of logged-in users
- Load averages: `1 min` · `5 min` · `15 min`

**When to use it:**
- Checking server stability
- Confirming how long the server has been running
- Understanding system load trends
- Verifying impact after a recent reboot

---

## 6. Check Running Processes

```bash
ps -ef
```

**What it shows:**
- User owning the process
- Process ID (PID) and Parent Process ID (PPID)
- Process start time
- Command used to start the process

**When to use it:**
- Find application processes
- Verify if a service is running
- Check parent-child process relationships
- Investigate stuck or orphaned processes

---

## 7. Check Listening Ports

```bash
ss -tulnp
```

**What it shows:**
- Listening ports (TCP/UDP)
- Bound IP addresses
- Process name associated with each port

**When to use it:**
- Application is not reachable
- Confirm a service is listening on the expected port
- Troubleshoot port conflicts
- Verify network exposure of services

---

## 8. Check Last Login / Reboot History

```bash
last
```

**What it shows:**
- User login and logout history
- Reboot and shutdown records

**When to use it:**
- Checking recent user access
- Verifying reboot time after patching
- Confirming outage or restart events
- Auditing recent system activity

---

## ⭐ Bonus — Check Service Status

```bash
systemctl status <service-name>

# Example:
systemctl status nginx
```

**What it shows:**
- Whether the service is `active` or `failed`
- Recent service logs
- Main process ID
- Service startup status

**When to use it:**
- Application/service is down
- Need to confirm service health
- Validating service after restart
- Troubleshooting startup failures

---

## 🔧 Real-World Troubleshooting Flow

> **Scenario:** Application is not reachable

Follow this sequence step by step:

**Step 1** — Check if the application process is running
```bash
ps -ef | grep <application-name>
```

**Step 2** — Check service status
```bash
systemctl status <service-name>
```

**Step 3** — Check if the application is listening on the expected port
```bash
ss -tulnp
```

**Step 4** — Check disk usage
```bash
df -h
```

**Step 5** — Check memory usage
```bash
free -m
```

**Step 6** — Check CPU and top processes
```bash
top
```

**Step 7** — Check logs
```bash
# System logs
journalctl -xe

# Application-specific logs
tail -f /var/log/messages
tail -f /var/log/syslog
tail -f /var/log/nginx/error.log
```

---

> 💡 **Tip:** Bookmark this as your go-to reference for first-response Linux troubleshooting!
