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
  echo "Service $service_name restarted"
  echo -e "\e[32mRemoved RPC URL: $random_url\e[0m"
  sleep "$restart_delay"
}

function display_waiting_message {
  echo -e "\e[35mI am waiting for you AIRCHAIN\e[0m"
}

function display_motivational_message {
  local messages=(
    "🚀 Keep pushing forward! 🚀"
    "💪 Believe in yourself and all that you are. 💪"
    "✨ Every step you take is a step closer to your goal. ✨"
    "🌟 Stay focused and never give up. 🌟"
    "💥 Your hard work will pay off. 💥"
  )
  local random_message=$(select_random_url "${messages[@]}")
  echo -e "\e[33m${random_message}\e[0m"
}

function display_daily_greeting {
  local now=$(date +%H:%M)
  if [[ "$now" < "12:00" ]]; then
    echo -e "\e[34mGood morning! 🌅 Have a great day! 🌞\e[0m"
  elif [[ "$now" < "18:00" ]]; then
    echo -e "\e[36mGood afternoon! ☀️ Keep going strong! 💪\e[0m"
  else
    echo -e "\e[35mGood evening! 🌜 Relax and unwind. 💤\e[0m"
  fi
}

function display_night_message {
  echo -e "\e[34mGood night! 🌙 Rest well and don't worry, I'm here to fix everything. 🌟\e[0m"
}

function check_for_update {
  local repo_url="https://github.com/Onixs50/fix-stationd-errors"
  local temp_dir="/tmp/fix-stationd-errors-update"

  echo "Checking for updates..."

  # Clone the repo into a temporary directory
  git clone "$repo_url" "$temp_dir" &>/dev/null

  if [ $? -ne 0 ]; then
    echo "Failed to check for updates."
    return
  fi

  cd "$temp_dir"

  # Fetch the latest changes
  git fetch &>/dev/null

  # Check for updates
  local local_commit=$(git rev-parse HEAD)
  local remote_commit=$(git rev-parse @{u})

  if [ "$local_commit" != "$remote_commit" ]; then
    echo "Update found. Applying changes..."

    git pull &>/dev/null

    echo "Update applied. Restarting script..."

    # Clean up
    cd ~
    rm -rf "$temp_dir"

    # Restart the script
    exec "$0"
  else
    echo "No updates found."
    rm -rf "$temp_dir"
  fi
}

echo "Script started to monitor errors in PC logs..."
echo -e "\e[32mby onixia\e[0m"
echo "Timestamp: $(date)"

# Display daily greeting
display_daily_greeting

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

  # Display motivational message every 5 minutes
  sleep 300
  display_motivational_message

  # Check for updates every 5 minutes
  check_for_update

  sleep "$restart_delay"
done
