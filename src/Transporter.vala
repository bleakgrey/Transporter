using Gtk;
using Granite;

public class MyApp : Granite.Application {

	public static MyApp instance;
	public TransporterWindow window;

	construct {
			application_id = "com.github.bleakgrey.transporter";
			flags = ApplicationFlags.FLAGS_NONE;
			program_name = "Transporter";
			build_version = "1.0";
	}

	public static int main (string[] args) {
		Gtk.init (ref args);
		instance = new MyApp();
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