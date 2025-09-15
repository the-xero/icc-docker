#!/usr/bin/env bash
set -e

# ==============================
# ICC Version Update Script
# ==============================

# -----------------------------
# Script directory and version file
# -----------------------------
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ICC_VERSION_FILE="$SCRIPT_DIR/icc_version"

# -----------------------------
# Load environment variables from .env
# -----------------------------
ENV_FILE="$SCRIPT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

# Set default branch if not specified
: "${GITHUB_BRANCH:=main}"

# -----------------------------
# Validate required configs
# -----------------------------
if [[ -z "$GITHUB_REPO" || -z "$GITHUB_TOKEN" ]]; then
    echo "❌ ERROR: GITHUB_REPO or GITHUB_TOKEN not set in .env"
    exit 1
fi

echo "✅ GitHub config loaded. Repo: $GITHUB_REPO, Branch: $GITHUB_BRANCH"

# -----------------------------
# Fetch latest ICC version
# -----------------------------
echo "🔄 Fetching latest ICC version from iptime server..."
LATEST_VER=$(curl -s --max-time 10 http://download.iptime.co.kr/icc/icc_image.version | head -n1)

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

# Write version to file and display
echo "🔄 Writing version '$LATEST_VER' to $ICC_VERSION_FILE..."
echo "$LATEST_VER" > "$ICC_VERSION_FILE"
echo "ℹ️ ICC Version file contents:"
cat "$ICC_VERSION_FILE"

# -----------------------------
# GitHub Commit & Push
# -----------------------------
echo "🔄 Configuring git..."
git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

# Remove existing repo folder if exists
if [[ -d "$SCRIPT_DIR/repo" ]]; then
    echo "ℹ️ Removing existing repo folder..."
    rm -rf "$SCRIPT_DIR/repo"
fi

echo "🔄 Cloning repository (depth=1)..."
git clone --depth 1 -b "$GITHUB_BRANCH" https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git "$SCRIPT_DIR/repo"
cd "$SCRIPT_DIR/repo"

echo "🔄 Updating icc_version in repository..."
cp ../icc_version ./icc_version

git add icc_version
if git commit -m "Update ICC version to $LATEST_VER"; then
    echo "✅ Commit created."
else
    echo "ℹ️ No changes to commit."
fi

echo "🔄 Pushing to GitHub branch $GITHUB_BRANCH..."
git push origin "$GITHUB_BRANCH"
echo "✅ icc_version updated and pushed to repository."

echo "=== ICC Version Update Completed ==="
