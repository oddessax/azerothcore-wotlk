#!/bin/bash
# Promote testing branch to live (stable) branch
# For: oddessax/azerothcore-wotlk fork

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==================================="
echo "Promote Testing → Live"
echo "==================================="
echo ""
echo "This will:"
echo "1. Create a backup tag of current stable (for rollback)"
echo "2. Merge testing into stable"
echo "3. Push to your fork"
echo "4. Update acore-live folder"
echo ""
echo -e "${YELLOW}WARNING: Make sure you've tested in acore-test first!${NC}"
echo ""
read -p "Are you sure you want to promote to live? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

cd ~/acore

BACKUP_DATE=$(date +%Y-%m-%d-%H%M)

echo ""
echo "Step 1: Creating backup tag..."
git checkout stable
git tag -a "backup-${BACKUP_DATE}" -m "Auto-backup before promoting testing to live"
git push origin "backup-${BACKUP_DATE}"
echo -e "${GREEN}✓ Created backup tag: backup-${BACKUP_DATE}${NC}"

echo ""
echo "Step 2: Merging testing into stable..."
git merge testing --no-edit || {
    echo -e "${RED}ERROR: Merge conflict between testing and stable!${NC}"
    echo "This shouldn't happen if you only edit in testing."
    echo "To abort: git merge --abort"
    exit 1
}

echo ""
echo "Step 3: Pushing to fork..."
git push origin stable

echo ""
echo "Step 4: Updating acore-live folder..."
cd ~/acore-live
git pull origin stable

echo ""
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}Promoted to live successfully!${NC}"
echo ""
echo "Backup tag created: backup-${BACKUP_DATE}"
echo ""
echo "If live breaks, rollback with:"
echo "  cd ~/acore-live"
echo "  git checkout stable"
echo "  git reset --hard backup-${BACKUP_DATE}"
echo "  # Then rebuild"
echo "==================================="
