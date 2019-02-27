#!/bin/sh

if [ -z "$1" ] && [ -z "$2" ]; then
   echo Syntax 
   echo setid \[git-hub login\]
   exit 0
fi

git config --global user.email "$1@users.noreply.github.com"
git config --global user.name "$1"
