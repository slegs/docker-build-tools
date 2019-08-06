# Build tools for Dockerfile and git

* Automatic building of Dockerfile
* Pushes to Docker repository
* Updates Git source control
* Inclues versioning
* For Linux

## To install

```

 chmod +x install.sh
 ./install.sh

```
### drelease

What it does
* Up versions your version number (x.x.x) in VERSION file by major, minor or patch. Uses docker image treeder/bump
* Pulls, commits and pushes latest git changes and versions
* Builds Docker image and tags with versions for stable and dev versions. Depends on dbuild for buidling Docker image.
* Pushes Docker image to linked Docker repository mapping latest tag to latest stable or test tag to latest dev

```
Docker and Git Release tool for Docker Images

Usage: drelease [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version type - major, minor or patch (default)
  -s          indicates stable release. Labels Docker version tag as stable
              if not set then will label version as dev release
  -h          display help

```

### dbuild

What it does
* Builds Docker image and tags with version label passed in argument
* Optionally runs the built image in Docker

```
Docker and Git Build tool for Docker Images

Usage: dbuild [OPTION]...

  -u VALUE    Docker username (required)
  -i VALUE    Docker image name (required)
  -v VALUE    version label (required)
  -r          run the newly built image
  -h          display help


```
