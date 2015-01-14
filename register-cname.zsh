#!/usr/bin/env zsh

# Find your DNSimple token at https://dnsimple.com/user.
# Run this script as:
#
# DNSIMPLE_EMAIL=me@example.com DNSIMPLE_TOKEN=abc123 DOMAIN=you.com ./register-cname.zsh

dnsimple_curl(){
  curl -s -H "X-DNSimple-Token: $DNSIMPLE_EMAIL:$DNSIMPLE_TOKEN" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    "$@" | jq .
}


get_all_records(){
  dnsimple_curl -X GET "https://api.dnsimple.com/v1/domains/$DOMAIN/records"
}

register_cname(){
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

# hello.yourdomain.com -> tumblr.com
register_cname "hello" "tumblr.com"
