# SmartNode
### Bash installer for smartnode on Ubuntu 16.04 LTS x64

#### This shell script comes with 4 cronjobs: 
1. Make sure the daemon is always running: `makerun.sh`
2. Make sure the daemon is never stuck: `checkdaemon.sh`
3. Make sure smartcash is always up-to-date: `upgrade.sh`
4. Clear the log file every other day: `clearlog.sh`

#### Login to your vps as normal user with sudo rights (not root), download the install.sh file and then run it:
```
wget https://rawgit.com/smartcash/smartnode/master/install.sh
bash ./install.sh
```

### (Optional) Remove sudo rights from user

#### On the client-side, add the following line to smartnode.conf:
```
node-alias vps-ip:9678	node-key collateral-txid vout
```

#### Run the qt wallet, go to SmartNodes tab, choose your node and click "start alias" at the bottom.

#### You're good to go now. BEE $SMART! https://smartcash.cc
