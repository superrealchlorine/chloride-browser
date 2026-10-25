# chloride-browser

A Manifest V3 browser extension and native messaging runtime for rendering Chloride Protocol WebAssembly applications on an HTML5 canvas. For now only Firefox and Firefox-based browsers are accepted.

## Structure

- `manifest.json`: WebExtension Manifest V3 configuration.
- `viewer.html`: Canvas container and extension frontend.
- `viewer.css`: Layout and canvas styling.
- `viewer.js`: Dynamic Wasm instantiator and framebuffer renderer.
- `chloride-host.py`: Python native messaging host handling raw TCP stream socket connections to riond.
- `com.superrealchlorine.chloride_host.json`: Native messaging host manifest.
- `install.sh`: Interactive installation script for Firefox, LibreWolf, and derivatives.

## Installation

1. Run the native host installer:

   ./install.sh

2. Open `about:debugging#/runtime/this-firefox` in Firefox or LibreWolf.

3. Click **Load Temporary Add-on...** and select `manifest.json`.

## Usage

Navigate to a Chloride URI via the extension protocol handler or by opening the viewer tab directly:

example: `moz-extension://<internal-uuid>/viewer.html?target=chloride.chlorine.me:49130`

