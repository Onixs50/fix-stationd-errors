#!/bin/bash

# Variables
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
repository_path="$HOME/fix-stationd-errors"
update_flag="$repository_path/update_flag.txt"
script_name=$(basename "$0")
lockfile="/tmp/${script_name}.lock"

unique_urls=(
  "https://t-airchains.rpc.utsa.tech/"
  "https://airchains.rpc.t.stavr.tech/"
  "https://airchains-rpc.chainad.org/"
  # (Add the remaining URLs as needed)
)

function acquire_lock {
    exec 200>$lockfile
    flock -n 200 || { echo -e "\e[31mAnother instance of the script is running.\e[0m"; exit 1; }
}

function release_lock {
    flock -u 200
    rm -f "$lockfile"
}

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
    cd ~/tracks || exit
    git pull || { echo -e "\e[31mFailed to update repository.\e[0m"; exit 1; }

    echo -e "\e[32mRPC URL updated to: $random_url\e[0m"
    echo -e "\e[32mPerforming rollback...\e[0m"
    for i in {1..3}; do
        go run cmd/main.go rollback || exit
    done
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
        wget -q https://raw.githubusercontent.com/Onixs50/fix-stationd-errors/main/fix.sh -O "$repository_path/fix.sh" > /dev/null 2>&1
        chmod +x "$repository_path/fix.sh" > /dev/null 2>&1

        touch "$update_flag"
        echo -e "\e[32mUpdate completed successfully!\e[0m"
        echo -e "\e[32mStopping current script...\e[0m"

        # Run the updated script in the same screen session
        "$repository_path/fix.sh"
        exit 0
    else
        rm -f "$update_flag"
    fi
}

# Start the script
acquire_lock
echo -e "\e[1;32m============================================\e[0m"
echo -e "\e[1;32m      Script Monitoring and Update Tool      \e[0m"
echo -e "\e[1;32m          Created by Onixia                 \e[0m"
echo -e "\e[1;32m============================================\e[0m"
echo -e "\e[1;36mScript started to monitor logs...\e[0m"
echo "Timestamp: $(date)"
echo -e "\e[32mCoded By Onixia\e[0m"
echo "Script started to monitor errors in shit airchain..."
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

    sleep 600  # Check for updates every 10 minutes
done

release_lock
echo -e "\e[32mCoded By Onixia\e[0m"
