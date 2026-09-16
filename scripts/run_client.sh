#!/usr/bin/env bash
set -e

echo "=========================================="
echo " Launching Flutter Client (Web / Chrome)"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../client"
flutter run -d chrome
