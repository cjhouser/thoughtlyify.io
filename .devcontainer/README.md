Local development environment packaged into a container.

## To Do
- Add checksum checks for all tools

## Changelog
### 6.0
- kubectl now uses kubectl instead of k
### 5.0
- Upgrade go to 1.24
- Upgrade terraform to 1.12.2
### 4.0
- flyctl is now installed from github, no need for local instance of concourse
- added kubectl 1.33
- upgraded flyctl to v0.3.145
### 3.2
- fly CLI was not copied over correctly in previous versions
### 3.1
- Add concourse-ci fly CLI
- golang directory is correctly copied to /usr/local/go/ instead of contents copied into /usr/local/
### 2.0
- Remove alias for tf
- Rename terraform binary to tf
- terraform now uses amd64 architecture image instead of arm64
    - terraform was slow before. this should fix it
- Add go1.23.6 to image
### 1.3
- fix tf (/usr/local/bin/terraform) alias
### 1.0
- add terraform binary to /usr/local/bin
