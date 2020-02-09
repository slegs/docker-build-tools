#!/bin/bash

function usage {
	cat <<EOM

Docker and Git Release tool for Docker Images

Usage: $(basename "$0") [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version type - major, minor or patch (default)
  -s          indicates stable release. Labels Docker version tag as stable
              if not set then will label version as dev release
  -h          display help

EOM

}

#Show the current directory
echo "Docker Release Directory=$PWD"

#DEFAULT TO DEV
TYPE="dev"
VERSION_TYPE="patch"


# GET OPTIONS
while getopts ":u:i:v:sh" opt; do
  case $opt in
    u) USERNAME="$OPTARG"
    ;;
    s) TYPE="stable"
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
FULL_VERSION_LABEL="${TYPE}-${VERSION_NO}"
echo "version: $FULL_VERSION_LABEL"

#Update Version Numbers in Readme
if [ "$TYPE" == "stable" ] ; then
	#Updated latest label
	sed -i 's/:latest is.*/:latest is '"${FULL_VERSION_LABEL}"'/g' README.md
fi
#Test is always latest build
sed -i 's/:test is.*/:test is '"${FULL_VERSION_LABEL}"'/g' README.md

# run build
dbuild -u $USERNAME -i $IMAGE -t $TYPE -v $FULL_VERSION_LABEL

if [ $? -eq 0 ]
then

	# tag it
	git add -A
	git commit -m "version $FULL_VERSION_LABEL"
	git tag -a "$FULL_VERSION_LABEL" -m "version $FULL_VERSION_LABEL"
	git push
	git push --tags

	docker push $USERNAME/$IMAGE:$FULL_VERSION_LABEL

	# if stable type then push stable also to latest
	if [ "$TYPE" == "stable" ] ; then

		docker tag $USERNAME/$IMAGE:$FULL_VERSION_LABEL $USERNAME/$IMAGE:latest
		# push to docker repository
		docker push $USERNAME/$IMAGE:latest

	fi

	# Always push to test
  docker tag $USERNAME/$IMAGE:$FULL_VERSION_LABEL $USERNAME/$IMAGE:test
	# push to docker repository
  docker push $USERNAME/$IMAGE:test


fi

exit 0
