# Transporter

Simple [magic-wormhole](https://github.com/warner/magic-wormhole) client designed for elementary OS.

![Transporter Screenshot](https://raw.githubusercontent.com/bleakgrey/transporter/master/data/screenshot.png)

## Building and Installation

You'll need some dependencies to build:
* libgranite-dev
* meson
* valac

And you'll need these to actually run [magic-wormhole](https://github.com/warner/magic-wormhole):
* build-essential
* python-pip
* python-dev
* libffi-dev
* libssl-dev


Run these commands to configure the build environment:

    meson build --prefix=/usr
    cd build

Finally, install and execute with:

    sudo ninja install
    com.github.bleakgrey.transporter
