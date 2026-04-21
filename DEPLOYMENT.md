# Server Deployment Checklist

Complete list of tasks needed when deploying a new AzerothCore server.

## Pre-Deployment (GitHub Setup)

- [ ] Ensure `testing` branch has all desired modules
- [ ] Configure module settings in `configs/test/`
- [ ] Test build in `acore-test` folder
- [ ] Verify all modules load without errors
- [ ] Merge `testing` → `stable` when ready
- [ ] Tag backup: `git tag -a backup-YYYY-MM-DD -m "Before deploy"`

## Server Setup (First Time)

### 1. Clone and Build

```bash
# Clone your fork
git clone --branch stable git@github.com:oddessax/azerothcore-wotlk.git acore-live
cd acore-live
git submodule update --init --recursive

# Build
mkdir build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### 2. Database Setup

- [ ] Install MariaDB/MySQL
- [ ] Create databases: `acore_world`, `acore_characters`, `acore_auth`
- [ ] Import world database from SQL files
- [ ] Run module SQL files from `modules/*/data/sql/`
- [ ] Create database user with permissions

### 3. Configuration Files

- [ ] Copy `worldserver.conf.dist` → `worldserver.conf`
- [ ] Copy `authserver.conf.dist` → `authserver.conf`
- [ ] Configure database connections in both files
- [ ] Set server name, realm ID, etc.
- [ ] **Copy module configs from repo:**
  ```bash
  cp ~/acore-live/configs/live/*.conf ~/acore-live/build/etc/
  ```
- [ ] **Copy breaking news HTML:**
  ```bash
  cp ~/acore-live/configs/live/breakingnews.html ~/acore-live/build/etc/
  ```

### 4. Auto-Restart Setup (Important!)

The server is configured to shut down at 4am daily. You MUST set up auto-restart.

**Option A: Simple Loop Script (easiest)**

Create `~/start-worldserver.sh`:
```bash
#!/bin/bash
cd ~/acore-live/build
while true; do
    ./worldserver
    echo "Server stopped, restarting in 10 seconds..."
    sleep 10
done
```

Make executable: `chmod +x ~/start-worldserver.sh`

**Option B: systemd Service (recommended for production)**

Create `/etc/systemd/system/acore-worldserver.service`:
```ini
[Unit]
Description=AzerothCore World Server
After=network.target mysql.service

[Service]
Type=simple
User=oddessax
WorkingDirectory=/home/oddessax/acore-live/build
ExecStart=/home/oddessax/acore-live/build/worldserver
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable acore-worldserver
sudo systemctl start acore-worldserver
```

**Why this matters:**
- `ServerAutoShutdown.Enabled = 1` in config
- Server shuts down at exactly 4am daily
- Without auto-restart, server stays down until manual restart
- 1 hour warning announced in-game at 3am

### 5. Firewall & Network

- [ ] Open ports: 3724 (auth), 8085 (world)
- [ ] Configure router port forwarding if behind NAT
- [ ] Set up DDNS if using dynamic IP

### 6. SSL/TLS (Optional but Recommended)

- [ ] Configure SSL for HTTPS if using web tools
- [ ] Let's Encrypt free certificates

## Post-Deployment

### 7. Testing

- [ ] Start authserver
- [ ] Start worldserver (or via systemd)
- [ ] Check logs for errors: `tail -f ~/acore-live/build/var/log/worldserver.log`
- [ ] Verify all modules loaded in console output
- [ ] Connect with game client
- [ ] Create character, enter world
- [ ] Test basic gameplay (combat, quests, etc.)
- [ ] Test key modules:
  - [ ] AutoBalance (dungeon scaling)
  - [ ] Transmog (if enabled)
  - [ ] Playerbots (bot commands)
  - [ ] Breaking news shows on login screen

### 8. Monitoring Setup

- [ ] Set up log rotation (prevents disk fill)
- [ ] Configure backups (see below)
- [ ] Set up alerts for server crashes

### 9. Backup System

Create `~/backup-acore.sh`:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/var/backups/acore"
mkdir -p "$BACKUP_DIR"

mysqldump -u root acore_world | gzip > "$BACKUP_DIR/world-$DATE.sql.gz"
mysqldump -u root acore_characters | gzip > "$BACKUP_DIR/chars-$DATE.sql.gz"
mysqldump -u root acore_auth | gzip > "$BACKUP_DIR/auth-$DATE.sql.gz"

# Keep only last 30 days
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +30 -delete
```

Add to crontab: `0 2 * * * /home/oddessax/backup-acore.sh`

### 10. Documentation

- [ ] Document any custom changes made
- [ ] Save server IP/hostname
- [ ] Note any non-default config values
- [ ] Share connection info with players

## Regular Maintenance Tasks

| Task | Frequency | Command/Notes |
|------|-----------|---------------|
| Check for updates | Weekly | Run `~/update-acore.sh` |
| Database backup | Daily | Automatic via cron |
| Log cleanup | Weekly | `find . -name "*.log" -mtime +7 -delete` |
| Disk space check | Weekly | `df -h` |
| Test server restart | Monthly | Verify auto-restart works |

## Troubleshooting Common Issues

### Server Won't Start

- Check logs in `build/var/log/`
- Verify database connection settings
- Ensure ports aren't already in use: `netstat -tlnp | grep 3724`

### Modules Not Loading

- Check `git submodule update --init --recursive` was run
- Verify module configs are in `build/etc/`
- Check worldserver console for module load messages

### Database Errors

- Ensure all SQL updates were applied
- Check module SQL files in `modules/*/data/sql/`
- Verify DB user has proper permissions

### Auto-Restart Not Working

- Check systemd service status: `systemctl status acore-worldserver`
- Verify script permissions: `chmod +x start-worldserver.sh`
- Check for syntax errors in service file

## Links & Resources

- Your fork: https://github.com/oddessax/azerothcore-wotlk
- AzerothCore docs: https://www.azerothcore.org/wiki/
- Module list: See README.md in your repo

---

**Last updated:** When deploying a new server, work through this checklist top to bottom.
