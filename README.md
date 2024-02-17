# Update DNS Script for Cloudflare

This script (`update_dns.sh`) automatically updates a specific DNS record in Cloudflare with the current external IP address of your server. It's useful for environments with dynamic IP addresses, ensuring your domain always points to the correct IP.

## Prerequisites

- A Cloudflare account
- A domain managed by Cloudflare
- `curl` and `jq` installed on your server (for making API calls and parsing JSON responses, respectively)

## Installation

1. **Install Required Tools:**

   Ensure `curl` and `jq` are installed on your server. If not, install them:

   `sudo apt update && sudo apt install curl jq -y`

 
2. **Download the Script:**

   Download `update_dns.sh`.

   `wget https://raw.githubusercontent.com/paulduca/cloudflare-simple-ddns/main/update_dns.sh`


3. **Make the Script Executable:**

   Change the script's permissions to make it executable.

   `chmod +x /path/to/update_dns.sh`


## Configuration

1. **API Token:**

   Generate an API token in Cloudflare with permissions to edit DNS settings:
     - Go to My Profile → API Tokens → Create Token.
     - Use the "Edit zone DNS" template and select the domain you want to update.

2. **Zone ID:**

   Find your Zone ID in the Cloudflare dashboard under the "Overview" tab for your domain.

3. **Edit the Script:**

   Open `update_dns.sh` in a text editor and replace the placeholders (`<cloudflare_api_token>` and `<zone_id>`) with your actual Cloudflare API token and Zone ID. Also, set `RECORD_NAME` to the DNS record you wish to update (e.g., `server.domain.tld`).



## Usage

1. **Run the Script Manually:**

   To manually update your DNS record, execute the script:

   `/path/to/update_dns.sh`


2. **Automate DNS Updates:**

   To have the script run automatically at regular intervals, use `cron`. To edit the crontab:

   `crontab -e`

   Add the following line to run the script every minute:

   `* * * * * /path/to/update_dns.sh >> /var/log/update_dns.log 2>&1`


 This will also log output and errors to `/var/log/update_dns.log`.


## Troubleshooting

- **Permission Issues:**
Ensure `update_dns.sh` is executable (`chmod +x /path/to/update_dns.sh`).

- **API Token Errors:**
Double-check your API token permissions in Cloudflare. The token should have `Zone.DNS` set to `Edit`.

- **Connectivity Issues:**
Ensure your server can reach Cloudflare's API and the external IP service.

- **Logging:**
Check `/var/log/update_dns.log` for any error messages or output from the script.

## Support

For additional help or information about Cloudflare's API, refer to the [Cloudflare API documentation](https://api.cloudflare.com/).




