Local development environment packaged into a container.

## To Do
- add checksum checks for all tools

## Changelog
### 10.1
- rename `tf` binary to `tofu` to allow opentofu extension to perform automatic formatting on save
- add `tf` alias for `tofu` binary
- add opentofu automatic formatting on save settings
### 10.0
- remove `terraform`
- rename `opentofu` binary to `tf`
### 9.0
- added `openssl` package
- added `opentofu`
- added `opentofu` vscode extension
- remove `terraform` vscode extension
### 8.0
- switch from host filesystem bind mounts to named volumes for persistence
- added `ack` package
### 7.0
- added helm 3.18
### 6.0
- kubectl now uses kubectl instead of k
### 5.0
- upgrade go to 1.24
- upgrade terraform to 1.12.2
### 4.0
- flyctl is now installed from github, no need for local instance of concourse
- added kubectl 1.33
- upgraded flyctl to v0.3.145
### 3.2
- fly CLI was not copied over correctly in previous versions
### 3.1
- add concourse-ci fly CLI
- golang directory is correctly copied to /usr/local/go/ instead of contents copied into /usr/local/
### 2.0
- remove alias for tf
- rename terraform binary to tf
- terraform now uses amd64 architecture image instead of arm64
    - terraform was slow before. this should fix it
- add go1.23.6 to image
### 1.3
- fix tf (/usr/local/bin/terraform) alias
### 1.0
- add terraform binary to /usr/local/bin
