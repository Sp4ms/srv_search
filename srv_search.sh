#!/usr/bin/env bash

DOMAIN="${1:-}"
SRV_FILE="${2:-srvs.txt}"

if [[ -z "$DOMAIN" ]]; then
    echo "Usage: $0 <domain> [srv-file]" >&2
    exit 1
fi

while IFS= read -r srv || [[ -n "$srv" ]]; do
    # Remove Windows CR and skip blanks/comments
    srv="${srv//$'\r'/}"
    [[ -z "$srv" || "$srv" =~ ^[[:space:]]*# ]] && continue

    fqdn="${srv}.${DOMAIN}"
    result="$(dig +short +time=2 +tries=1 SRV "$fqdn")"

    if [[ -n "$result" ]]; then
        while IFS= read -r record; do
            printf '%s | %s\n' "$fqdn" "$record"
        done <<< "$result"
    fi
done < "$SRV_FILE"
