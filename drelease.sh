#!/bin/bash

function usage {
	cat <<EOM

Docker and Git Release tool for Docker Images

Create symbolic links for
- drelease.sh to /usr/local/bin/drelease
- dbuild.sh to /usr/local/bin/dbuild

Call from build directory where your Dockerfile is located

What it does
1. Up versions your version number (x.x.x) in VERSION file by major, minor or patch. Uses docker image treeder/bump
2. Pulls, commits and pushes latest git changes and versions
3. Builds Docker image and tags with versions and stable for PROD versions and dev for DEV versions. Depends on dbuild.sh
4. Pushes Docker image to linked Docker repository mapping latest tag to latest stable or test to latest dev release

Usage: $(basename "$0") [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version type - major, minor or patch (default)
  -p          indicates production release. Labels Docker version tag as stable
              if not set then will label version as dev release
  -h          display help

EOM

}

#Show the current directory
echo "Docker Release Directory=$PWD"

#DEFAULT TO DEV
TYPE="DEV"
VERSION_TYPE="patch"


# GET OPTIONS
while getopts ":u:i:v:ph" opt; do
  case $opt in
    u) USERNAME="$OPTARG"
    ;;
    p) TYPE="PROD"
    ;;
    v) VERSION_TYPE="$OPTARG"
    ;;
    i) IMAGE="$OPTARG"
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


# ensure we're up to date
git pull

# bump version
docker run --rm -v "$PWD":/app treeder/bump $VERSION_TYPE

VERSION_NO=`cat VERSION`
echo "version: $VERSION_NO"

#Update Version Number in Readme and Dockerfile
if [ "$TYPE" == "PROD" ] ; then
	sed -i 's/LATEST_STABLE/stable-'"$VERSION_NO"'/g' README.md
	sed -i 's/LABEL_VERSION/stable-'"$VERSION_NO"'/g' Dockerfile
else
	sed -i 's/LATEST_DEV/dev-'"$VERSION_NO"'/g' README.md
	sed -i 's/LABEL_VERSION/dev-'"$VERSION_NO"'/g' Dockerfile
fi

# run build
dbuild -u $USERNAME -i $IMAGE -t $TYPE -v $VERSION_NO

if [ $? -eq 0 ]
then

	# tag it
	git add -A
	git commit -m "version $VERSION_NO"
	git tag -a "$VERSION_NO" -m "version $VERSION_NO"
	git push
	git push --tags


	# if PROD release then push stable and latest else dev
	if [ "$TYPE" == "PROD" ] ; then

		docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$VERSION_NO
		# push to docker repository
		docker push $USERNAME/$IMAGE:latest

    docker tag $USERNAME/$IMAGE:stable-$VERSION_NO $USERNAME/$IMAGE:$VERSION_NO
		# push to docker repository
    docker push $USERNAME/$IMAGE:stable-$VERSION_NO

	else
    docker tag $USERNAME/$IMAGE:test $USERNAME/$IMAGE:$VERSION_NO
		# push to docker repository
    docker push $USERNAME/$IMAGE:test

    docker tag $USERNAME/$IMAGE:dev-$VERSION_NO $USERNAME/$IMAGE:$VERSION_NO
		# push to docker repository
    docker push $USERNAME/$IMAGE:dev-$VERSION_NO

	fi

fi

exit 0
