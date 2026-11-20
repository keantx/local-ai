#!/bin/sh
set -eu

BASE="http://litellm:4000"
AUTH="Authorization: Bearer $LITELLM_MASTER_KEY"
JSON="Content-Type: application/json"

until curl -sf "$BASE/health/liveliness" >/dev/null; do
  echo "waiting for litellm..."; sleep 3
done

code=$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" \
  "$BASE/user/info?user_id=$ADMIN_USER_ID")
if [ "$code" = "200" ]; then
  echo "admin already exists, skipping"; exit 0
fi

echo "creating user..."
curl -sf -X POST "$BASE/user/new" -H "$AUTH" -H "$JSON" \
  -d '{"user_id":"'"$ADMIN_USER_ID"'","user_email":"'"$ADMIN_EMAIL"'","user_role":"proxy_admin","auto_create_key":false}' >/dev/null

echo "ensuring master-key identity exists..."
curl -s -X POST "$BASE/user/new" -H "$AUTH" -H "$JSON" \
  -d '{"user_id":"default_user_id","user_role":"internal_user","auto_create_key":false}' >/dev/null

echo "creating invitation..."
inv=$(curl -sf -X POST "$BASE/invitation/new" -H "$AUTH" -H "$JSON" \
  -d '{"user_id":"'"$ADMIN_USER_ID"'"}')
inv_id=$(echo "$inv" | sed -n 's/.*"id": *"\([^"]*\)".*/\1/p')
[ -n "$inv_id" ] || { echo "no invitation id in: $inv"; exit 1; }

echo "fetching onboarding token..."
tok_resp=$(curl -sf "$BASE/onboarding/get_token?invite_link=$inv_id")
outer=$(echo "$tok_resp" | sed -n 's/.*"token": *"\([^"]*\)".*/\1/p')
[ -n "$outer" ] || { echo "no token in response"; exit 1; }

# The onboarding JWT is the "key" claim inside the outer token's payload
p=$(echo "$outer" | cut -d. -f2 | tr '_-' '/+')
while [ $(( ${#p} % 4 )) -ne 0 ]; do p="${p}="; done
tok=$(echo "$p" | base64 -d 2>/dev/null | sed -n 's/.*"key": *"\([^"]*\)".*/\1/p')
[ -n "$tok" ] || { echo "no onboarding key inside token"; exit 1; }

echo "setting password..."
resp=$(curl -s -w '\n%{http_code}' -X POST "$BASE/onboarding/claim_token" \
  -H "Authorization: Bearer $tok" -H "$JSON" \
  -d '{"invitation_link":"'"$inv_id"'","user_id":"'"$ADMIN_USER_ID"'","password":"'"$ADMIN_PASSWORD"'"}')
code=$(echo "$resp" | tail -n1)
body=$(echo "$resp" | sed '$d')
[ "$code" = "200" ] || { echo "claim_token failed ($code): $body"; exit 1; }
echo "admin ready"

code=$(curl -s -o /dev/null -w '%{http_code}' -H "$AUTH" \
  "$BASE/key/info?key=$OPENWEBUI_LITELLM_KEY")
if [ "$code" = "200" ]; then
  echo "openwebui key already registered, skipping"
else
  echo "registering openwebui key..."
  resp=$(curl -s -w '\n%{http_code}' -X POST "$BASE/key/generate" -H "$AUTH" -H "$JSON" \
    -d '{"key":"'"$OPENWEBUI_LITELLM_KEY"'","key_alias":"openwebui","models":["qwen3.5:9b"],"user_id":"'"$ADMIN_USER_ID"'"}')
  code=$(echo "$resp" | tail -n1)
  body=$(echo "$resp" | sed '$d')
  [ "$code" = "200" ] || { echo "key/generate failed ($code): $body"; exit 1; }
  echo "openwebui key ready"
fi
