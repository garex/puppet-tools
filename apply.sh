#!/usr/bin/env bash

modulePath='~/puppet'

echo "Getting settings"
settingsPath=$1
. $settingsPath

# zero
if [ -z "$puppetColor" ]; then
  puppetColor="false"
fi

echo "Uploading puppet"
ssh $userName@$hostName "
  rm --recursive --force $modulePath;
  mkdir --parents $modulePath;
"
for module in $(echo $modules | tr ":" "\n")
do
  # recursively, quiet & with compression
  scp -r -q -C $module $userName@$hostName:$modulePath/$(basename $module)
done

echo "Applying puppet"
ssh $userName@$hostName "
  sudo puppet apply --verbose --color $puppetColor --modulepath $modulePath $modulePath/$entryPoint;
  rm --recursive --force $modulePath;
"
echo "Done"
