# AzerothCore + Playerbots Private Server

Personal fork of [mod-playerbots/azerothcore-wotlk](https://github.com/mod-playerbots/azerothcore-wotlk) with custom modules for a 5-player private server.

## Branches

| Branch | Purpose | Modules |
|--------|---------|---------|
| `stable` | Live server | Playerbots only (clean) |
| `testing` | Development/testing | Playerbots + 33 custom modules |
| `Playerbot` | Upstream tracking | Original from mod-playerbots (don't modify) |

## Quick Start

### Clone and Setup (First Time)

```bash
# Clone your fork
git clone git@github.com:oddessax/azerothcore-wotlk.git acore
cd acore

# Create worktrees for live and test servers
git worktree add ../acore-live stable
git worktree add ../acore-test testing
```

### Directory Structure

```
~/
├── acore/           # Main repo (run updates from here)
├── acore-live/      # Live server (stable branch)
├── acore-test/      # Test server (testing branch)
└── acore-backups/   # Database backups
```

## Updating

### Check for Updates

```bash
cd ~/acore
git fetch origin

# See what's new on testing vs stable
git log stable..testing --oneline
```

### Update Testing Server

```bash
cd ~/acore-test
git pull origin testing
git submodule update --init --recursive

# Build
cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### Promote to Live (When Testing Works)

```bash
cd ~/acore

# Backup current stable
git checkout stable
git tag -a backup-$(date +%Y-%m-%d) -m "Before promoting testing"
git push origin backup-$(date +%Y-%m-%d)

# Merge testing into stable
git merge testing --no-edit
git push origin stable

# Update live folder
cd ~/acore-live
git pull origin stable
git submodule update --init --recursive

# Rebuild
```

## Modules

### Installed Modules (testing branch)

| Module | Author | Purpose |
|--------|--------|---------|
| mod-individual-progression | ZhengPeiRu21 | Character progression system |
| mod-transmog | azerothcore | Transmogrification |
| mod-autobalance | azerothcore | Auto-balance dungeon difficulty |
| mod-ah-bot-plus | NathanHandley | Auction house bot |
| mod-aoe-loot | azerothcore | AoE looting |
| mod-better-item-reloading | azerothcore | Better item reloading |
| mod-player-bot-level-brackets | DustinHendrickson | Bot level brackets |
| mod-custom-login | azerothcore | Custom login screen |
| DungeonRespawn | AnchyDev | Dungeon respawn system |
| mod-ale | azerothcore | Ale/alcohol system |
| mod-npc-gambler | azerothcore | Gambling NPC |
| mod-starter-guild | azerothcore | Auto guild for new players |
| mod-TimeIsTime | dunjeon | Time scaling |
| mod-junk-to-gold | noisiver | Sell junk to gold |
| mod-breaking-news-override | azerothcore | Custom breaking news |
| mod-server-auto-shutdown | azerothcore | Auto shutdown |
| mod-rdf-expansion | azerothcore | RDF expansion |
| mod-reforging | silviu20092 | Item reforging |
| mod-learnspells | noisiver | Auto learn spells |
| mod-no-hearthstone-cooldown | BytesGalore | No HS cooldown |
| mod-flightmaster-whistle | silviu20092 | Flightmaster whistle |
| mod-autofish | Flerp | Auto fishing |
| mod-missing-objectives | forumcorex | Missing objectives |
| mod-tcg-vendors | lightninjay | TCG vendors |
| mod-reset-raid-cooldowns | sogladev | Reset raid cooldowns |
| mod-shared-professions | thanhtong89 | Shared professions |
| mod-auto-gather | thanhtong89 | Auto gathering |
| mod-auto-resurrect | Elmegaard | Auto resurrect |
| mod-gm-commands | chromiecraft | GM commands |
| mod-abyssal-storage | thanhtong89 | Abyssal storage |
| mod-increment-cache-version | sogladev | Cache version increment |
| mod-easy-respawn | silviu20092 | Easy respawn |
| mod-starter-wands | Protonull | Starter wands |

### Adding New Modules

```bash
cd ~/acore
git checkout testing
git submodule add https://github.com/USER/mod-name.git modules/mod-name
git submodule update --init --recursive
git commit -m "Add mod-name"
git push origin testing
```

### Updating a Module

```bash
cd ~/acore/modules/mod-name
git fetch origin
git pull
cd ../..
git add modules/mod-name
git commit -m "Update mod-name"
git push origin testing
```

### Forking a Module (For Custom Changes)

If you need to modify a module:

1. Fork the module on GitHub
2. Change the submodule URL:
```bash
cd ~/acore/modules/mod-name
git remote set-url origin git@github.com:oddessax/mod-name.git
git remote add upstream https://github.com/ORIGINALAUTHOR/mod-name.git
```
3. Push changes to your fork
4. Update main repo: `git add modules/mod-name && git commit && git push`

## Troubleshooting

### Build Fails After Update

```bash
cd ~/acore-test/build
rm -rf *  # Clean build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### Rollback Live Server

```bash
cd ~/acore-live

# See backup tags
git tag | grep backup

# Rollback to specific date
git checkout stable
git reset --hard backup-YYYY-MM-DD

# Rebuild
```

### Submodule Issues

```bash
# Reinitialize all submodules
git submodule update --init --recursive --force

# If a module is stuck
cd modules/mod-name
git reset --hard HEAD
cd ../..
git submodule update
```

## Links

- **Your Fork**: https://github.com/oddessax/azerothcore-wotlk
- **Upstream (Playerbots)**: https://github.com/mod-playerbots/azerothcore-wotlk
- **Original AzerothCore**: https://github.com/azerothcore/azerothcore-wotlk

## Notes

- Always test in `acore-test` before promoting to `acore-live`
- Database backups before live deploys are essential
- When something breaks, copy the error and ask AI: "My AzerothCore Playerbot server has this error: [paste error]"
