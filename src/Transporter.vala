using Gtk;
using Granite;

public class Transporter : Granite.Application {

	public static Transporter instance;
	public TransporterWindow window;

	construct {
			application_id = "com.github.bleakgrey.transporter";
			flags = ApplicationFlags.FLAGS_NONE;
			program_name = "Transporter";
			build_version = "1.2.0";
	}

	public static int main (string[] args) {
		Gtk.init (ref args);
		instance = new Transporter();
		return instance.run (args);
	}

	protected override void startup () {
		base.startup();
		Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
		window = new TransporterWindow (this);
	}

	protected override void shutdown () {
		window.wormhole.close();
		base.shutdown();
	}

	protected override void activate () {
		window.present (); 
	}

}