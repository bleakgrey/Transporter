public class Transport.Settings : Granite.Services.Settings {

        private static Settings? instance;
        public string server_relay { get; set; }
        public string server_transit { get; set; }
        public bool ding { get; set; }

        public static unowned Settings get_default () {
            if (instance == null) {
                instance = new Settings ();
            }
            return instance;
        }

        private Settings () {
            base ("com.github.bleakgrey.transporter");
        }

}