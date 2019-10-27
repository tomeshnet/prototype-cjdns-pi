# NoDogSplash captive portal

Source: https://github.com/nodogsplash/nodogsplash

Nodogsplash is a Captive Portal that offers a simple way to provide restricted access to the Internet by showing a splash page to the user before Internet access is granted.

This script install and configured the Nodogsplash captive portal to run on `wlan-ap` interface of the prototype stack.

## Installation

```
chmod +x install-nodogsplash.sh
./install-nodogsplash.sh
```

## Issues

Some people have objections using captive portal because it hijacks traffic and could potentially be a privacy violation. Additionally it prevents headless devices from accessing the internet.

## Nice to have

- [ ] Nice tomesh splash screen (/etc/nodogsplash/htdocs/splash.sh)
