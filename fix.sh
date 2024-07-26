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
  " VRF record is nil"
)
restart_delay=120
config_file="$HOME/.tracks/config/sequencer.toml"

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
  systemctl restart "$service_name"
  echo -e "\e[32m🚀 Service $service_name restarted with new RPC URL: $random_url\e[0m"
  sleep "$restart_delay"
}

function display_waiting_message {
  echo -e "\e[35m🕒 I am waiting for you AIRCHAIN...\e[0m"
}

function check_for_updates {
  echo -e "\e[34m🔄 Checking for updates...\e[0m"
  cd ~/path_to_repository || exit

  git fetch --quiet

  local local_commit=$(git rev-parse @)
  local remote_commit=$(git rev-parse @{u})

  if [ "$local_commit" != "$remote_commit" ]; then
    echo -e "\e[34m🔄 Update found. Updating...\e[0m"
    git reset --hard HEAD
    git pull --quiet
    echo -e "\e[32m✅ Update completed successfully!\e[0m"
    exit 0
  fi
}

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

      systemctl stop "$service_name"
      cd ~/tracks || exit

      echo -e "\e[33m🔄 Starting rollback after changing RPC...\e[0m"
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      echo -e "\e[32m✅ Rollback completed, restarting $service_name...\e[0m"

      systemctl start "$service_name"
      display_waiting_message
      break
    fi
  done

  sleep "$restart_delay"
done
