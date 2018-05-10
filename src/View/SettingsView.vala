public class SettingsView : AbstractView {

    construct {
        var settings = TransporterSettings.get_default();
        column_spacing = 12;
        row_spacing = 6;
        margin = 6;

        attach (new Granite.HeaderLabel (_("Servers")), 0, 1, 2, 1);
        attach (new SettingsLabel (_("Relay:")), 0, 2);
        attach (new SettingsEntry ("server-relay"), 1, 2);
        attach (new SettingsLabel (_("Transit:")), 0, 3);
        attach (new SettingsEntry ("server-transit"), 1, 3);

        attach (new Granite.HeaderLabel (_("Miscellaneous")), 0, 4, 2, 1);
        attach (new SettingsLabel (_("Downloads:")), 0, 5);
        attach (new SettingsEntry ("downloads"), 1, 5);
        attach (new SettingsLabel (_("ID Length:")), 0, 6);
        var words = new Gtk.SpinButton.with_range (2, 5, 1);
        settings.schema.bind ("words", words, "value", SettingsBindFlags.DEFAULT);
        attach (words, 1, 6);
        attach (new SettingsLabel (_("Sounds:")), 0, 7);
        attach (new SettingsSwitch ("ding"), 1, 7);

        show_all ();
    }

    public SettingsView(TransporterWindow window){
        base (window);
    }

    protected class SettingsLabel : Gtk.Label {
        public SettingsLabel (string text) {
            label = text;
            halign = Gtk.Align.END;
            margin_start = 12;
        }
    }

    protected class SettingsEntry : Gtk.Entry {
        public SettingsEntry (string setting) {
            var settings = TransporterSettings.get_default();
            var is_downloads = setting == "downloads";
            var icon = is_downloads ? "document-open-symbolic" : "edit-clear-symbolic";
            
            hexpand = true;
            editable = !is_downloads;
            set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, icon);
            icon_press.connect ((pos, event) => {
                if (is_downloads) {
                    var path = choose_folder ();
                    settings.downloads = path;
                    settings.downloads = settings.get_downloads_folder ();
                }
                else {
                    settings.schema.reset(setting);
                }
            });
            settings.schema.bind (setting, this, "text", SettingsBindFlags.DEFAULT);
        }
    }

    protected class SettingsSwitch : Gtk.Switch {
        public SettingsSwitch (string setting) {
            halign = Gtk.Align.START;
            valign = Gtk.Align.CENTER;
            TransporterSettings.get_default().schema.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
        }
    }
    
    protected static string choose_folder () {
        var chooser =  new Gtk.FileChooserDialog (
                _("Select a folder"),
                null,
                Gtk.FileChooserAction.SELECT_FOLDER,
                _("_Cancel"),
                Gtk.ResponseType.CANCEL,
                _("_Select"),
                Gtk.ResponseType.ACCEPT);
         
         string result = "null";
         if (chooser.run () == Gtk.ResponseType.ACCEPT)
            result = chooser.get_uri ().replace ("file://", "");
         chooser.close ();
         return result;
    }

}
