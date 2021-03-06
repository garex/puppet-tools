# Puppet masterless management tools

Allows to initially install masterless puppet on remote node and then periodically manualy apply it.

## Description

This module is for masterless puppet versions. On new node it runs once in installs puppet. And then you periodically apply changes in your manifests to this node.

Both install & apply you run on your machine, that contacts remote node via SSH and do all job there.

## Usage

### Install

You are ready to install some puppet modules to some node. These modules are somewhere on your machine. One of them is main module.

So you create in it file with settings, like:

    hostName=your.remote.node.com
    rootName=root
    userName=user
    localKey=~/.ssh/id_rsa
    puppetColor=false

    modules=/home/you/puppet/some-main-module:/another/path/to/module2:./moduleN
    entryPoint=/home/you/puppet/some-main-module/manifests/site.pp
    remoteLogRoot=/var/log/puppet

Puppet tradition recommend to put it under "tools" directory. Let it be /home/you/puppet/some-main-module/tools/settings.sh

In modules you need to specify all your modules, that will be uploaded to remote node. And also there should be your main module, that keeps concrete details of your remote node.

*We recommend you to use flat modules structure, as git submodules not always a good idea. But you anyway can use submodules.*

Then just start install.sh, passing to it path to your settings.sh:

    /path/to/puppet-tools/install.sh /home/you/puppet/some-main-module/tools/settings.sh

Script will ask you some SSH-specific questions and then you are done. Now just change your puppet modules & main module and apply changes.

#### Defaults

You can skip userName, puppetColor and remoteLogRoot variables as they are replaced by defaults.
Also when we dont' have specified userName on remote host, then we will add it during initial install.
To log your puppet runs we use remoteLogRoot -- you can also change it or skip to use default value.


### Apply

Apply is easy:

    /path/to/puppet-tools/apply.sh /home/you/puppet/some-main-module/tools/settings.sh

*Just to make note: apply requires install :)*

### IDE specific settings

In IDE you can setup both actions as some custom actions, that are binded to keys. For example in Eclipse we have "External tools", that can be configured and key there is something like "Run last applied action".

So during development/debug you will hit one key and see results in IDE`s console. For console not forget to choose some checkbox in your IDE.

### Windows people

Windows version also exists. It's a good news. "Bad" news is that it have two dependencies or even three:

* path to [Putty][1]
* path to [7-zip][2]
* public key from putty private key

See examples in settings.bat.tpl. All other operations is same -- you only need to use install.bat and apply.bat.

## GOODTODO
* Currently remote-install script is Debian-specific. You are welcome to make it more universal.
* Specify more IDE-specific recipes for puppet development or delegate it by giving link to good source.

  [1]: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html
  [2]: http://www.7-zip.org/download.html
