#!/bin/sh
# xc-ops-bridge pre-commit hook
# Block commits to forbidden files

RESTRICTED_PATHS="\.local/|DerivedData/|xcuserdata/|\.xcresult"

if git diff --cached --name-only | grep -E "$RESTRICTED_PATHS" > /dev/null; then
    echo "=========================================================="
    echo "🚨 ERROR: Commit blocked by xc-ops-bridge pre-commit hook."
    echo "You are trying to commit a forbidden file/directory."
    echo ""
    echo "The following files matched the restricted pattern ($RESTRICTED_PATHS):"
    git diff --cached --name-only | grep -E "$RESTRICTED_PATHS" | sed 's/^/  - /'
    echo ""
    echo "Please unstage these files before committing:"
    echo "  git reset HEAD <file>"
    echo "=========================================================="
    exit 1
fi

exit 0
