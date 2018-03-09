public class TransporterSettings : Granite.Services.Settings {

        private static TransporterSettings? instance;
        public string server_relay { get; set; }
        public string server_transit { get; set; }
        public bool ding { get; set; }
        public int words { get; set; }

        public static unowned TransporterSettings get_default () {
            if (instance == null) {
                instance = new TransporterSettings ();
            }
            return instance;
        }

        private TransporterSettings () {
            base ("com.github.bleakgrey.transporter");
        }

}