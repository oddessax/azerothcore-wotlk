#!/bin/bash
# Setup script for oddessax/azerothcore-wotlk fork
# Run this on your server after cloning

set -e

REPO_URL="git@github.com:oddessax/azerothcore-wotlk.git"
UPSTREAM_URL="https://github.com/azerothcore/azerothcore-wotlk.git"
PLAYERBOT_UPSTREAM="https://github.com/mod-playerbots/azerothcore-wotlk.git"

echo "======================================"
echo "Setting up oddessax/azerothcore-wotlk"
echo "======================================"
echo ""

# Check if already cloned
if [ -d "acore" ]; then
    echo "Found existing acore/ folder. Updating setup..."
    cd acore
else
    echo "Cloning your fork..."
    git clone --branch Playerbot "$REPO_URL" acore
    cd acore
fi

echo ""
echo "Step 1: Configuring remotes..."

# Remove any existing upstream to avoid duplicates
git remote remove upstream 2>/dev/null || true

# Add AzerothCore upstream for core updates
git remote add upstream "$UPSTREAM_URL"

# Add mod-playerbots upstream (optional - to check their Playerbot branch updates)
git remote remove playerbot-upstream 2>/dev/null || true
git remote add playerbot-upstream "$PLAYERBOT_UPSTREAM"

echo "Remotes configured:"
git remote -v

echo ""
echo "Step 2: Fetching all remotes..."
git fetch origin
git fetch upstream
git fetch playerbot-upstream

echo ""
echo "Step 3: Creating stable and testing branches..."

# Create stable branch from origin/Playerbot if it doesn't exist
if ! git branch --list | grep -q "stable"; then
    git checkout -b stable origin/Playerbot
    echo "Created 'stable' branch"
else
    echo "'stable' branch already exists"
fi

# Create testing branch from origin/Playerbot if it doesn't exist
if ! git branch --list | grep -q "testing"; then
    git checkout -b testing origin/Playerbot
    echo "Created 'testing' branch"
else
    echo "'testing' branch already exists"
fi

echo ""
echo "Step 4: Pushing branches to your fork..."
git push -u origin stable || echo "stable already pushed"
git push -u origin testing || echo "testing already pushed"

echo ""
echo "Step 5: Creating worktrees..."
cd ..

if [ ! -d "acore-live" ]; then
    echo "Creating acore-live worktree (stable branch)..."
    git -C acore worktree add acore-live stable
else
    echo "acore-live already exists"
fi

if [ ! -d "acore-test" ]; then
    echo "Creating acore-test worktree (testing branch)..."
    git -C acore worktree add acore-test testing
else
    echo "acore-test already exists"
fi

echo ""
echo "======================================"
echo "Setup complete!"
echo "======================================"
echo ""
echo "Your folder structure:"
echo "  ~/acore/        - Main repo (run updates from here)"
echo "  ~/acore-live/   - Live server (stable branch)"
echo "  ~/acore-test/   - Test server (testing branch)"
echo ""
echo "Next steps:"
echo "1. Create the update script: ~/update-acore.sh"
echo "2. Set up your databases"
echo "3. Build acore-test first and verify it works"
echo "4. Promote to acore-live when ready"
echo ""
echo "To check your setup:"
echo "  cd acore && git branch -a && git remote -v"
echo ""
echo "To check for updates:"
echo "  cd acore && git fetch upstream && git log HEAD..upstream/master --oneline"
