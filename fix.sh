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
update_interval=120  # 2 دقیقه

while true; do
  current_time=$(date +%s)
  if [ $((current_time - last_update_time)) -ge $update_interval ]; then
    check_for_updates
    last_update_time=$current_time
  fi
  logs=$(systemctl status "$service_name" --no-pager | tail -n 10)
  for error in "${error_strings[@]}"; do
    if echo "$logs" | grep -q "$error"; then
      echo -e "\e[31mFound error ('$error') in logs, updating $config_file and restarting $service_name...\e[0m"
      update_rpc_and_restart
      break
    fi
  done
  sleep 40
done
