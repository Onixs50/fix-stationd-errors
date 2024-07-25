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
    nano fix.sh
    ```

3. Copy and paste the following script into the editor:

```#!/bin/bash

service_name="stationd"
error_strings=(
  "ERROR"
  "with gas used"
  "Failed to Init VRF"
  "Client connection error: error while requesting node"
  "Error in getting sender balance : http post error: Post"
  "rpc error: code = ResourceExhausted desc = request ratelimited"
  "rpc error: code = ResourceExhausted desc = request ratelimited: System blob rate limit for quorum 0"
  "ERR"
  "Retrying the transaction after 10 seconds..."
  "Error in VerifyPod transaction Error"
  "Error in ValidateVRF transaction Error"
  "Failed to get transaction by hash: not found"
  "json_rpc_error_string: error while requesting node"
  "can not get junctionDetails.json data"
  "JsonRPC should not be empty at config file"
  "Error in getting address"
  "Failed to load conf info"
  "error unmarshalling config"
  "Error in initiating sequencer nodes due to the above error"
  "Failed to Transact Verify pod"
  " VRF record is nil"
)
restart_delay=120
config_file="$HOME/.tracks/config/sequencer.toml"

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

function select_random_url {
  local array=("$@")
  local rand_index=$(( RANDOM % ${#array[@]} ))
  echo "${array[$rand_index]}"
}

function update_rpc_and_restart {
  local random_url=$(select_random_url "${unique_urls[@]}")
  sed -i -e "s|JunctionRPC = \"[^\"]*\"|JunctionRPC = \"$random_url\"|" "$config_file"
  systemctl restart "$service_name"
  echo "Service $service_name restarted"
  echo -e "\e[32mRemoved RPC URL: $random_url\e[0m"
  sleep "$restart_delay"
}

function display_waiting_message {
  echo -e "\e[35mI am waiting for you AIRCHAIN\e[0m"
}

echo "Script started to monitor errors in PC logs..."
echo -e "\e[32mby onixia\e[0m"
echo "Timestamp: $(date)"

while true; do
  logs=$(systemctl status "$service_name" --no-pager | tail -n 10)

  for error_string in "${error_strings[@]}"; do
    if echo "$logs" | grep -q "$error_string"; then
      echo "Found error ('$error_string') in logs, updating $config_file and restarting $service_name..."

      update_rpc_and_restart

      systemctl stop "$service_name"
      cd ~/tracks

      echo "Starting rollback after changing RPC..."
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      echo "Rollback completed, restarting $service_name..."

      systemctl start "$service_name"
      display_waiting_message
      break
    fi
  done

  sleep "$restart_delay"
done
```
4. Save and exit the editor:
    - For nano: Press `Ctrl+X`, then `Y` and `Enter` to save the file and exit.

5. Make the script executable:
    ```sh
    chmod +x fix.sh
    ```

6. Run the script:
    ```sh
    bash fix.sh
    ```
![image](https://github.com/user-attachments/assets/fae5e553-263b-4a80-be8a-5607817ad8e4)







