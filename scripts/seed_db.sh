#!/usr/bin/env bash
set -e

echo "=========================================="
echo " Seeding IT Helpdesk Demo Database"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."
python -m backend.db.seed
