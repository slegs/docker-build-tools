#!/bin/bash

function usage {
        cat <<EOM

Docker and Git Build tool for Docker Images by Paul Walsh

Create symbolic links for 
- drelease.sh to /usr/local/bin/drelease
- dbuild.sh to /usr/local/bin/dbuild   

Call from build directory where your Dockerfile is located

What it does
- Builds Docker image and tags with versions and stable for PROD versions and dev for DEV versions
- Optionally runs the built image in Docker

Usage: $(basename "$0") [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version number (required)
  -t VALUE    build type. 
              if set to PROD will create build with tag stable-x.x.x and latest
              else will assume DEV and create build with tag dev-x.x.x and test
  -r          runs the build in Docker
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
    t) TYPE="$OPTARG"
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
  echo "-i docker version is required"
  echo
  exit 1
fi


if [ "$TYPE" == "PROD" ] ; then

	docker build -t $USERNAME/$IMAGE:stable-$VERSION -t $USERNAME/$IMAGE:latest .

	if [ "$RUN_BUILD" == "YES" ] ; then
        	docker run $USERNAME/$IMAGE:stable-$VERSION 
	fi

else

        docker build -t $USERNAME/$IMAGE:dev-$VERSION  -t $USERNAME/$IMAGE:test .
        if [ "$RUN_BUILD" == "YES" ] ; then
	        docker run $USERNAME/$IMAGE:dev-$VERSION
	fi

fi

exit 0
