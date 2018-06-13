# Transporter
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.bleakgrey.transporter)

Simple [magic-wormhole](https://github.com/warner/magic-wormhole) client designed for elementary OS.

![Transporter Screenshot](https://raw.githubusercontent.com/bleakgrey/transporter/master/data/screenshot.png)

## Building and Installation

You'll need some dependencies to build:
* libgranite-dev
* meson
* valac

And you'll need these to actually run [magic-wormhole](https://github.com/warner/magic-wormhole):
* build-essential
* libffi-dev
* libssl-dev
* python-pip
* python-dev
* zip


Run these commands to configure the build environment:

    meson build --prefix=/usr
    cd build

Finally, install and execute with:

    sudo ninja install
    com.github.bleakgrey.transporter

## Contributing

If you feel like contributing, you're always welcome to help the project in many ways:
* Reporting any issues
* Suggesting ideas and functionality
* Submitting pull requests
* Donating with [LiberaPay](https://liberapay.com/bleakgrey/) to help project development and keeping the developer happy

<a href="https://liberapay.com/bleakgrey/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

## Credits
* Lithuanian translation by <a href="https://github.com/welaq">@welaq</a>
* French and Italian translation by <a href="https://github.com/papou84">@papou84</a>
* Brazilian Portuguese translation by <a href="https://github.com/btd1337">@btd1337</a>
* German translation by <a href="https://github.com/p3732">@p3732</a>
