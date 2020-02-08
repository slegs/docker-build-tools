#!/bin/bash

function usage {
        cat <<EOM

Docker and Git Build tool for Docker Images

Usage: $(basename "$0") [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version label (required)
  -r          run the newly built image
  -e          test envrionment variables as one string
  -h          display help

EOM

}


#Show the current directory
echo "Docker Build Directory=$PWD"

#DEFAULT TO DEV WITH NO RUN
TYPE="DEV"
RUN_BUILD="NO"

while getopts ":u:v:t:i:e:rh" opt; do
  case $opt in
    u) USERNAME="$OPTARG"
    ;;
    v) VERSION="$OPTARG"
    ;;
    i) IMAGE="$OPTARG"
    ;;
    e) ENVIRON="$OPTARG"
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
    if [ "x" == "x$ENVIRON" ]; then
      docker run $USERNAME/$IMAGE:$VERSION
    else
      echo "docker run $USERNAME/$IMAGE:$VERSION -e $ENVIRON"
      docker run $USERNAME/$IMAGE:$VERSION -e $ENVIRON
    fi
  fi



exit 0
