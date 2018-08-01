
if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

printf "Name of coin folder: "
read _coinName
printf "Example: su - smartadmin -c "smartcashd" "
printf "Example: su - adnuser -c "~/adn/adnd --daemon" "
printf "Example: su - gobyteadmin -c "~/gobyte/src/gobyted -daemon" "
printf "Exact command for root user to start the node (see examples above): "
read _startNode

if ! crontab -l | grep "@reboot ${ _startNode; }"; then
  (crontab -l ; echo "@reboot ${ _startNode; }") | crontab -
fi

if ! crontab -l | grep "/bin/date > ~/.${ _coinName; }/debug.log"; then
  (crontab -l ; echo "0 0 */2 * * /bin/date > ~/.${ _coinName; }/debug.log") | crontab -
fi
