# Transporter

Simple [magic-wormhole](https://github.com/warner/magic-wormhole) client designed for elementary OS.

![Transporter Screenshot](https://raw.githubusercontent.com/bleakgrey/transporter/master/data/screenshot.png)

## Building and Installation

You'll need some dependencies to build:
* gtk+-3.0
* granite
* meson
* valac

And you'll need these to actually run [magic-wormhole](https://github.com/warner/magic-wormhole):
* python-pip
* build-essential
* python-dev
* libffi-dev
* libssl-dev


Run these commands to configure the build environment and run some tests:

    meson build --prefix=/usr
    cd build
    ninja test

Finally, install and execute with:

    sudo ninja install
    com.github.bleakgrey.transporter
