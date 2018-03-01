project('com.github.bleakgrey.transporter', 'vala', 'c')

i18n = import('i18n')

add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

executable(
    meson.project_name(),
    'src/Transporter.vala',
    'src/TransporterWindow.vala',
    'src/WormholeInterface.vala',
    'src/View/InstallView.vala',
    'src/View/ReceiveView.vala',
    'src/View/SendView.vala',
    'src/View/WelcomeView.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('granite')
    ],
    install: true
)

subdir('data')
subdir('po')