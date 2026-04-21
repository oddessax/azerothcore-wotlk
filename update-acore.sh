#!/bin/bash
# AzerothCore + Playerbots Update Script
# For: oddessax/azerothcore-wotlk fork

# Colors for obvious errors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==================================="
echo "AzerothCore + Playerbots Update"
echo "For: oddessax/azerothcore-wotlk"
echo "==================================="
echo ""
echo "This will:"
echo "1. Check for AzerothCore upstream updates"
echo "2. Check for mod-playerbots Playerbot branch updates"
echo "3. Warn about potential merge conflicts"
echo "4. Update your testing branch"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

cd ~/acore

echo ""
echo "Step 1: Fetching remotes..."
git fetch origin
git fetch upstream
git fetch playerbot-upstream

echo ""
echo "Step 2: Checking for updates..."

# Check AzerothCore upstream
CORE_LOCAL=$(git rev-parse testing)
CORE_REMOTE=$(git rev-parse upstream/master 2>/dev/null || echo "N/A")

# Check mod-playerbots Playerbot branch
PB_LOCAL=$(git rev-parse testing)
PB_REMOTE=$(git rev-parse playerbot-upstream/Playerbot 2>/dev/null || echo "N/A")

echo "Current testing branch: ${CORE_LOCAL:0:7}"
echo "AzerothCore upstream:  ${CORE_REMOTE:0:7}"
echo "mod-playerbots Playerbot: ${PB_REMOTE:0:7}"
echo ""

# Check if we're behind mod-playerbots Playerbot branch
if [ "$PB_REMOTE" != "N/A" ] && [ "$PB_LOCAL" != "$PB_REMOTE" ]; then
    echo -e "${YELLOW}⚠ Your fork is behind mod-playerbots Playerbot branch${NC}"
    echo "The mod-playerbots team may have updated the Playerbot branch."
    echo ""
    read -p "Fast-forward to latest Playerbot branch first? (recommended) (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout testing
        git merge playerbot-upstream/Playerbot --ff-only || {
            echo -e "${RED}ERROR: Cannot fast-forward. Playerbot branch has diverged.${NC}"
            echo "This means mod-playerbots made changes that conflict with yours."
            echo "Options:"
            echo "1. Reset your testing branch to theirs (loses your changes in testing):"
            echo "   git reset --hard playerbot-upstream/Playerbot"
            echo "2. Ask AI for help with the merge"
            exit 1
        }
        echo -e "${GREEN}✓ Updated to latest Playerbot branch${NC}"
    fi
fi

# Check if AzerothCore upstream has new commits
if [ "$CORE_REMOTE" != "N/A" ] && [ "$CORE_LOCAL" != "$CORE_REMOTE" ]; then
    echo ""
    echo "AzerothCore upstream has new commits."
    echo "Commits to review:"
    git log --oneline HEAD..upstream/master | head -10
    COMMIT_COUNT=$(git log --oneline HEAD..upstream/master | wc -l)
    echo ""
    echo "Total commits behind: $COMMIT_COUNT"
    echo ""
    read -p "Merge AzerothCore upstream into testing? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout testing
        git merge upstream/master --no-edit || {
            echo -e "${RED}ERROR: Merge conflict detected!${NC}"
            echo ""
            echo "=== CONFLICTED FILES ==="
            git diff --name-only --diff-filter=U
            echo "======================="
            echo ""
            echo "This is a conflict between Playerbot code and new AzerothCore code."
            echo ""
            echo "Options:"
            echo "1. Fix manually (edit the files, remove <<<<<<< ======= >>>>>>> lines)"
            echo "2. Abort and wait for mod-playerbots to update their branch:"
            echo "   git merge --abort"
            echo "3. Ask AI: Copy the conflicted files above and ask for help"
            echo ""
            echo "Current state: Merge is in progress but has conflicts."
            echo "You must either resolve or abort before continuing."
            exit 1
        }
        echo -e "${GREEN}✓ AzerothCore upstream merged successfully${NC}"
    fi
else
    echo -e "${GREEN}✓ Already up to date with AzerothCore upstream${NC}"
fi

echo ""
echo "Step 3: Pushing to your fork..."
git push origin testing || {
    echo -e "${RED}ERROR: Push failed!${NC}"
    echo "You may have changes on GitHub that aren't in your local repo."
    echo "Try: git pull origin testing --rebase"
    exit 1
}

echo ""
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}Update complete!${NC}"
echo ""
echo "Next steps:"
echo "1. cd ~/acore-test && git pull origin testing"
echo "2. Build and test the server"
echo "   cd ~/acore-test/build"
echo "   cmake ../ -DCMAKE_BUILD_TYPE=Release"
echo "   make -j$(nproc)"
echo "3. If it works, promote to live:"
echo "   cd ~/acore && git checkout stable && git merge testing --no-edit"
echo "   git push origin stable"
echo "   cd ~/acore-live && git pull origin stable"
echo "==================================="
