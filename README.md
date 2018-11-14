# SmartNode

## pre-requeriments
#### software-properties-common;
*( Depends: python3:any, python3, python3-gi, gir1.2-glib-2.0, python-apt-common, python3-dbus, python3-software-properties, ca-certificates )* 
#### [smartcashd](https://launchpad.net/~smartcash/+archive/ubuntu/ppa)
*( Depends: db4.8, smartcash )*

### Bash installer for smartnode on Ubuntu 16.04 LTS x64

#### This shell script comes with 4 cronjobs: 
1. Make sure the daemon is always running: `makerun.sh`
2. Make sure the daemon is never stuck: `checkdaemon.sh`
3. Make sure smartcash is always up-to-date: `upgrade.sh`
4. Clear the log file every other day: `clearlog.sh`

#### On the client-side, use your node-client (formerly known as wallet) and click "Create Smartnode." Input an alias of your choosing, your server's IP address, select a collateral TX and copy/write down your SmartNodeKey.

#### Login to your vps as root, download the install.sh file and then run it, enter the SmartNodeKey you got above when asked for SmartNode GenKey:
```
wget https://rawgit.com/smartcash/smartnode/master/install.sh
bash ./install.sh
```

#### Run the node-client (formerly known as wallet), go to SmartNodes tab, choose your node and click "start alias" at the bottom.

#### You're good to go now. BEE $SMART! https://smartcash.cc
