public class WelcomeView : Gtk.Grid {

    MyApp app;

    construct {
        var welcome = new Granite.Widgets.Welcome (_("Welcome to Transporter"), _("What would you like to do?"));
        welcome.append ("document-export", _("Send Files"), _("Upload data to another computer"));
        welcome.append ("document-import", _("Receive Files"), _("Download data from another computer"));
        welcome.append ("folder", _("Show Downloads"), _("Open your Downloads folder"));
        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    var chooser = app.getFileChooser();
                    if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                        var file = chooser.get_filename();
                        var display = app.window.get_display ();
                        var clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);

                        app.addScreen(new SendView(app.wormhole, clipboard));
                        app.wormhole.send(file);
                    }
                    chooser.close ();
                    break;
                case 1:
                    app.addScreen(new ReceiveView(app.wormhole));
                    break;
                case 2:
                    AppInfo.launch_default_for_uri ("file://" + app.wormhole.downloads_path, null);
                    break;
            }
        });

        add (welcome);
        show_all ();
    }

    public WelcomeView(MyApp application){
        this.app = application;
    }

}