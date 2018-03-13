public class SettingsView : Gtk.Grid {

    construct {
        var settings = TransporterSettings.get_default();
        column_spacing = 12;
        row_spacing = 6;
        margin = 6;

        attach (new Granite.HeaderLabel (_("Servers")), 0, 0, 2, 1);
        attach (new SettingsLabel (_("Relay:")), 0, 1, 1, 1);
        attach (new SettingsEntry ("server-relay"), 1, 1, 1, 1);
        attach (new SettingsLabel (_("Transit:")), 0, 3, 1, 1);
        attach (new SettingsEntry ("server-transit"), 1, 3, 1, 1);

        attach (new Granite.HeaderLabel (_("Miscellaneous")), 0, 4, 2, 1);
        attach (new SettingsLabel (_("ID Length:")), 0, 5, 1, 1);
        var words = new Gtk.SpinButton.with_range (2, 5, 1);
        settings.schema.bind ("words", words, "value", SettingsBindFlags.DEFAULT);
        attach (words, 1, 5, 1, 1);
        attach (new SettingsLabel (_("Sounds:")), 0, 6, 1, 1);
        attach (new SettingsSwitch ("ding"), 1, 6, 1, 1);

        show_all ();
    }

    public SettingsView(){}

    protected class SettingsLabel : Gtk.Label {
        public SettingsLabel (string text) {
            label = text;
            halign = Gtk.Align.END;
            margin_start = 12;
        }
    }

    protected class SettingsEntry : Gtk.Entry {
        public SettingsEntry (string setting) {
            hexpand = true;
            set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear");
            icon_press.connect ((pos, event) => {
                TransporterSettings.get_default().schema.reset(setting);
            });
            TransporterSettings.get_default().schema.bind (setting, this, "text", SettingsBindFlags.DEFAULT);
        }
    }

    protected class SettingsSwitch : Gtk.Switch {
        public SettingsSwitch (string setting) {
            halign = Gtk.Align.START;
            valign = Gtk.Align.CENTER;
            TransporterSettings.get_default().schema.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
        }
    }

}