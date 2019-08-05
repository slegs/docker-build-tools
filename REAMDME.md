# Build tools for Dockerfile and git

* Automatic building of Dockerfile
* Pushes to Docker repository
* Updates Git source control
* Inclues versioning

###drelease.sh

```
Docker and Git Release tool for Docker Images by Paul Walsh

Create symbolic links for 
- drelease.sh to /usr/local/bin/drelease
- dbuild.sh to /usr/local/bin/dbuild

Call from build directory where your Dockerfile is located

What it does
1. Up versions your version number (x.x.x) in VERSION file by major, minor or patch. Uses docker image treeder/bump
2. Pulls, commits and pushes latest git changes and versions
3. Builds Docker image and tags with versions and stable for PROD versions and dev for DEV versions. Depends on dbuild.sh
4. Pushes Docker image to linked Docker repository mapping latest tag to latest stable or test to latest dev release

Usage: drelease [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version type - major, minor or patch (default)
  -p          indicates production release. Labels Docker version tag as stable
              if not set then will label version as dev release
  -h          display help


```

###dbuild.sh

```
Docker and Git Build tool for Docker Images by Paul Walsh

Create symbolic links for 
- drelease.sh to /usr/local/bin/drelease
- dbuild.sh to /usr/local/bin/dbuild   

Call from build directory where your Dockerfile is located

What it does
- Builds Docker image and tags with versions and stable for PROD versions and dev for DEV versions
- Optionally runs the built image in Docker

Usage: dbuild [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version number (required)
  -t VALUE    build type. 
              if set to PROD will create build with tag stable-x.x.x and latest
              else will assume DEV and create build with tag dev-x.x.x and test
  -r          runs the build in Docker
  -h          display help

```

