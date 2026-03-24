##: Day 1 Script File

## `01-linux-shell/scripts/day01-disk-check.sh`

```bash
#!/bin/bash
# Day 01 - Disk Usage Monitoring Script
# This script checks disk usage and prints a warning if usage exceeds threshold.

THRESHOLD=80

echo "===== Disk Usage Check ====="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo

df -h | awk 'NR>1 {print $1, $5, $6}' | while read filesystem usage mountpoint
do
  percent=$(echo $usage | tr -d '%')

  echo "Filesystem: $filesystem | Usage: $usage | Mount: $mountpoint"

  if [ "$percent" -ge "$THRESHOLD" ]; then
    echo "WARNING: Disk usage on $mountpoint is above ${THRESHOLD}%"
  fi
done

echo
echo "Disk check completed."

###  7. Make Script Executable
Run:
chmod +x 01-linux-shell/scripts/day01-disk-check.sh

Test it:
./01-linux-shell/scripts/day01-disk-check.sh

