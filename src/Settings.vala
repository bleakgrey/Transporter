public class TransporterSettings : Granite.Services.Settings {

    private static TransporterSettings? instance;
    public string server_relay { get; set; }
    public string server_transit { get; set; }
    public string downloads { get; set; }
    public bool ding { get; set; }
    public int words { get; set; }
    
    public string get_downloads_folder () {
        if (downloads == "null")
            return GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD);
        else
            return downloads;
    }
    
    public static unowned TransporterSettings get_default () {
        if (instance == null) {
            instance = new TransporterSettings ();
            instance.downloads = instance.get_downloads_folder ();
        }
        return instance;
    }

    private TransporterSettings () {
        base ("com.github.bleakgrey.transporter");
    }

}
