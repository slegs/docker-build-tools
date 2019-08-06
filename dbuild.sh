#!/bin/bash

function usage {
        cat <<EOM

Docker and Git Build tool for Docker Images

Create symbolic links for
- drelease.sh to /usr/local/bin/drelease
- dbuild.sh to /usr/local/bin/dbuild

Call from build directory where your Dockerfile is located

What it does
- Builds Docker image and tags with version number along with stable or dev identifier
- Optionally runs the built image in Docker

Usage: $(basename "$0") [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version label (required)
  -h          display help

EOM

}


#Show the current directory
echo "Docker Build Directory=$PWD"

#DEFAULT TO DEV WITH NO RUN
TYPE="DEV"
RUN_BUILD="NO"

while getopts ":u:v:t:i:rh" opt; do
  case $opt in
    u) USERNAME="$OPTARG"
    ;;
    v) VERSION="$OPTARG"
    ;;
    i) IMAGE="$OPTARG"
    ;;
    r) RUN_BUILD="YES"
    ;;
    h) usage
       exit 0
    ;;
    \?) usage
        echo "An invalid option has been entered: $OPTARG"
        echo
        exit 1
    ;;
    :)  usage
        echo "The additional argument for option $OPTARG was omitted."
        echo
        exit 1
    ;;
  esac
done

#Check Mandatory Options
if [ "x" == "x$USERNAME" ]; then
  usage
  echo "-u docker username is required"
  echo
  exit 1
fi

if [ "x" == "x$IMAGE" ]; then
  usage
  echo "-i docker image name is required"
  echo
  exit 1
fi

if [ "x" == "x$VERSION" ]; then
  usage
  echo "-i version label is required"
  echo
  exit 1
fi



  docker build -t $USERNAME/$IMAGE:$VERSION  .

  if [ "$RUN_BUILD" == "YES" ] ; then
    docker run $USERNAME/$IMAGE:$VERSION
  fi



exit 0
