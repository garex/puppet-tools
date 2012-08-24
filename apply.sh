#!/usr/bin/env bash


echo "Getting settings"
settingsPath=$1
. $settingsPath

if [ -z "$puppetColor" ]; then
  puppetColor="false"
fi

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
  sudo puppet apply --verbose --color $puppetColor --modulepath ~/puppet ~/puppet/$entryPoint;
  rm -rf ~/puppet;
"
echo "Done"
