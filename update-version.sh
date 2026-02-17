#!/usr/bin/env bash
set -euo pipefail

PLUGIN_JSON="$(cd "$(dirname "$0")" && pwd)/.claude-plugin/plugin.json"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  echo "Error: $PLUGIN_JSON not found" >&2
  exit 1
fi

current=$(jq -r '.version' "$PLUGIN_JSON")
if [[ -z "$current" || "$current" == "null" ]]; then
  echo "Error: no version field in $PLUGIN_JSON" >&2
  exit 1
fi

IFS='.' read -r major minor patch <<< "$current"

part="${1:-patch}"
case "$part" in
  patch) patch=$((patch + 1)) ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  major) major=$((major + 1)); minor=0; patch=0 ;;
  *)
    echo "Usage: $0 [patch|minor|major]" >&2
    echo "  Default: patch" >&2
    exit 1
    ;;
esac

new_version="$major.$minor.$patch"

jq --arg v "$new_version" '.version = $v' "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp" \
  && mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"

echo "$current -> $new_version"
