# ⚙️ Day 04 — Linux Process Management

> **Role:** DevOps Engineer / Linux Administrator  
> **Topic:** Process Management in Production Linux Environments

---

## 📌 Table of Contents

1. [Introduction](#introduction)
2. [What is a Process?](#what-is-a-process)
3. [Key Process Terms](#key-process-terms)
4. [View Running Processes](#view-running-processes)
5. [Real-Time Monitoring](#real-time-monitoring)
6. [Process Tree View](#process-tree-view)
7. [Foreground vs Background Processes](#foreground-vs-background-processes)
8. [Kill a Process](#kill-a-process)
9. [Kill Signals Reference](#kill-signals-reference)
10. [Kill by Name](#kill-by-name)
11. [Find Process by Port](#find-process-by-port)
12. [CPU & Memory Monitoring](#cpu--memory-monitoring)
13. [Process Priority (nice & renice)](#process-priority-nice--renice)
14. [Run After Logout (nohup)](#run-after-logout-nohup)
15. [Pause & Resume a Process](#pause--resume-a-process)
16. [Service-Related Processes](#service-related-processes)
17. [Process States](#process-states)
18. [Zombie Processes](#zombie-processes)
19. [Real-World Production Use Cases](#real-world-production-use-cases)
20. [Troubleshooting Scenarios](#troubleshooting-scenarios)
21. [Security & Best Practices](#security--best-practices)
22. [Interview Questions & Answers](#interview-questions--answers)
23. [Quick Command Reference](#quick-command-reference)

---

## Introduction

Process management is one of the most important Linux administration skills for **DevOps Engineers**, **Cloud Support Engineers**, and **System Administrators**.

A **process** is simply a running instance of a program. Whenever you run a command, start an application, or launch a service, Linux creates a process.

### Why Process Management Matters in Production

| Scenario | Impact |
|----------|--------|
| Application consuming high CPU | Server slowdown, user impact |
| Service becomes unresponsive | Downtime, SLA breach |
| Background jobs running after logout | Resource waste, unexpected behavior |
| Zombie processes accumulating | System instability |
| Stuck processes not releasing ports | New deployments fail |

---

## What is a Process?

A process is a running program with its own:

- Unique **PID** (Process ID)
- **PPID** (Parent Process ID)
- CPU and memory usage
- Process state (running, sleeping, stopped, zombie...)
- Owner (which user started it)

### Example

When you run:

```bash
sleep 300
```

Linux creates a new process for `sleep` with a unique PID, visible in `ps` or `top`.

---

## Key Process Terms

| Term | Description |
|------|-------------|
| **PID** | Process ID — unique identifier for every process |
| **PPID** | Parent Process ID — who spawned this process |
| **Foreground Process** | Runs in the current terminal and blocks it |
| **Background Process** | Runs in background; terminal remains free |
| **Daemon** | Background system/service process (e.g., `sshd`, `httpd`) |
| **Zombie Process** | Completed but still in process table (parent hasn't read exit status) |
| **Orphan Process** | Child whose parent has exited |

---

## View Running Processes

### Basic `ps` — Current Terminal Only

```bash
ps
```

```
  PID TTY          TIME CMD
 2345 pts/0    00:00:00 bash
 2401 pts/0    00:00:00 ps
```

---

### `ps -ef` — All Processes (Full Format)

> 🏭 One of the **most-used commands in production.**

```bash
ps -ef
```

| Flag | Meaning |
|------|---------|
| `-e` | Show all processes |
| `-f` | Full format (UID, PID, PPID, time, command) |

```
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 08:00 ?        00:00:02 /sbin/init
root       722     1  0 08:01 ?        00:00:01 /usr/sbin/sshd -D
ec2-user   990   988  0 08:10 pts/0    00:00:00 -bash
```

---

### Search for a Specific Process

```bash
ps -ef | grep sshd
```

> ⚠️ `grep` itself may appear in the results.

**Better approach — exclude grep from results:**

```bash
ps -ef | grep [s]shd
```

---

### Check a Process by PID

```bash
ps -p 722         # Basic
ps -fp 722        # Detailed
```

```
UID        PID  PPID  C STIME TTY          TIME CMD
root       722     1  0 08:01 ?        00:00:01 /usr/sbin/sshd -D
```

---

## Real-Time Monitoring

### `top` — Live Process View

```bash
top
```

Displays live: CPU usage, memory, load average, running processes, and top consumers.

**Useful keyboard shortcuts inside `top`:**

| Key | Action |
|-----|--------|
| `P` | Sort by CPU usage |
| `M` | Sort by memory usage |
| `k` | Kill a process |
| `q` | Quit |

---

### `htop` — Enhanced Interactive Monitor

```bash
htop
```

> ⚠️ May not be installed by default. Install with `sudo yum install htop` or `sudo apt install htop`.

**Advantages over `top`:**

- Better UI with color coding
- Easier sorting and navigation
- Mouse support
- Easier process killing

---

## Process Tree View

Understand **parent-child relationships** between processes:

```bash
pstree
```

```
systemd─┬─sshd───sshd───bash
        ├─cron
        └─httpd───httpd───httpd
```

> 💡 Extremely useful in production troubleshooting to trace which parent spawned a problem process.

---

## Foreground vs Background Processes

### Foreground Process

Blocks the terminal until it finishes:

```bash
sleep 100
```

### Run Directly in Background

```bash
sleep 100 &
```

```
[1] 2456
```

> `[1]` = job number | `2456` = PID. Terminal is now free.

---

### View Background Jobs

```bash
jobs
```

```
[1]+  Running    sleep 100 &
```

---

### Bring to Foreground

```bash
fg %1
```

---

### Send Running Process to Background

1. Start a command:
   ```bash
   sleep 200
   ```
2. Press `Ctrl + Z` → pauses the process
3. Resume in background:
   ```bash
   bg
   ```

---

## Kill a Process

### Graceful Kill (SIGTERM)

```bash
kill 2456
```

Sends **SIGTERM (15)** — asks the process to terminate gracefully (allows cleanup).

---

### Force Kill (SIGKILL)

```bash
kill -9 2456
```

Sends **SIGKILL (9)** — forcefully terminates immediately with no cleanup.

> ⚠️ Use `kill -9` only when graceful kill fails. Avoid on critical system processes.

---

## Kill Signals Reference

```bash
kill -l    # List all signals
```

| Signal | Number | Description |
|--------|--------|-------------|
| `SIGTERM` | 15 | Graceful termination *(default)* |
| `SIGKILL` | 9  | Force kill — no cleanup |
| `SIGHUP`  | 1  | Reload/restart (used by some daemons) |
| `SIGINT`  | 2  | Interrupt (like `Ctrl+C`) |
| `SIGSTOP` | 19 | Pause a process |
| `SIGCONT` | 18 | Continue a paused process |

---

## Kill by Name

### `pkill` — Kill by Pattern Match

```bash
pkill nginx          # Graceful
pkill -9 nginx       # Force kill
```

### `killall` — Kill All with Exact Name

```bash
killall nginx
```

> ⚠️ Both commands can affect **multiple processes** at once — use carefully in production. Always verify with `ps -ef | grep [n]ame` first.

---

## Find Process by Port

> 🏭 One of the **most common production troubleshooting tasks.**  
> *"App is not reachable — what process is holding the port?"*

### Using `ss` (Modern, Preferred)

```bash
ss -tulnp
```

```
tcp  LISTEN  0  128  0.0.0.0:8080  0.0.0.0:*  users:(("java",pid=3210,fd=123))
```

| Info | Value |
|------|-------|
| Port | `8080` |
| Process | `java` |
| PID | `3210` |

**Filter to a specific port:**

```bash
ss -tulnp | grep 8080
```

### Using `netstat` (Older Systems)

```bash
netstat -tulnp | grep 8080
```

---

## CPU & Memory Monitoring

### Top CPU Consumers

```bash
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
```

### Top Memory Consumers

```bash
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
```

---

## Process Priority (nice & renice)

Linux allows processes to run with different scheduling priorities.

### Check Nice Values

```bash
ps -eo pid,cmd,nice
```

| Nice Value | Priority |
|------------|----------|
| `-20` | Highest priority |
| `0` | Default |
| `19` | Lowest priority |

---

### Start a Process with Lower Priority

```bash
nice -n 10 tar -czf backup.tar.gz /var/log
```

> 💡 Use lower priority for non-critical tasks: backups, compression, log archiving, batch jobs.

---

### Change Priority of a Running Process

```bash
sudo renice 5 -p 3210
```

This changes the nice value of PID `3210` to `5`.

---

## Run After Logout (nohup)

Keep a command running even after closing the terminal:

```bash
nohup python3 app.py &
```

```
nohup: ignoring input and appending output to 'nohup.out'
```

Output is saved to `nohup.out` by default.

**Verify it's running:**

```bash
ps -ef | grep [a]pp.py
```

> 💡 Useful for: scripts, background automation, temporary app testing, long-running commands.

---

## Pause & Resume a Process

### Pause (Temporary Stop)

```bash
kill -STOP 3210
```

### Resume

```bash
kill -CONT 3210
```

> Useful for **temporary control during troubleshooting** without killing the process.

---

## Service-Related Processes

Many production processes run as **system services**.

### Check Service Status

```bash
systemctl status sshd
```

```
● sshd.service - OpenSSH server daemon
   Active: active (running)
   Main PID: 722 (sshd)
```

### Combined Troubleshooting Flow

```bash
systemctl status nginx          # Service state + recent logs
ps -ef | grep [n]ginx           # Process details
ss -tulnp | grep 80             # Port binding confirmation
```

---

## Process States

```bash
ps aux
```

| State | Code | Meaning |
|-------|------|---------|
| Running | `R` | Actively using CPU |
| Sleeping | `S` | Waiting for event/input |
| Uninterruptible Sleep | `D` | Waiting for I/O (disk, network) |
| Stopped | `T` | Paused (e.g., via `Ctrl+Z`) |
| Zombie | `Z` | Completed but not yet cleaned up |

---

## Zombie Processes

A **zombie process** has completed execution but remains in the process table because its **parent hasn't collected its exit status**.

### Detect Zombies

```bash
ps aux | grep Z
```

### How to Handle

> ❗ You **cannot kill a zombie directly** — it's already dead.

- Identify the **parent process** (via PPID)
- Restart or fix the parent process
- The zombie will be cleaned up automatically

---

## Real-World Production Use Cases

### 🔴 Use Case 1: High CPU on Server

**Symptoms:** Server slow, high load average, application delayed

```bash
top
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
```

**Action:**

```bash
kill PID       # Try graceful first
kill -9 PID    # Force if needed
```

---

### 🔴 Use Case 2: Java App Running But Not Reachable

```bash
ps -ef | grep [j]ava           # Is the process alive?
ss -tulnp | grep 8080          # Is it listening on the port?
systemctl status myapp         # Did the service start correctly?
```

**Possible findings:**

- Java process not running
- App not binding to port
- Port conflict with another process
- Service in a failed state

---

### 🔴 Use Case 3: Process Stuck / Unresponsive

```bash
kill PID        # Try graceful first
kill -9 PID     # Force if still stuck
```

---

### 🔴 Use Case 4: Script Must Keep Running After Logout

```bash
nohup ./backup.sh &
ps -ef | grep [b]ackup.sh     # Verify it's still running
```

---

## Troubleshooting Scenarios

### ❌ Scenario 1: Process Running But App Not Accessible

```bash
ps -ef | grep [a]ppname
ss -tulnp | grep 8080
curl http://localhost:8080
```

**Root causes:**

- App exists but not listening on the port
- Bound to wrong address (e.g., `127.0.0.1` instead of `0.0.0.0`)
- Firewall blocking the port
- Startup incomplete

---

### ❌ Scenario 2: Process Keeps Restarting

```bash
systemctl status appservice
journalctl -u appservice -n 50
```

**Root causes:**

- Crash loop due to config error
- Port already in use
- Missing dependencies or file permissions

---

### ❌ Scenario 3: High Memory Usage

```bash
top
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
free -m
```

**Actions:**

- Restart the service to reclaim memory
- Investigate for memory leaks
- Scale up resources if persistent

---

### ❌ Scenario 4: Wrong Process Killed Accidentally

> ✅ **Best Practice:** Always verify PID before killing.

```bash
ps -fp PID    # Confirm what you're about to kill
kill PID      # Only after confirmation
```

---

## Security & Best Practices

| # | Practice |
|---|----------|
| 1 | Prefer `kill` (SIGTERM) before `kill -9` |
| 2 | Always verify PID with `ps -fp PID` before killing |
| 3 | Use `pkill` and `killall` carefully — they affect multiple processes |
| 4 | Use `nohup` for long-running background tasks |
| 5 | Monitor CPU and memory regularly with `top` |
| 6 | Use `systemctl status` for service-based apps |
| 7 | Check port binding with `ss -tulnp` |
| 8 | Understand parent-child process relationships using `pstree` |
| 9 | Never force-kill critical system processes without cause |
| 10 | Use `nice` to lower priority for non-critical background jobs |

---

## Interview Questions & Answers

**Q1. What is a process in Linux?**

A process is a running instance of a program. Each process has a unique PID, consumes CPU and memory, and can be managed using commands like `ps`, `top`, and `kill`.

---

**Q2. What is the difference between `ps` and `top`?**

| Command | Type | Use |
|---------|------|-----|
| `ps` | Static snapshot | Point-in-time view of processes |
| `top` | Live/real-time | Continuously updated CPU, memory, and process view |

---

**Q3. What is the difference between `kill` and `kill -9`?**

| Command | Signal | Behavior |
|---------|--------|----------|
| `kill PID` | SIGTERM (15) | Graceful termination — process can clean up |
| `kill -9 PID` | SIGKILL (9) | Immediate force kill — no cleanup |

Always try `kill` first. Use `kill -9` only when the process doesn't respond.

---

**Q4. How do you find which process is using port 8080?**

```bash
ss -tulnp | grep 8080
```

This returns the process name, PID, and socket details.

---

**Q5. What is `nohup` used for?**

`nohup` allows a command or script to keep running even after the user logs out or the terminal session closes. Output is redirected to `nohup.out`.

---

**Q6. What is a zombie process?**

A zombie process has finished execution but still occupies an entry in the process table because its parent has not yet read its exit status. You fix it by restarting the parent — not by killing the zombie directly.

---

**Q7. What is the difference between `pkill` and `killall`?**

| Command | Behavior |
|---------|----------|
| `pkill` | Matches by pattern — more flexible |
| `killall` | Matches by exact process name |

Both kill multiple processes — use carefully in production.

---

**Q8. What is the nice value in Linux?**

Nice value controls process scheduling priority:

| Value | Priority |
|-------|----------|
| `-20` | Highest |
| `0` | Default |
| `19` | Lowest |

Use `nice` (at launch) or `renice` (for running processes) to adjust.

---

## Quick Command Reference

```bash
# ── View Processes ──────────────────────────────────
ps                                              # Current terminal
ps -ef                                          # All processes, full format
ps -ef | grep [p]rocessname                     # Search specific process
ps -p PID                                       # By PID
ps -fp PID                                      # Detailed by PID
ps aux                                          # BSD style (shows %CPU, %MEM, state)

# ── Real-Time Monitoring ────────────────────────────
top                                             # Live view
htop                                            # Enhanced live view
pstree                                          # Process tree

# ── Background / Foreground ─────────────────────────
sleep 100 &                                     # Run in background
jobs                                            # List background jobs
fg %1                                           # Bring job 1 to foreground
bg                                              # Resume stopped job in background

# ── Kill Processes ──────────────────────────────────
kill PID                                        # Graceful (SIGTERM)
kill -9 PID                                     # Force kill (SIGKILL)
kill -l                                         # List all signals
pkill processname                               # Kill by name (pattern)
pkill -9 processname                            # Force kill by name
killall processname                             # Kill all with exact name

# ── Port & Network ──────────────────────────────────
ss -tulnp                                       # All listening ports + PIDs
ss -tulnp | grep 8080                           # Filter by port
netstat -tulnp | grep 8080                      # Older systems

# ── CPU & Memory ────────────────────────────────────
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head   # Top CPU consumers
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head   # Top memory consumers
free -m                                              # System memory overview

# ── Priority ────────────────────────────────────────
ps -eo pid,cmd,nice                             # View nice values
nice -n 10 command                              # Start with lower priority
sudo renice 5 -p PID                            # Change priority of running process

# ── Persist After Logout ────────────────────────────
nohup command &                                 # Keep running after logout

# ── Pause / Resume ──────────────────────────────────
kill -STOP PID                                  # Pause a process
kill -CONT PID                                  # Resume a paused process

# ── Services ────────────────────────────────────────
systemctl status servicename                    # Service state + Main PID
journalctl -u servicename -n 50                 # Recent service logs

# ── Zombies ─────────────────────────────────────────
ps aux | grep Z                                 # Find zombie processes
curl http://localhost:8080                      # Test app reachability
```

---

## Summary

| Topic | Key Takeaway |
|-------|-------------|
| View processes | `ps -ef` for snapshot, `top` for real-time |
| Search process | `ps -ef \| grep [n]ame` (bracket trick avoids self-match) |
| Kill process | `kill` (graceful) → `kill -9` (force) |
| Port → PID | `ss -tulnp \| grep PORT` |
| Background jobs | `command &`, `jobs`, `fg`, `bg` |
| Persist after logout | `nohup command &` |
| Priority control | `nice` (new), `renice` (running) |
| Zombie processes | Fix/restart the parent — can't kill directly |
| Service processes | `systemctl status` + `ps` + `ss` together |

> 🎯 Process management is the first line of defense in **production incident response**. Master these commands and you'll resolve most server issues with confidence.

---

*📅 Day 04 of Linux Administration Series*