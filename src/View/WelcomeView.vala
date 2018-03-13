public class WelcomeView : Gtk.Grid {

    TransporterWindow window;

    construct {
        var welcome = new Granite.Widgets.Welcome (_("Welcome to Transporter"), _("What would you like to do?"));
        welcome.append ("document-export", _("Send Files"), _("Upload data to another computer"));
        welcome.append ("document-import", _("Receive Files"), _("Download data from another computer"));
        welcome.append ("folder", _("Show Downloads"), _("Open your Downloads folder"));
        welcome.activated.connect ((index) => {
            switch (index) {
                case 0:
                    // var file = chooser.get_filename ();
                    // var display = window.get_display ();
                    // var clipboard = Gtk.Clipboard.get_for_display (display, Gdk.SELECTION_CLIPBOARD);
                    window.addScreen (new DropView (window.wormhole));
                    //window.wormhole.send (file);
                    break;
                case 1:
                    window.addScreen (new ReceiveView (window.wormhole));
                    break;
                case 2:
                    try{
                        AppInfo.launch_default_for_uri ("file://" + window.wormhole.downloads_path, null);
                    }
                    catch(GLib.Error e){
                        warning(e.message);
                    }
                    break;
            }
        });
        welcome.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
        welcome.margin = 16;
        
        add (welcome);
        show_all ();
    }

    public WelcomeView(TransporterWindow window){
        this.window = window;
    }

}