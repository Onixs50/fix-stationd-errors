#!/bin/bash

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
  "VRF record is nil"
)
restart_delay=120
config_file="$HOME/.tracks/config/sequencer.toml"
repository_path="/root/fix-stationd-errors"
unique_urls=(
  "https://t-airchains.rpc.utsa.tech/"
  "https://airchains.rpc.t.stavr.tech/"
  "https://airchains-rpc.chainad.org/"
  "https://junction-rpc.kzvn.xyz/"
  "https://airchains-testnet-rpc.apollo-sync.com/"
  "https://rpc-airchain.danggia.xyz/"
  "https://airchains-testnet-rpc.stakerhouse.com/"
  "https://airchains-testnet-rpc.crouton.digital/"
  "https://airchains-testnet-rpc.itrocket.net/"
  "https://rpc1.airchains.t.cosmostaking.com/"
  "https://rpc.airchain.yx.lu/"
  "https://airchains-testnet-rpc.staketab.org/"
  "https://rpc.airchains.aknodes.net/"
  "https://airchains-rpc-testnet.zulnaaa.com/"
  "https://rpc-testnet-airchains.nodeist.net/"
  "https://airchains-testnet.rpc.stakevillage.net/"
  "https://airchains-rpc.sbgid.com/"
  "https://airchains-test.rpc.moonbridge.team/"
  "https://rpc-airchains-t.sychonix.com/"
  "https://junction-testnet-rpc.nodesync.top/"
  "https://rpc-airchain.vnbnode.com/"
  "https://junction-rpc.validatorvn.com/"
  "https://airchains-testnet-rpc.nodesphere.net/"
  "https://airchains-testnet-rpc.cherryvalidator.us/"
  "https://airchain-testnet-rpc.cryptonode.id/"
  "https://rpc.airchains.preferrednode.top/"
  "https://airchains-testnet-rpc.validator247.com/"
  "https://airchains-t-rpc.noders.services/"
  "https://rpc.airchains-t.linkednode.xyz/"
  "https://rpc-airchains.bootblock.xyz/"
  "https://airchains-rpc.henry3222.xyz/"
  "https://testnet.rpc.airchains.silentvalidator.com/"
  "https://rpc.airchains.stakeup.tech/"
  "https://airchains-testnet-rpc.mekonglabs.tech/"
  "https://testnet.airchain.network/rpc/"
  "https://airchain-rpc.com/"
  "https://airchain-node1.rpc.com/"
  "https://airchain-test-rpc.network/"
  "https://airchain-rpc.test1.xyz/"
  "https://rpc.airchain.testnet.xyz/"
  "https://testnet.rpc.airchain.org/"
  "https://rpc-airchain.testnode.xyz/"
  "https://rpc.airchain.network/"
  "https://airchain-rpc1.node.com/"
  "https://airchain-rpc.testnet.net/"
  "https://rpc-airchain.t1.com/"
  "https://testnet-airchain-rpc.org/"
  "https://airchain-test-rpc.io/"
  "https://test-rpc.airchain.com/"
)

function select_random_url {
  local array=("$@")
  local rand_index=$(( RANDOM % ${#array[@]} ))
  echo "${array[$rand_index]}"
}

function update_rpc_and_restart {
  local random_url=$(select_random_url "${unique_urls[@]}")
  sed -i -e "s|JunctionRPC = \"[^\"]*\"|JunctionRPC = \"$random_url\"|" "$config_file"
  if [[ $? -ne 0 ]]; then
    echo -e "\e[31m Failed to update RPC URL in config file.\e[0m"
    exit 1
  fi

  echo -e "\e[32m Service $service_name stopped.\e[0m"
  systemctl stop "$service_name"
  if [[ $? -ne 0 ]]; then
    echo -e "\e[31m Failed to stop service $service_name.\e[0m"
    exit 1
  fi

  echo -e "\e[32m RPC URL updated to: $random_url\e[0m"
  echo -e "\e[32m Performing rollback...\e[0m"
  cd ~/tracks || exit
  go run cmd/main.go rollback || exit
  go run cmd/main.go rollback || exit
  go run cmd/main.go rollback || exit
  echo -e "\e[32m Rollback completed.\e[0m"

  echo -e "\e[32m Restarting service $service_name...\e[0m"
  systemctl start "$service_name"
  if [[ $? -ne 0 ]]; then
    echo -e "\e[31m Failed to restart service $service_name.\e[0m"
    exit 1
  fi
  echo -e "\e[32m Service $service_name restarted successfully!\e[0m"
  sleep "$restart_delay"
}

function display_waiting_message {
  echo -e "\e[35m I am waiting for you AIRCHAIN...\e[0m"
}

function check_for_updates {
  echo -e "\e[34m Checking for updates...\e[0m"
  cd ~/path_to_repository || exit

  git fetch --quiet

  local local_commit=$(git rev-parse @)
  local remote_commit=$(git rev-parse @{u})

  if [ "$local_commit" != "$remote_commit" ]; then
    echo -e "\e[34m Update found. Downloading and updating...\e[0m"
    wget -q https://github.com/Onixs50/fix-stationd-errors/blob/main/fix.sh -O fix.sh
    if [[ $? -ne 0 ]]; then
      echo -e "\e[31m Failed to download update.\e[0m"
      exit 1
    fi
    chmod +x fix.sh
    echo -e "\e[32m Update completed successfully!\e[0m"
    echo -e "\e[32m Restarting script to apply changes...\e[0m"
    exec "$0"
  fi
}

echo -e "\e[36m Don't worry, I've got this! I'll take care of everything.\e[0m"
echo "Script started to monitor errors in PC logs..."
echo -e "\e[32mby onixia\e[0m"
echo "Timestamp: $(date)"

while true; do
  check_for_updates

  logs=$(systemctl status "$service_name" --no-pager | tail -n 5)

  for error_string in "${error_strings[@]}"; do
    if echo "$logs" | grep -q "$error_string"; then
      echo -e "\e[31mFound error ('$error_string') in logs, updating $config_file and restarting $service_name...\e[0m"

      update_rpc_and_restart

      display_waiting_message
      break
    fi
  done

  sleep 300  # Check for updates every 5 minutes
done

echo -e "\e[32mCoded By Onixia\e[0m"
