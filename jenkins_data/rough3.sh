#!/bin/bash

# Prompt user to enter API key and secret
read -p "Enter your GoDaddy API key: " api_key
read -p "Enter your GoDaddy API secret: " api_secret

# Prompt user to enter domain and DNS record details
read -p "Enter the domain name where you want to create the DNS record: " domain
read -p "Enter the DNS record type (e.g., A, CNAME, MX): " dns_type
read -p "Enter the name for the DNS record (e.g., subdomain): " dns_name
read -p "Enter the data/IP address for the DNS record: " dns_data
read -p "Enter the TTL (Time to Live) for the DNS record (in seconds): " dns_ttl

# Function to create DNS record
create_dns_record() {
    local api_key="$1"
    local api_secret="$2"
    local domain="$3"
    local dns_type="$4"
    local dns_name="$5"
    local dns_data="$6"
    local dns_ttl="$7"

    local url="https://api.ote-godaddy.com/v1/domains/$domain/records/$dns_type/$dns_name"
    local headers="-H 'Authorization: sso-key $api_key:$api_secret' -H 'Content-Type: application/json' -H 'Accept: application/json'"

    local dns_records='[{"data": "'"$dns_data"'","ttl": '"$dns_ttl"'}]'
    local curl_command="curl -s -X POST $headers --data '$dns_records' '$url'"
    
    # Execute the cURL command and capture the response
    local response=$(eval "$curl_command")
    local error=$(echo "$response" | jq -r '.errors[0]')

    if [ -z "$error" ]; then
        echo "DNS record created successfully."

        # Verify DNS record by performing a DNS lookup
        verify_dns_record "$domain" "$dns_type" "$dns_name" "$dns_data"
    else
        echo "Error: $error"
    fi
}

# Function to verify DNS record
verify_dns_record() {
    local domain="$1"
    local dns_type="$2"
    local dns_name="$3"
    local dns_data="$4"

    echo "Verifying DNS record..."

    # Perform DNS lookup
    local dns_result=$(dig +short "$dns_name.$domain" "$dns_type")

    if [ -n "$dns_result" ]; then
        echo "DNS record verified: $dns_result"
    else
        echo "Error: DNS record verification failed."
    fi
}


# Create DNS record
create_dns_record "$api_key" "$api_secret" "$domain" "$dns_type" "$dns_name" "$dns_data" "$dns_ttl"
