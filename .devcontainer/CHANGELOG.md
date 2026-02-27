# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- `plan` and `apply` functions to quickly run through the terraform workflow
- changelog uses Keep a Changelog standard

## 0.11.4
### Added
- latest azure-cli

## 0.11.3
### Fixed
- custom prompt wrapping due to non-printable characters

## 0.11.2
### Added
- add `ssh`
- ignore stderr and stdout during apt-get step
### Removed
- bashrc appends from postCreateCommand that are built into image

## 0.11.1
### Added
- path on bash prompt is relative to git work tree root when present working directory is in work tree

## 0.11.0
### Added
- azure-cli

### Changed
- changelog uses semver
- use debian based image instead of alpine

## 0.10.1
### Added
- `tf` alias for `tofu` binary
- opentofu automatic formatting on save settings
### Changed
- rename `tf` binary to `tofu` to allow opentofu extension to perform automatic formatting on save

## 0.10.0
### Changed
- rename `opentofu` binary to `tf`
### Removed
- `terraform` executable


## 0.9.0
### Added
- `openssl` package
- `opentofu` executable
- `opentofu` vscode extension
### Removed
- `terraform` vscode extension

## 0.8.0
### Added
- added `ack` package
### Changed
- switch from host filesystem bind mounts to named volumes for persistence

## 0.7.0
### Added
- added helm 3.18

## 0.6.0
### Changed
- kubectl now uses kubectl instead of k

## 0.5.0
### CHanged
- upgrade go to 1.24
- upgrade terraform to 1.12.2

## 0.4.0
### Added
- added kubectl 1.33
### Changed
- flyctl is now installed from github, no need for local instance of concourse
- upgraded flyctl to v0.3.145

## 0.3.2
### Fixed
- flyctl was not copied over correctly in previous versions

## 0.3.1
### Added
- concourse-ci flyctl
### Fixed
- golang directory is correctly copied to /usr/local/go/ instead of contents copied into /usr/local/

## 0.2.0
### Added
- go1.23.6 to image
### Changed
- rename terraform binary to tf
- terraform now uses amd64 architecture image instead of arm64
### Removed
- alias for tf

## 0.1.3
### Fixed
- tf (/usr/local/bin/terraform) alias

## 0.1.0
### Added
- terraform binary to /usr/local/bin
