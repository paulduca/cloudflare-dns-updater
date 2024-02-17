#!/bin/bash

# Cloudflare settings
API_TOKEN="<cloudflare_api_token>"         # Your API_TOKEN
ZONE_ID="<zone_id>"                        # Cloudflare Zone ID
RECORD_TYPE="<record_type>"                # Use "A" for IPv4 or "AAAA" for IPv6 addresses

# List of DNS records you want to update
declare -a RECORD_NAMES=("record1.yourdomain.tld" "record2.yourdomain.tld")

# Get the current external IP address
IP=$(curl -s http://ipv4.icanhazip.com)    # Use "http://ipv6.icanhazip.com" for IPv6 addresses

# Get the current date and time
CURRENT_DATETIME=$(date "+%d/%m/%Y %H:%M:%S")

# Log start with date and time
echo "[$CURRENT_DATETIME] Starting DNS update process."

# Loop through all DNS records
for RECORD_NAME in "${RECORD_NAMES[@]}"; do
  echo "[$CURRENT_DATETIME] Processing ${RECORD_NAME}."

  # Get the record details
  RECORD_DETAILS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=${RECORD_TYPE}&name=${RECORD_NAME}" \
       -H "Authorization: Bearer ${API_TOKEN}" \
       -H "Content-Type: application/json")

  # Extract the Record ID and current IP from the details
  RECORD_ID=$(echo "$RECORD_DETAILS" | jq -r '.result[0].id')
  DNS_IP=$(echo "$RECORD_DETAILS" | jq -r '.result[0].content')

  # Check if the Record ID was retrieved successfully
  if [ -z "$RECORD_ID" ] || [ "$RECORD_ID" == "null" ]; then
    echo "[$CURRENT_DATETIME] Failed to retrieve Record ID for ${RECORD_NAME}. Continuing to next record."
    continue  # Skip to the next record
  fi

  # Compare the current external IP with the DNS record's IP
  if [ "$IP" != "$DNS_IP" ]; then
    echo "[$CURRENT_DATETIME] Current IP ($IP) is different from DNS IP ($DNS_IP) for ${RECORD_NAME}. Updating record."

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
  else
    echo "[$CURRENT_DATETIME] Current IP ($IP) is the same as DNS IP ($DNS_IP) for ${RECORD_NAME}. No update required."
  fi
done

echo "[$CURRENT_DATETIME] DNS update process completed."
