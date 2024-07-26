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

function check_for_updates {
  echo "Checking for updates..."
  local repo_url="https://github.com/Onixs50/fix-stationd-errors.git"
  local local_dir="$HOME/fix-stationd-errors"
  
  if [ -d "$local_dir" ]; then
    cd "$local_dir"
    git fetch origin main
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/main)
    
    if [ "$local_commit" != "$remote_commit" ]; then
      echo "New update found. Updating..."
      git pull origin main
      echo -e "\e[32mUpdated to the latest version from $repo_url\e[0m"
    else
      echo "Already up-to-date."
    fi
  else
    git clone "$repo_url" "$local_dir"
    echo -e "\e[32mCloned the repository from $repo_url\e[0m"
  fi
}

function fetch_crypto_quote {
  local quote=$(curl -s https://api.cryptomotivation.com/random | jq -r '.quote')
  echo -e "\e[36mCrypto Motivation: $quote\e[0m"
}

function morning_greeting {
  echo -e "\e[34mGood morning!☀️ Ready to conquer the crypto world today?🚀\e[0m"
}

function night_greeting {
  echo -e "\e[34mGood night!🌙 Sleep well and dream of moonshots.✨ Don't worry, I'm here to keep everything running smoothly.🛌\e[0m"
}

echo "Script started to monitor errors in PC logs..."
echo -e "\e[32mby onixia\e[0m"
echo "Timestamp: $(date)"

# Initial morning greeting
morning_greeting

# Schedule morning greeting at 7 AM and night greeting at 10 PM
(crontab -l 2>/dev/null; echo "0 7 * * * $(realpath $0) morning_greeting") | crontab -
(crontab -l 2>/dev/null; echo "0 22 * * * $(realpath $0) night_greeting") | crontab -

# Initial fetch of crypto motivation quote
fetch_crypto_quote

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

  check_for_updates
  
  # Fetch and display a new crypto quote every 2 hours
  fetch_crypto_quote
  sleep 7200
done

# Support message
echo -e "\e[31m🚀🚀🚀 If you would like to support me, you can donate to this address: 0x7F60244433Af55b0f030f05a798A48Efc01b18b1 🚀🚀🚀\e[0m"
