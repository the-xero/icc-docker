#!/usr/bin/env bash
set -e

echo "=== Starting ICC Version Update ==="

# 필수 환경 변수 확인
if [[ -z "$GITHUB_REPO" || -z "$GITHUB_TOKEN" ]]; then
    echo "❌ ERROR: GITHUB_REPO or GITHUB_TOKEN environment variable not set."
    echo "❌ Please set GITHUB_REPO and GITHUB_TOKEN to run this script."
    exit 1
fi
echo "✅ Required environment variables are set."

# 선택 환경 변수
: "${GITHUB_BRANCH:=main}"   # 기본값 main
echo "ℹ️ Using branch: $GITHUB_BRANCH"

# 파일 경로
ICC_VERSION_FILE="icc_version"

echo "🔄 Fetching latest ICC version from iptime server..."
LATEST_VER=$(curl -s -A "Mozilla/5.0" --max-time 10 http://download.iptime.co.kr/icc/icc_image.version | head -n1)

# curl 실패 시 기존 파일 사용
if [[ -z "$LATEST_VER" ]]; then
    echo "❌ Failed to fetch ICC version from server."
    if [ -f "$ICC_VERSION_FILE" ]; then
        LATEST_VER=$(head -n1 "$ICC_VERSION_FILE")
        echo "ℹ️ Using existing icc_version file: $LATEST_VER"
    else
        LATEST_VER="0_918"
        echo "ℹ️ No icc_version file found. Using default: $LATEST_VER"
    fi
else
    echo "✅ Latest ICC version from server: $LATEST_VER"
fi

# icc_version 파일 생성/갱신
echo "🔄 Writing version to $ICC_VERSION_FILE..."
echo "$LATEST_VER" > "$ICC_VERSION_FILE"
echo "✅ icc_version file updated locally."

# GitHub에 커밋 및 푸시
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
echo "✅ icc_version updated and pushed to repository."

echo "=== ICC Version Update Completed ==="
