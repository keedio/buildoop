#!/bin/bash
BUILDOOP_BRANCH=$1
RECIPES_ORG=$2
RECIPES_REPO=$3
BRANCH=$4
FORCE_CLEAN=$5
PKG=$6

REMOTE_REPO=$RECIPES_ORG/$RECIPES_REPO
echo $HOME
echo $BUILDOOP_BRANCH

echo $REMOTE_REPO
echo $BRANCH
echo $FORCE_CLEAN
echo $PKG
#echo $BDROOT


#export HOME=/home/$USER
source $HOME/.bash_profile &>/dev/null

echo $BDROOT

github_prefix="git@github.com:"
#github_prefix="https://github.com/"

echo -e "\n >>> Building $PKG on $(whoami)@$(hostname) \n"

cd $BDROOT

echo -e "\n >>> Checking out branch $BUILDOOP_BRANCH \n"
git checkout $BUILDOOP_BRANCH

echo -e "\n >>> Pulling changes from $BUILDOOP_BRANCH \n"
git pull origin

#if [ ! -d "./$REMOTE_REPO" ]; then
#   echo "remoterepo: $github_prefix/$REMOTE_REPO"
#   buildoop -remoterepo $github_prefix/$REMOTE_REPO
#fi

if [ ! -d "./recipes/$REMOTE_REPO" ]; then
   echo -e "\n >>> Downloading $BRANCH from REPO: $github_prefix$REMOTE_REPO \n"
   buildoop -downloadrepo $github_prefix$REMOTE_REPO $BRANCH
fi

cd ./recipes/$BRANCH
echo -e "\n >>> Pulling changes from $github_prefix/$REMOTE_REPO $BRANCH \n"
git pull origin

cd $BDROOT

if $FORCE_CLEAN ; then 
   echo -e "\n >>> Cleaning previously built artifact for package $PKG \n"
   buildoop $BRANCH $PKG -clean
fi

echo -e "\n >>> Building package $PKG \n"
buildoop $BRANCH $PKG -build

