#!/usr/bin/env bash

# Display defaults
if [ -z "$PUPPET_COLOR" ]; then
  PUPPET_COLOR="yes"
fi

echo "Getting settings"
settingsPath=$1
. $settingsPath

echo "Uploading puppet"
ssh $userName@$hostName "
  rm -rf ~/puppet;
  mkdir -p ~/puppet;
"
for module in $(echo $modules | tr ":" "\n")
do
  scp -r -q $module $userName@$hostName:~/puppet/$(basename $module)
done

echo "Applying puppet"
ssh $userName@$hostName "
  sudo puppet apply --verbose --color $PUPPET_COLOR --modulepath ~/puppet ~/puppet/$entryPoint;
  rm -rf ~/puppet;
"
echo "Done"
