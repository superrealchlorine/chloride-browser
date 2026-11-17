# WARNING

The renderer (viewer) used by this extension is still experimental and currently supports only Chloride applications that output framebuffers. Please use the native client "rion" for full functionality while this client is updated.

# chloride-browser

A Manifest V3 browser extension and native messaging runtime for rendering Chloride Protocol WebAssembly applications on an HTML5 canvas. For now only Firefox and Firefox-based browsers are supported.

## Structure

- `manifest.json`: WebExtension Manifest V3 configuration.
- `viewer.html`: Canvas container and extension frontend.
- `viewer.css`: Layout and canvas styling.
- `viewer.js`: Dynamic Wasm instantiator and framebuffer renderer.
- `chloride-host.py`: Python native messaging host handling raw TCP stream socket connections to riond.
- `com.superrealchlorine.chloride_host.json`: Native messaging host manifest.
- `install.sh`: Interactive installation script for Firefox, LibreWolf, and derivatives.

## Installing the extension on Firefox

It's available here:
https://addons.mozilla.org/en-US/firefox/addon/chloride-browser-extension/

For full functionality, you'll need to install the helper script.

## Installing the helper script

1. Clone this repository with git: `git clone https://github.com/superrealchlorine/chloride-browser.git`

2. Enter the directory: `cd chloride-browser`

3. Run the native host installer: `./install.sh`

You're done!

## Usage

You should now be able toe use the Chloride URI easily as well as load Chloride applications! For example ext+chloride://chloride.chlorine.me/ should load perfectly fine.

You can also navigate to the extension protocol handler and open the viewer tab directly:

example: `moz-extension://<internal-uuid>/viewer.html?target=chloride.chlorine.me:49130`

