project('com.github.bleakgrey.transporter', 'vala', 'c')

i18n = import('i18n')

add_global_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

executable(
    meson.project_name(),
    'src/Transporter.vala',
    'src/TransporterWindow.vala',
    'src/Settings.vala',
    'src/WormholeInterface.vala',
    'src/View/InstallView.vala',
    'src/View/ReceiveView.vala',
    'src/View/SendView.vala',
    'src/View/WelcomeView.vala',
    'src/View/SettingsView.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('glib-2.0', version: '>=2.30.0')
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')