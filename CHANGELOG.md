# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project **does not** follow [Semantic Versioning](https://semver.org/) at the moment.

## [Unreleased 0.5] - 2019-MM-DD

### NOT ADDED BY MAKEWORLD
- Yggdrasil IPTunnel changes
  - I added some but not all
  - Some are not merged yet, and I am unsure what they are exactly anyway

### Added
- Stack can run without CJDNS installed
- [MODULES.md](./docs/MODULES.md) file added
  - Many module instructions and documentation have been added there
- Support for generic `amd64` or `i386`, as well as other ARM boards in all relevant modules
- Grafana database can be saved on uninstall
- IPFS configuration to use less resources  - `Swarm.ConnMgr.LowWater/HighWater/GracePeriod`
- IPFS configuration to enable QUIC
- Hostname can be changed with the installation of Yggdrasil or CJDNS
- Yggdrasil IPTunnel supports IPv6 and routed IPv6
- Yggdrasil IPtunnel drop in service adjustment - **EXPAND ON THIS**

### Changed
- Grafana version 5.1.4 -> 6.0.0
- CJDNS is now a module
- NodeJS is now a module, as several modules need it installed it - **NOT MERGED YET** #381
- NetworkManager is now removed, it was never used
- IPFS version 0.4.19 -> 0.4.20
- IPFS peering will now try and use QUIC if it's available on the node being connected to
- Prometheus Node Exporter version 0.14.0 -> 0.17.0
- Prometheus Server version 2.0.0-alpha.3 -> 2.7.2
- Yggdrasil version 0.3.3 -> 0.3.5
- Yggdrasil IPTunnel now does not change config files
- TUI profile selection changed to a menu type instead of radio buttons

### Fixed
- User is instructed to install `sudo` if it's not installed
- Passwordless sudo now works on Armbian
- Choosing the Yggdrasil IPTunnel module now actually installs it
- Prometheus Node Exporter now uses the correct `collector.textfile.directory`
- Yggdrasil IP addresses will no longer be seen as Internet addresses

---

Versions prior to v0.5 were neither formatted in this style or originally added to this file. A rough changelog for those releases can be found on the [Github Releases page](https://github.com/tomeshnet/prototype-cjdns-pi/releases) for this repo.