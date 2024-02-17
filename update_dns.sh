#!/bin/bash

# Cloudflare settings
API_TOKEN="<cloudflare_api_token>"         # Your API_TOKEN
ZONE_ID="<zone_id>"                        # Cloudflare Zone ID
RECORD_NAME="<record>.<yourdomain>.<tld>"  # The name of the DNS record you want to update
RECORD_TYPE="<record_type>"                # Use "A" for IPv4 or "AAAA" for IPv6 addresses

# Get the current external IP address
IP=$(curl -s http://ipv4.icanhazip.com)    # Use "http://ipv6.icanhazip.com" for IPv6 addresses

# Get the current date and time
CURRENT_DATETIME=$(date "+%d/%m/%Y %H:%M:%S")

# Log start with date and time
echo "[$CURRENT_DATETIME] Updating DNS for ${RECORD_NAME} to ${IP}"

# Get the record ID
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=${RECORD_TYPE}&name=${RECORD_NAME}" \
     -H "Authorization: Bearer ${API_TOKEN}" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

# Check if the Record ID was retrieved successfully
if [ -z "$RECORD_ID" ] || [ "$RECORD_ID" == "null" ]; then
  CURRENT_DATETIME=$(date "+%d/%m/%Y %H:%M:%S")
  echo "[$CURRENT_DATETIME] Failed to retrieve Record ID for ${RECORD_NAME}. Exiting."
  exit 1
fi

# Update the DNS record
UPDATE_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
     -H "Authorization: Bearer ${API_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"type":"'"${RECORD_TYPE}"'","name":"'"${RECORD_NAME}"'","content":"'"${IP}"'"}')

# Check for success
if echo "$UPDATE_RESPONSE" | jq -e '.success' >/dev/null; then
  CURRENT_DATETIME=$(date "+%d/%m/%Y %H:%M:%S")
  echo "[$CURRENT_DATETIME] DNS update successful."
else
  CURRENT_DATETIME=$(date "+%d/%m/%Y %H:%M:%S")
  echo "[$CURRENT_DATETIME] Failed to update DNS for ${RECORD_NAME}."
  exit 1
fi
