#!/usr/bin/env bash
set -e

# -----------------------------
# Configuration
# -----------------------------
CONFIG_FILE="config.yaml"

# 기본값
GITHUB_BRANCH="main"

# -----------------------------
# Load config
# -----------------------------
if [[ -f "$CONFIG_FILE" ]]; then
    GITHUB_REPO=$(grep 'repo:' "$CONFIG_FILE" | awk '{print $2}')
    GITHUB_TOKEN=$(grep 'token:' "$CONFIG_FILE" | awk '{print $2}')
    BRANCH=$(grep 'branch:' "$CONFIG_FILE" | awk '{print $2}')
    [[ -n "$BRANCH" ]] && GITHUB_BRANCH="$BRANCH"
fi

# -----------------------------
# Validate
# -----------------------------
if [[ -z "$GITHUB_REPO" || -z "$GITHUB_TOKEN" ]]; then
    echo "❌ ERROR: GITHUB_REPO or GITHUB_TOKEN not set in config file."
    exit 1
fi

echo "✅ GitHub config loaded. Repo: $GITHUB_REPO, Branch: $GITHUB_BRANCH"

# -----------------------------
# ICC Version File
# -----------------------------
ICC_VERSION_FILE="/path/to/icc_version"

echo "🔄 Fetching latest ICC version from iptime server..."
LATEST_VER=$(curl -s -A "Mozilla/5.0" --max-time 10 http://download.iptime.co.kr/icc/icc_image.version | head -n1)

if [[ -z "$LATEST_VER" ]]; then
    echo "❌ Failed to fetch ICC version from server."
    if [[ -f "$ICC_VERSION_FILE" ]]; then
        LATEST_VER=$(head -n1 "$ICC_VERSION_FILE")
        echo "ℹ️ Using existing icc_version file: $LATEST_VER"
    else
        LATEST_VER="0_918"
        echo "ℹ️ No icc_version file found. Using default: $LATEST_VER"
    fi
else
    echo "✅ Latest ICC version from server: $LATEST_VER"
fi

echo "$LATEST_VER" > "$ICC_VERSION_FILE"
echo "✅ icc_version file updated locally."

# -----------------------------
# GitHub Commit & Push
# -----------------------------
echo "🔄 Configuring git..."
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

echo "🔄 Cloning repository..."
git clone https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git repo
cd repo

echo "🔄 Updating icc_version in repository..."
cp ../$ICC_VERSION_FILE ./

git add $ICC_VERSION_FILE
if git commit -m "Update ICC version to $LATEST_VER"; then
    echo "✅ Commit created."
else
    echo "ℹ️ No changes to commit."
fi

echo "🔄 Pushing to GitHub branch $GITHUB_BRANCH..."
git push origin $GITHUB_BRANCH
echo "✅ icc_version updated and pushed."

echo "=== ICC Version Update Completed ==="
