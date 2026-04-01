#!/usr/bin/env bash
#
# Quick new post creator
# Usage: ./new-post.sh "My Post Title"
#        ./new-post.sh "My Post Title" --draft
#

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 \"Post Title\" [--draft]"
    echo ""
    echo "Examples:"
    echo "  $0 \"Why I Love Terraform\""
    echo "  $0 \"Quick Thought on AI\" --draft"
    exit 1
fi

TITLE="$1"
DRAFT="false"

if [[ "${2:-}" == "--draft" ]]; then
    DRAFT="true"
fi

# Convert title to slug
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
POST_DIR="content/posts/${SLUG}"
POST_FILE="${POST_DIR}/index.md"

if [ -d "$POST_DIR" ]; then
    echo "Error: Post directory already exists: ${POST_DIR}"
    exit 1
fi

mkdir -p "$POST_DIR"

cat > "$POST_FILE" << EOF
---
title: "${TITLE}"
date: ${DATE}
draft: ${DRAFT}
description: ""
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
tags: []
categories: []
---

EOF

echo "Created: ${POST_FILE}"
echo ""
echo "Next steps:"
echo "  1. Write your post in ${POST_FILE}"
if [ "$DRAFT" == "true" ]; then
    echo "  2. Set draft: false when ready to publish"
fi
echo "  3. git add, commit, push — done!"
