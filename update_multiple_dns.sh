#!/bin/bash

# Cloudflare settings
API_TOKEN="<cloudflare_api_token>"         # Your API_TOKEN
ZONE_ID="<zone_id>"                        # Cloudflare Zone ID
RECORD_TYPE="<record_type>"                # Use "A" for IPv4 or "AAAA" for IPv6 addresses

# List of DNS records you want to update
declare -a RECORD_NAMES=("dns.yourdomain.tld" "dns2.yourdomain.tld")

# Get the current external IP address
IP=$(curl -s http://ipv4.icanhazip.com)    # Use "http://ipv6.icanhazip.com" for IPv6 addresses

# Get the current date and time
CURRENT_DATETIME=$(date "+%d/%m/%Y %H:%M:%S")

# Log start with date and time
echo "[$CURRENT_DATETIME] Starting DNS update process."

# Loop through all DNS records
for RECORD_NAME in "${RECORD_NAMES[@]}"; do
  echo "[$CURRENT_DATETIME] Updating DNS for ${RECORD_NAME} to ${IP}"

  # Get the record ID
  RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=${RECORD_TYPE}&name=${RECORD_NAME}" \
       -H "Authorization: Bearer ${API_TOKEN}" \
       -H "Content-Type: application/json" | jq -r '.result[0].id')

  # Check if the Record ID was retrieved successfully
  if [ -z "$RECORD_ID" ] || [ "$RECORD_ID" == "null" ]; then
    echo "[$CURRENT_DATETIME] Failed to retrieve Record ID for ${RECORD_NAME}. Continuing to next record."
    continue  # Skip to the next record
  fi

  # Update the DNS record
  UPDATE_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
       -H "Authorization: Bearer ${API_TOKEN}" \
       -H "Content-Type: application/json" \
       --data '{"type":"'"${RECORD_TYPE}"'","name":"'"${RECORD_NAME}"'","content":"'"${IP}"'"}')

  # Check for success
  if echo "$UPDATE_RESPONSE" | jq -e '.success' >/dev/null; then
    echo "[$CURRENT_DATETIME] DNS update successful for ${RECORD_NAME}."
  else
    echo "[$CURRENT_DATETIME] Failed to update DNS for ${RECORD_NAME}."
  fi
done
