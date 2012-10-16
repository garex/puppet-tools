#!/usr/bin/env bash

# Base vars
HERE=$(dirname $0)

echo "Getting settings"
settingsPath=$1
. $settingsPath

# -z = zero
if [ -z "$userName" ]; then
  userName=puppet
fi

# Path to remote install script
remoteScriptPath=$HERE/
remoteScriptName=install.remote.sh
remoteScript=$remoteScriptPath$remoteScriptName

echo "Getting public key from your $localKey (could ask your key's password)"
publicKey=$(ssh-keygen -y -f $localKey)

echo "Removing remote SSH host from known_hosts"
ssh-keygen -R $hostName
for ip in $(dig +short $hostName)
do
  ssh-keygen -R $ip
done

echo "Uploading public key to remote host (could ask your remote root's password)"
ssh $rootName@$hostName "mkdir -p ~/.ssh && echo $publicKey > ~/.ssh/authorized_keys"

echo "Uploading initial install script"
scp $remoteScript $rootName@$hostName:~

echo "Running initial install script"
ssh $rootName@$hostName "chmod +x ~/$remoteScriptName && ~/$remoteScriptName $userName"

echo "Done. Now you can use apply.sh to manage remote host."
