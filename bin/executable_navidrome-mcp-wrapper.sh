#!/bin/bash
PASS=/opt/homebrew/bin/pass-cli
export NAVIDROME_URL=$($PASS item view --vault-name "Personal" --item-title "Navidrome login" --field urls | cut -d',' -f1 | tr -d ' ' | sed 's|/$||')
export NAVIDROME_USERNAME=$($PASS item view --vault-name "Personal" --item-title "Navidrome login" --field username)
export NAVIDROME_PASSWORD=$($PASS item view --vault-name "Personal" --item-title "Navidrome login" --field password)
exec /Users/devdogfish/.bun/bin/navidrome-mcp
