# Day 01 - Linux Basic Health Check Commands

## Objective
Learn and practice the most commonly used Linux commands for basic server health checks and initial troubleshooting.

These commands are heavily used in:
- Linux Administration
- Production Support
- DevOps
- Cloud Operations
- SRE troubleshooting

---

# 1. Check CPU Usage and System Load

## Command
```bash
top
Purpose

Displays real-time system resource usage, including:

CPU usage
Memory usage
Load average
Running processes
Top resource-consuming processes
Real-world Use

Used when:

Server is slow
CPU usage is high
Need to identify heavy processes
System performance is degraded
Example
top
2. Check Memory Usage
Command
free -m
Purpose

Shows memory usage in MB, including:

Total memory
Used memory
Free memory
Buff/cache memory
Swap usage
Real-world Use

Used when:

Application is slow
Server is running out of memory
Swap is being heavily used
Need to confirm available RAM
Example
free -m
3. Check Disk Usage
Command
df -h
Purpose

Displays disk usage of mounted file systems in human-readable format.

Shows:

Total disk size
Used space
Available space
Mounted paths
Real-world Use

Used when:

Disk is full
Logs are growing rapidly
Application fails with “No space left on device”
Root filesystem usage needs to be verified
Example
df -h
4. Check Directory Size
Command
du -sh /var/log
Purpose

Shows the total size of a specific directory in human-readable format.

Real-world Use

Used to identify:

Large log folders
Space-consuming directories
Unusual disk growth
Log accumulation issues
Example
du -sh /var/log
5. Check System Uptime and Load
Command
uptime
Purpose

Shows:

Current time
System uptime
Number of logged-in users
Load averages for 1, 5, and 15 minutes
Real-world Use

Used for:

Checking server stability
Confirming how long server has been running
Understanding system load trend
Verifying recent reboot impact
Example
uptime
6. Check Running Processes
Command
ps -ef
Purpose

Lists all running processes in full format.

Shows:

User owning the process
Process ID (PID)
Parent Process ID (PPID)
Start time
Command used to start the process
Real-world Use

Used to:

Find application processes
Verify if a service is running
Check parent-child process relationships
Investigate stuck or orphan processes
Example
ps -ef
7. Check Listening Ports
Command
ss -tulnp
Purpose

Shows:

Listening ports
TCP/UDP protocols
Bound IP addresses
Process associated with each port
Real-world Use

Used when:

Application is not reachable
Need to confirm service is listening on the expected port
Troubleshooting port conflicts
Verifying network exposure of services
Example
ss -tulnp
8. Check Last Login / Reboot History
Command
last
Purpose

Shows:

User login history
Logout times
Reboot records
Shutdown events
Real-world Use

Useful for:

Checking recent user access
Verifying reboot time after patching
Confirming outage or restart events
Auditing recent system activity
Example
last
Bonus Command - Check Service Status
Command
systemctl status <service-name>
Example
systemctl status nginx
Purpose

Shows:

Whether the service is active or failed
Recent logs for the service
Main process ID
Service startup status
Real-world Use

Used when:

Application/service is down
Need to confirm service health
Validating service after restart
Troubleshooting startup failures
Basic Troubleshooting Flow (Real-world Scenario)
Scenario: Application is not reachable

Follow this sequence:

1. Check if application process is running
ps -ef | grep <application-name>
2. Check service status
systemctl status <service-name>
3. Check if the application is listening on the expected port
ss -tulnp
4. Check disk usage
df -h
5. Check memory usage
free -m
6. Check CPU and top processes
top
7. Check logs
journalctl -xe

Or check application-specific logs, for example:

tail -f /var/log/messages
tail -f /var/log/syslog
tail -f /var/log/nginx/error.log
