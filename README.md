# fix-stationd-errors

This script monitors the logs of the `stationd` service and performs actions based on specific error strings. It updates the RPC URL and restarts the service when certain errors are found.

## Prerequisites

Before running the script, make sure you have the following installed:

1. Update your package list:
    ```sh
    sudo apt-get update
    ```

2. Install `screen`:
    ```sh
    sudo apt-get install screen
    ```

## Usage

1. Create a new screen session:
    ```sh
    screen -S fix
    ```

2. Open a text editor to create the script:
    ```sh
    nano fix_stationd_errors.sh
    ```

3. Copy and paste the following script into the editor:

    ```bash
    #!/bin/bash

    # Define service name and log search string
    service_name="stationd"
    error_string="ERROR"  # Error string to search for in PC logs
    gas_string="with gas used"
    vrf_error_string="Failed to Init VRF"  # New error string to search for
    client_error_string="Client connection error: error while requesting node"  # Another error string to search for
    balance_error_string="Error in getting sender balance : http post error: Post"  # Another error string to search for
    rate_limit_error_string="rpc error: code = ResourceExhausted desc = request ratelimited"  # Rate limit error string to search for
    restart_delay=180  # Restart delay in seconds (3 minutes)
    config_file="$HOME/.tracks/config/sequencer.toml"

    # List of unique RPC URLs
    unique_urls=(
      "https://airchains-rpc-testnet.zulnaaa.com/"
      "https://t-airchains.rpc.utsa.tech/"
      "https://airchains.rpc.t.stavr.tech/"
      "https://airchains-rpc.chainad.org/"
      "https://junction-rpc.kzvn.xyz/"
      "https://airchains-rpc.elessarnodes.xyz/"
      "https://airchains-testnet-rpc.apollo-sync.com/"
      "https://rpc-airchain.danggia.xyz/"
      "https://airchains-rpc.stakeme.pro/"
      "https://airchains-testnet-rpc.crouton.digital/"
      "https://airchains-testnet-rpc.itrocket.net/"
      "https://rpc1.airchains.t.cosmostaking.com/"
      "https://rpc.airchain.yx.lu/"
      "https://airchains-testnet-rpc.staketab.org/"
      "https://junction-rpc.owlstake.com/"
      "https://rpctt-airchain.sebatian.org/"
      "https://rpc.airchains.aknodes.net/"
      "https://rpc-testnet-airchains.nodeist.net/"
      "https://airchains-testnet.rpc.stakevillage.net/"
      "https://airchains-rpc.sbgid.com/"
      "https://airchains-test.rpc.moonbridge.team/"
      "https://rpc-airchains-t.sychonix.com/"
      "https://airchains-rpc.anonid.top/"
      "https://rpc.airchains.stakeup.tech/"
      "https://junction-testnet-rpc.nodesync.top/"
      "https://rpc-airchain.vnbnode.com/"
      "https://airchain-t-rpc.syanodes.my.id"
      "https://airchains-test-rpc.nodesteam.tech/"
      "https://junction-testnet-rpc.synergynodes.com/"
      "https://rpc-t.airchains.safeblock.space/"
      "https://airchains-rpc.kubenode.xyz/"
    )

    # Function to select a random URL from the list
    function select_random_url {
      local array=("$@")
      local rand_index=$(( RANDOM % ${#array[@]} ))
      echo "${array[$rand_index]}"
    }

    echo "Script started to monitor errors in PC logs..."
    echo "by onixia"

    while true; do
      # Get the last 10 lines of service logs
      logs=$(systemctl status "$service_name" --no-pager | tail -n 10)

      # Check for errors in logs
