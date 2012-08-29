#!/usr/bin/env bash

modulePath='~/puppet'

# Getting settings
settingsPath=$1
. $settingsPath

# zero
if [ -z "$puppetColor" ]; then
  puppetColor="false"
fi

# Packing puppet
packDirectory=$(mktemp --directory)
packFile=$(mktemp)
trap "rm --recursive --force $packDirectory" EXIT
trap "rm --recursive --force $packFile" EXIT

for module in $(echo $modules | tr ":" "\n")
do
  cp --recursive $module $packDirectory/$(basename $module)
  rm --recursive --force $packDirectory/$(basename $module)/.git
done

tar --create --bzip2 --file $packFile --directory $packDirectory .

echo "Uploading puppet"
ssh $userName@$hostName "
  rm --recursive --force $modulePath;
  mkdir --parents $modulePath;
"
# quiet
scp -q $packFile $userName@$hostName:$modulePath/$(basename $packFile)

echo "Applying puppet"
ssh $userName@$hostName "
  tar --extract --bzip2 --file $modulePath/$(basename $packFile) --directory $modulePath
  sudo puppet apply --verbose --color $puppetColor --modulepath $modulePath $modulePath/$entryPoint;
  rm --recursive --force $modulePath;
"
echo "Done"
