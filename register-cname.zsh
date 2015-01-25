#!/usr/bin/env zsh

# Find your DNSimple token at https://dnsimple.com/user.
# Run this script as:
#
# DNSIMPLE_TOKEN=abc123 DOMAIN=you.com ./register-cname.zsh

if [[ -z "$DNSIMPLE_TOKEN" ]]; then
  echo "Set \$DNSIMPLE_TOKEN to your DNSimple domain token."
  exit 64
fi

if [[ -z "$DOMAIN" ]]; then
  echo "Set \$DOMAIN to the name of your DNSimple domain."
  exit 64
fi

dnsimple_curl(){
  curl -s -H "X-DNSimple-Domain-Token: $DNSIMPLE_TOKEN" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    "$@" | jq .
}


get_all_records(){
  dnsimple_curl -X GET "https://api.dnsimple.com/v1/domains/$DOMAIN/records"
}

register_cname(){
  if (( $# < 2 )); then
    echo "register_cname needs a subdomain and a URL to map to"
    exit 64
  fi

  subdomain="$1"
  url="$2"

  read -r -d '' json <<EOJSON
  {
    "record": {
      "name": "$subdomain",
      "record_type": "CNAME",
      "content": "$url",
      "ttl": 3600
    }
  }
EOJSON

  dnsimple_curl -X POST "https://api.dnsimple.com/v1/domains/$DOMAIN/records" \
    -d "$json"
}

# get_all_records

# hello.yourdomain.com -> tumblr.com
# register_cname "hello" "tumblr.com"
