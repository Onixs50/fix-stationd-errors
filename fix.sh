#!/bin/bash

# Initial settings
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
restart_delay=100
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
)

api_url="https://quote-garden.herokuapp.com/api/v3/quotes/random"
quotes_file="$HOME/.tracks/quotes_used.txt"

function select_random_url {
  local array=("$@")
  local rand_index=$(( RANDOM % ${#array[@]} ))
  echo "${array[$rand_index]}"
}

function update_rpc_and_restart {
  local random_url=$(select_random_url "${unique_urls[@]}")
  sed -i -e "s|JunctionRPC = \"[^\"]*\"|JunctionRPC = \"$random_url\"|" "$config_file"
  systemctl restart "$service_name"
  echo -e "\e[32m🟢 Service $service_name restarted with new RPC URL: $random_url\e[0m"
  sleep "$restart_delay"
}

function display_waiting_message {
  echo -e "\e[35m💬 I am waiting for you AIRCHAIN...\e[0m"
}

function get_motivational_message {
  local response=$(curl -s "$api_url")
  local message=$(echo "$response" | jq -r '.data[0].quote')
  echo "$message"
}

function display_motivational_message {
  local message=$(get_motivational_message)
  echo -e "\e[34m$message\e[0m"
}

function display_daily_greeting {
  local current_hour=$(date +"%H")
  if [ "$current_hour" -lt 12 ]; then
    echo -e "\e[36m🌅 Good morning! Have a great day ahead!\e[0m"
  elif [ "$current_hour" -ge 18 ]; then
    echo -e "\e[33m🌙 Good night! Sleep well and don't worry, I’m here to fix everything!\e[0m"
  else
    echo -e "\e[32m☀️ Good afternoon! Keep up the great work!\e[0m"
  fi
}

function check_for_updates {
  echo -e "\e[33m🔄 Checking for updates...\e[0m"
  local repo_url="https://github.com/Onixs50/fix-stationd-errors.git"
  local local_dir="$HOME/fix-stationd-errors"
  
  if [ -d "$local_dir" ]; then
    cd "$local_dir"
    git fetch origin main
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/main)
    
    if [ "$local_commit" != "$remote_commit" ]; then
      echo -e "\e[32m🔧 New update found! Updating...\e[0m"
      git pull origin main
      echo -e "\e[32m✅ Updated to the latest version from $repo_url\e[0m"
      
      echo -e "\e[31m🚨 Restarting the script to apply new updates...\e[0m"
      pkill -f "$(basename $0)"
      exec "$0" &
      
    else
      echo -e "\e[32m✅ Already up-to-date.\e[0m"
    fi
  else
    git clone "$repo_url" "$local_dir"
    echo -e "\e[32m🔄 Cloned the repository from $repo_url\e[0m"
  fi
}

function log_used_quote {
  local message="$1"
  echo "$message" >> "$quotes_file"
}

function is_quote_used {
  local message="$1"
  grep -Fxq "$message" "$quotes_file"
}

echo -e "\e[36m🛠️ Script started to monitor errors in PC logs...\e[0m"
echo -e "\e[32mby Onixs\e[0m"
echo "Timestamp: $(date)"

while true; do
  check_for_updates

  display_daily_greeting

  logs=$(systemctl status "$service_name" --no-pager | tail -n 10)
  for error_string in "${error_strings[@]}"; do
    if echo "$logs" | grep -q "$error_string"; then
      echo -e "\e[31mFound error ('$error_string') in logs, updating $config_file and restarting $service_name...\e[0m"
      update_rpc_and_restart

      systemctl stop "$service_name"
      cd ~/tracks

      echo -e "\e[31m🔄 Starting rollback after changing RPC...\e[0m"
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      go run cmd/main.go rollback
      echo -e "\e[32m✅ Rollback completed, restarting $service_name...\e[0m"

      systemctl start "$service_name"
      display_waiting_message
      break
    fi
  done

  local message
  while true; do
    message=$(get_motivational_message)
    if ! is_quote_used "$message"; then
      break
    fi
  done
  display_motivational_message
  log_used_quote "$message"

  sleep 300 # Sleep for 5 minutes
done
