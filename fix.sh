#!/bin/bash

LOCKFILE="/tmp/fix.sh.lock"

# Check if the lock file exists
if [ -e "$LOCKFILE" ]; then
  echo "Script is already running."
  exit 1
fi

# Create the lock file
touch "$LOCKFILE"

# Function to remove the lock file on exit
cleanup() {
  rm -f "$LOCKFILE"
}
trap cleanup EXIT

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
  "[GIN]"
)
restart_delay=120
config_file="$HOME/.tracks/config/sequencer.toml"
repository_path="$HOME/fix-stationd-errors"
update_flag="$repository_path/update_flag.txt"

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
"https://airchains-rpc.elessarnodes.xyz/"
"https://airchains-rpc.stakeme.pro/"
"https://rpctt-airchain.sebatian.org/"
"https://junction-rpc.owlstake.com/"
"https://airchains-testnet-rpc.node39.top/"
"https://airchain-t-rpc.syanodes.my.id/"
"https://airchain-testnet-rpc.dashnode.org/"
"https://airchain-rpc.rawakinode.tech/"
"https://airchains-testnet-rpc.mekonglabs.tech/"
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
    echo -e "\e[31mFailed to update RPC URL in config file.\e[0m"
    exit 1
  fi
  echo -e "\e[32mService $service_name stopped.\e[0m"
  systemctl stop "$service_name"
  if [[ $? -ne 0 ]]; then
    echo -e "\e[31mFailed to stop service $service_name.\e[0m"
    exit 1
  fi
  echo -e "\e[32mUpdating repository...\e[0m"
  cd "$repository_path" || exit
  git fetch --quiet
  git reset --hard HEAD
  git pull --quiet
  if [[ $? -ne 0 ]]; then
    echo -e "\e[31mFailed to update repository.\e[0m"
    exit 1
  fi
  echo -e "\e[32mRPC URL updated to: $random_url\e[0m"
  echo -e "\e[32mPerforming rollback...\e[0m"
  cd ~/tracks || exit
  go run cmd/main.go rollback || exit
  go run cmd/main.go rollback || exit
  go run cmd/main.go rollback || exit
  echo -e "\e[32mRollback completed.\e[0m"
  echo -e "\e[32mRestarting service $service_name...\e[0m"
  systemctl start "$service_name"
  if [[ $? -ne 0 ]]; then
    echo -e "\e[31mFailed to restart service $service_name.\e[0m"
    exit 1
  fi
  echo -e "\e[32mService $service_name restarted successfully!\e[0m"
  sleep "$restart_delay"
}

function display_waiting_message {
  echo -e "\e[35mI am waiting for you AIRCHAIN...\e[0m"
}

function check_for_updates {
  cd "$repository_path" || exit
  git fetch --quiet
  local local_commit=$(git rev-parse @)
  local remote_commit=$(git rev-parse @{u})
  if [ "$local_commit" != "$remote_commit" ]; then
    echo -e "\e[31m+\e[0m \e[32m+\e[0m \e[31m+\e[0m \e[32m+\e[0m \e[31m+\e[0m"
    echo -e "\e[32mUpdate found. Downloading and updating...\e[0m"
    wget -q https://raw.githubusercontent.com/Onixs50/fix-stationd-errors/main/fix.sh -O fix.sh > /dev/null 2>&1
    chmod +x fix.sh > /dev/null 2>&1
    echo -e "\e[32mUpdate completed successfully!\e[0m"
    touch "$update_flag"
    echo -e "\e[32mRestarting script to apply changes...\e[0m"
    rm -f "$LOCKFILE"
    exec bash "$repository_path/fix.sh"
  else
    rm -f "$update_flag"
  fi
}

echo -e "\e[1;32m============================================\e[0m"
echo -e "\e[1;32m      Script Monitoring and Update Tool      \e[0m"
echo -e "\e[1;32m          Created by Onixia                 \e[0m"
echo -e "\e[1;32m============================================\e[0m"
echo -e "\e[1;36mScript started to monitor logs...\e[0m"
echo "Timestamp: $(date)"
echo -e "\e[32mCoded By Onixia\e[0m"
echo "Script started to monitor errors in airchain logs..."
echo "Timestamp: $(date)"
last_update_time=$(date +%s)
update_interval=80000

while true; do
  current_time=$(date +%s)
  if [ $((current_time - last_update_time)) -ge $update_interval ]; then
    check_for_updates
    last_update_time=$current_time
  fi
  logs=$(systemctl status "$service_name" --no-pager | tail -n 9)
  for error in "${error_strings[@]}"; do
    if echo "$logs" | grep -q "$error"; then
      echo -e "\e[31mFound error ('$error') in logs, updating $config_file and restarting $service_name...\e[0m"
      update_rpc_and_restart
      break
    fi
  done
  sleep 40
done
