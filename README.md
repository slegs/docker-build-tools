# Build tools for Dockerfile and git

* Automatic building of Dockerfile
* Pushes to Docker repository
* Updates Git source control
* Inclues versioning

### drelease.sh

```
Docker and Git Release tool for Docker Images

Create symbolic links for
- drelease.sh to /usr/local/bin/drelease
- dbuild.sh to /usr/local/bin/dbuild

Call from build directory where your Dockerfile is located

What it does
1. Up versions your version number (x.x.x) in VERSION file by major, minor or patch. Uses docker image treeder/bump
2. Pulls, commits and pushes latest git changes and versions
3. Builds Docker image and tags with versions for stable and dev versions. Depends on dbuild.sh
4. Pushes Docker image to linked Docker repository mapping latest tag to latest stable or test to latest dev release

Usage: drelease [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version type - major, minor or patch (default)
  -s          indicates stable release. Labels Docker version tag as stable
              if not set then will label version as dev release
  -h          display help

```

### dbuild.sh

```
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


```
