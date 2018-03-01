using Gtk;
using Granite;

public class MyApp : Granite.Application {

	public static MyApp instance;
	public ApplicationWindow window;

	HeaderBar headerbar;
	Button back_button;
	Spinner spinner;

	Widget currScreen;
	Widget[] screens;

	public WormholeInterface wormhole;

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
		wormhole = new WormholeInterface();
		shutdown.connect(() => wormhole.close());

		spinner = new Gtk.Spinner ();
		spinner.active = true;

		back_button = new Button.with_label (_("Back"));
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
        back_button.clicked.connect(() => prevScreen());

		headerbar = new HeaderBar();
		headerbar.set_show_close_button(true);
		headerbar.title = program_name;
		headerbar.pack_end(spinner);
		headerbar.pack_start(back_button);
		headerbar.show();

		window = new ApplicationWindow (this);
		window.title = program_name;
		window.window_position = WindowPosition.CENTER;
		window.set_default_size (470, 400);
		window.set_resizable(false);
		window.set_titlebar(headerbar);

		wormhole.started.connect(() => spinner.show());
		wormhole.closed.connect(() => spinner.hide());

		wormhole.errored.connect((err) => {
			spinner.hide();
            Gtk.MessageDialog msg = new Gtk.MessageDialog (window, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.CANCEL, err);
			msg.response.connect ((response_id) => {
				switch (response_id) {
					default:
					case Gtk.ResponseType.CANCEL:
						break;
				}
				msg.destroy();
			});
			msg.show ();
        });

        if(wormhole.bin_present())
			addScreen(new WelcomeView (this));
		else
			addScreen(new InstallView (instance, wormhole));

	}

	protected override void activate () {
		window.present(); 
	}

	public void addScreen(Widget screen){
		if(screens.length > 0)
			window.remove(currScreen);

		screens += screen;
		currScreen = screen;
		window.add(currScreen);
		currScreen.show();

		back_button.visible = !(currScreen is WelcomeView) && screens.length > 1;
	}

	public void prevScreen(){
		if(screens.length <= 1)
			return;

		if(wormhole.is_running()){
			Gtk.MessageDialog msg = new Gtk.MessageDialog (window, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.YES_NO,
				_("Are you sure you want to cancel transaction?"));
			msg.response.connect ((response_id) => {
				switch (response_id) {
					case Gtk.ResponseType.YES:
						wormhole.close();
						popScreen();
						break;
					default:
						break;
				}
				msg.destroy();
			});
			msg.show ();
		}
		else{
			popScreen();
		}

	}

	private void popScreen(){
		window.remove(currScreen);
		screens.resize(screens.length - 1);
		currScreen = screens[screens.length - 1];
		window.add(currScreen);
		currScreen.show();

		back_button.visible = !(currScreen is WelcomeView) && screens.length > 2;
	}

	public Gtk.FileChooserDialog getFileChooser(){
		return new Gtk.FileChooserDialog (
			_("Select files or a folder to send"),
			window,
			Gtk.FileChooserAction.OPEN,
			_("_Cancel"),
			Gtk.ResponseType.CANCEL,
			_("_Open"),
			Gtk.ResponseType.ACCEPT
		);
	}

}