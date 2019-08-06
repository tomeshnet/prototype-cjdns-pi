# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project **does not** follow [Semantic Versioning](https://semver.org/) at the moment.

## [Unreleased 0.5] - 2019-MM-DD
### Added
- Stack can run without CJDNS installed
- [MODULES.md](./docs/MODULES.md) file was updated
  - Table of Contents
  - CJDNS Internet peering instructions
  - Yggdrasil Internet peering instructions
  - Yggdrasil IPTunnel instructions
  - Grafana instructions
  - Prometheus instructions
  - Scuttlebutt explanation
  - Scuttlebutt Internet pub peering instructions
- Support for generic `amd64` or `i386` was added, as well as other ARM boards
  - All relevant modules now download different binaries depending on the hardware
- Grafana database can be saved on uninstall
- IPFS configuration uses less resources  - Changed `Swarm.ConnMgr.LowWater/HighWater/GracePeriod`
- IPFS configuration has QUIC enabled
- Hostname can be changed with the installation of Yggdrasil or CJDNS
- Yggdrasil IPTunnel supports IPv6 and routed IPv6
- Yggdrasil IPtunnel drop in service adjustment - **EXPAND ON THIS**
- There is now a `confset` command used to set INI-like files - view the command [here](https://github.com/tomeshnet/prototype-cjdns-pi/blob/43b6fc62e2bbc07594e07c56fdba8dc345163d61/scripts/shared/confset/confset.sh)
- The GeoLocation contrib module was added, which will insert the longitude, latitude and accuracy of the node's location into `nodeinfo.json`
- The installation process now has a module (`extra-tools-netcat`) for `netcat`, giving the user an option to install `netcat-openbsd` over any other versions of `netcat`, since the BSD rewrite supports IPv6
- The [TROUBLESHOOT.md](./docs/TROUBLESHOOT.md) file has been created, with information on on wireless meshing and CJDNS or Yggdrasil IPTunnel-ing
- The `/etc/mesh.conf` file as been added, as an INI style configuration file. It contains variables such `mesh-name` and `frequency`, which modules now use instead of just assuming the values
- The stack will now run on Raspbian/Debian Buster, the latest stable version at the time of release.

### Changed
- Grafana version 5.1.4 -> 6.0.0
- CJDNS is now a module
- NodeJS is now a module, as several modules need it installed
- NodeJS version 8.x -> 10.x
  - The latest LTS
- NetworkManager is now removed, it was never used
- IPFS version 0.4.19 -> 0.4.20
- IPFS peering will now try and use QUIC if it's available on the node being connected to
- Prometheus Node Exporter version 0.14.0 -> 0.17.0
- Prometheus Server version 2.0.0-alpha.3 -> 2.7.2
- Yggdrasil version 0.3.3 -> 0.3.5
- Yggdrasil IPTunnel now does not change config files
- TUI profile selection changed to a menu type instead of radio buttons
- The Pine64 Armbian link in the hardware table has been fixed to the correct one
- The IBSS device first checked from the `mesh.conf` file, then a search of the interfaces available is used. Previously it was just always `wlan0` that was tried.

### Fixed
- User is instructed to install `sudo` if it's not installed
- Passwordless sudo now works on Armbian
- Choosing the Yggdrasil IPTunnel module now actually installs it
- Prometheus Node Exporter now uses the correct `collector.textfile.directory`
- Yggdrasil IP addresses will no longer be seen as Internet addresses by the node's routing
- The IPFS module will now still install even if there is already a `.ipfs` directory for that user

---

Versions prior to v0.5 were not included in this file, and were not formatted according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). A rough changelog for those releases can be found on the [Github releases page](https://github.com/tomeshnet/prototype-cjdns-pi/releases) for this repo.
