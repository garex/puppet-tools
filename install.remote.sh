#!/usr/bin/env bash

echo "Setting rights to .ssh for root"
chmod 700 ~/.ssh
chmod 640 ~/.ssh/authorized_keys

echo "Adding auth keys for user"
userName=$1
userHome=$(grep $userName /etc/passwd | cut -d ":" -f6)
rm -rf $userHome/.ssh
mkdir $userHome/.ssh
cp ~/.ssh/authorized_keys $userHome/.ssh/authorized_keys

echo "Setting rights to .ssh for user"
chown -R $userName:$userName $userHome/.ssh
chmod 700 $userHome/.ssh
chmod 640 $userHome/.ssh/authorized_keys

echo "Setting up user as sudoer for puppet"
echo "# Edit this by 'visudo' as root.
Defaults    env_reset
root        ALL = (ALL) ALL
$userName   ALL = NOPASSWD: /usr/bin/puppet
" > /etc/sudoers

echo "Installing sudo & puppet"
echo "APT::Get::AllowUnauthenticated 1;" > /etc/apt/apt.conf
echo "deb http://debian.nsu.ru/debian squeeze main" > /etc/apt/sources.list
echo "deb http://debian.nsu.ru/debian-security squeeze/updates main" >> /etc/apt/sources.list

apt-get update
apt-get -y upgrade
apt-get -y install sudo
apt-get -y install puppet
