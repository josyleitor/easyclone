#!/usr/bin/env bash
#=============================================================
# https://github.com/xd003/clone
# File Name: setup.sh
# Author: xd003
# Description: Installing prerequisites for clone script
# System Supported: Arch , Ubuntu/Debian , Fedora & Termux
#=============================================================

#Variables 
arch="$(uname -m)"
ehome="$(echo $HOME)"
epac="$(which pacman 2>/dev/null)" 
eapt="$(which apt 2>/dev/null)"
ednf="$(which dnf 2>/dev/null)"
conf="$HOME/easyclone/rc.conf"

cecho g "¶ Renaming the json files in numerical order"
rm -rf $HOME/easyclone/accounts/.git
if [ ! -f "$HOME/easyclone/accounts/5.json" ] ; then 
  (cd $HOME/easyclone/accounts; ls -v | cat -n | while read n f; do mv -n "$f" "$n.json"; done)
elif [ ! -f "$HOME/easyclone/accounts/10.json" ] ; then
  (cd $HOME/easyclone/accounts; ls -v | cat -n | while read n f; do mv -n "$f" "$n.json"; done)
elif [ ! -f "$HOME/easyclone/accounts/15.json" ] ; then
  (cd $HOME/easyclone/accounts; ls -v | cat -n | while read n f; do mv -n "$f" "$n.json"; done)
fi
  

# Moving rclone Config file & bookmark.txt to easyclone folder
cecho g "¶ Moving the config file to easyclone folder"
rm -rf $HOME/easyclone/rc.conf
mv $HOME/tmp/rc.conf $HOME/easyclone
if [ ! -f "$HOME/easyclone/bookmark.txt" ] ; then 
  mv $HOME/tmp/bookmark.txt $HOME/easyclone
fi
sed -i "s|HOME|$ehome|g" $conf


sasyncinstall() {
cecho g "¶ Installing rclone"
case $ehome in
/data/data/com.termux/files/home)
  pkg install rclone &>/dev/null
  ;;
*)
  curl https://rclone.org/install.sh | sudo bash &>/dev/null
  ;;
esac


lcloneinstall() {
if [ "$arch" == "arm64" ] || [ "$ehome" == "/data/data/com.termux/files/home" ] ; then
  arch=arm64
elif [ "$arch" == "x86_64" ] ; then
  arch=amd64
elif [ "$arch" == "*" ] ; then
  cecho r "Unsupported Kernel architecture , Install again and select Sasync as default cloning tool" && \
  exit
fi

cecho g "¶ Downloading and adding lclone to path"
elclone="$(lclone version 2>/dev/null)" 
check="$(echo "$elclone" | grep 'v1\.55\.0-DEV')"
if [ -z "${check}" ] ; then
  lclone_version="v1.55.0-DEV"
  URL=http://easyclone.xd003.workers.dev/0:/lclone/lclone-$lclone_version-linux-$arch.zip
  wget -c -t 0 --timeout=60 --waitretry=60 $URL -O $HOME/tmp/lclone.zip &>/dev/null
  unzip -q $HOME/tmp/lclone.zip -d $HOME/tmp &>/dev/null
  if [ "$ehome" == "/data/data/com.termux/files/home" ]; then
      mv $HOME/tmp/lclone $spath
      chmod u+x $spath/lclone
  else     
      sudo mv $HOME/tmp/lclone $spath
      sudo chmod u+x $spath/lclone
  fi
fi
}

lcloneinstall

####################################################################

echo
case 2 in
1)
   cecho g "¶ Creating Symlink for clone script in path"
  if [ "$ehome" == "/data/data/com.termux/files/home" ]; then
      ln -sf "$HOME/easyclone/rclone" "$spath/clone"
      chmod u+x $spath/clone
  else  
      sudo ln -sf "$HOME/easyclone/rclone" "$spath/clone"
      sudo chmod u+x $spath/clone
  fi
  ;;
2)
  cecho g "¶ Creating Symlink for clone script in path"
  if [ "$ehome" == "/data/data/com.termux/files/home" ]; then
      ln -sf "$HOME/easyclone/lclone" "$spath/clone"
      chmod u+x $spath/clone
  else  
      sudo ln -sf "$HOME/easyclone/lclone" "$spath/clone"
      sudo chmod u+x $spath/clone
  fi
  ;;
esac

# Shorten Expanded Variable
if [ "$ehome" == "/data/data/com.termux/files/home" ]; then
  sed -i "s|--config=$HOME/easyclone/rc.conf|--config=$conf|g" $(which clone)
else
  sudo sed -i "s|--config=$HOME/easyclone/rc.conf|--config=$conf|g" $(which clone)
fi

rm -rf $HOME/tmp
cecho g "¶ Installation 100% successful"
echo
cecho g "✓ Entering clone will always start the script henceforth"
