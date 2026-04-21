# Server Update Workflow

Simple step-by-step guide for updating your AzerothCore server.

## Regular Update Check (Weekly/Monthly)

### 1. Check for Updates

```bash
cd ~/acore
git fetch origin

# See if testing is ahead of stable
git log stable..testing --oneline
```

### 2. Update Test Server

```bash
cd ~/acore-test
git pull origin testing
git submodule update --init --recursive

# Build
cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

# Run tests
```

### 3. Test Everything

- Start worldserver + authserver
- Log in, check modules work
- Test any new features
- Check for errors in logs

### 4. Promote to Live (Only If Tests Pass!)

```bash
cd ~/acore

# Create backup tag first
git checkout stable
git tag -a backup-$(date +%Y-%m-%d) -m "Working version before update"
git push origin backup-$(date +%Y-%m-%d)

# Merge testing into stable
git merge testing --no-edit
git push origin stable

# Update live folder
cd ~/acore-live
git pull origin stable
git submodule update --init --recursive

# Build live
cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

# Restart live server
```

## Emergency Rollback

If live breaks after update:

```bash
cd ~/acore-live

# Find backup tag
git tag | grep backup

# Rollback
git checkout stable
git reset --hard backup-YYYY-MM-DD

# Rebuild and restart
```

## Adding a New Module

```bash
cd ~/acore
git checkout testing

# Add module
git submodule add https://github.com/USER/mod-name.git modules/mod-name
git submodule update --init --recursive

# Commit and push
git add .gitmodules modules/mod-name
git commit -m "Add mod-name"
git push origin testing

# Test in acore-test before promoting to live
```

## Customizing a Module (Forking)

When you need to make changes to a module:

```bash
# 1. Fork the module on GitHub web interface

# 2. In your local submodule, change remote
cd ~/acore/modules/mod-name
git remote set-url origin git@github.com:oddessax/mod-name.git

# 3. Add original as upstream
git remote add upstream https://github.com/ORIGINAL/mod-name.git

# 4. Make changes, commit, push to your fork
# 5. Update main repo to track your fork's new commit
cd ~/acore
git add modules/mod-name
git commit -m "Switch mod-name to my fork with custom changes"
git push origin testing
```

## Database Backups (Before Every Live Deploy)

```bash
mkdir -p ~/acore-backups
DATE=$(date +%Y%m%d)

mysqldump -u root acore_world > ~/acore-backups/world-${DATE}.sql
mysqldump -u root acore_characters > ~/acore-backups/chars-${DATE}.sql
mysqldump -u root acore_auth > ~/acore-backups/auth-${DATE}.sql
```

## Quick Reference

| Task | Command |
|------|---------|
| Check branch | `git branch` |
| Switch to testing | `git checkout testing` |
| Switch to stable | `git checkout stable` |
| See commit history | `git log --oneline -10` |
| Check for updates | `git fetch && git log HEAD..origin/testing --oneline` |
| Update all submodules | `git submodule update --init --recursive` |
| See all modules | `ls modules/` |
| Check worktrees | `git worktree list` |

## What Each Folder Is

| Folder | Branch | Purpose |
|--------|--------|---------|
| `~/acore/` | N/A (bare) | Main repo, run updates from here |
| `~/acore-live/` | `stable` | Your live server for players |
| `~/acore-test/` | `testing` | Test server, try updates here first |

## When Things Go Wrong

1. **Build fails**: Clean build folder, re-run cmake && make
2. **Merge conflict**: Script shows conflicted files, ask AI for help
3. **Module won't load**: Check submodule is initialized, rebuild
4. **Database issues**: Restore from backup, make sure DB matches code version
5. **Can't push**: Check SSH key, make sure you have permissions

Remember: **Always test in acore-test before touching acore-live!**
