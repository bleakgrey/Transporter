using Gtk;

public class TransporterWindow: Gtk.Dialog {

	HeaderBar headerbar;
	Button back_button;
	Button settings_button;
	Spinner spinner;

	Widget currScreen;
	Widget[] screens;

	public WormholeInterface wormhole;

	public TransporterWindow (Gtk.Application application) {
	     Object (application: application,
	     icon_name: "com.github.bleakgrey.transporter",
	        title: "Transporter",
	        resizable: false,
	        width_request: 470,
	        height_request: 470
	    );
	    this.wormhole = new WormholeInterface();
		this.window_position = WindowPosition.CENTER;
		this.set_titlebar (headerbar);

		wormhole.started.connect(() => spinner.show ());
		wormhole.closed.connect(() => spinner.hide ());
		wormhole.errored.connect((err, title, critical) => {
			spinner.hide();
			var view = new Granite.Widgets.AlertView (title, err, "dialog-warning");
			view.show_all();

			if(critical)
				replaceScreen(view);
			else
				addScreen(view);
        });

		if(wormhole.bin_present ())
			addScreen(new WelcomeView (this));
		else
			addScreen(new InstallView (this, wormhole));
	} 

	construct{
		get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

		spinner = new Gtk.Spinner ();
		spinner.active = true;

		back_button = new Button.with_label (_("Back"));
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
        back_button.clicked.connect (() => prevScreen ());

        settings_button = new Button ();
        settings_button.tooltip_text = _("Settings");
        settings_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        settings_button.clicked.connect (() => addScreen (new SettingsView ()));

		headerbar = new HeaderBar ();
		headerbar.set_show_close_button (true);
		headerbar.title = "Transporter";
		headerbar.pack_end (settings_button);
		headerbar.pack_end (spinner);
		headerbar.pack_start (back_button);
		headerbar.show ();
	}

	private void updateWindow(){
		back_button.visible = !(currScreen is WelcomeView) && screens.length > 1;
		settings_button.visible = currScreen is WelcomeView;
	}

	public void addScreen(Widget screen){
		var box = get_content_area () as Gtk.Box;

		if(screens.length > 0 && currScreen != null)
			box.remove (currScreen);

		screens += screen;
		currScreen = screen;
		box.add (currScreen);
		currScreen.show ();
		updateWindow ();
	}

	public void prevScreen(){
		if(wormhole.is_running()){
			Gtk.MessageDialog msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.YES_NO,
				_("Are you sure you want to cancel transaction?"));
			msg.response.connect ((response_id) => {
				switch (response_id) {
					case Gtk.ResponseType.YES:
						wormhole.close ();
						popScreen ();
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
		if(screens.length <= 1)
			return;
		var box = get_content_area () as Gtk.Box;

		box.remove (currScreen);
		screens.resize (screens.length - 1);
		currScreen = screens[screens.length - 1];
		box.add (currScreen);
		currScreen.show ();
		updateWindow ();
	}

	public void replaceScreen(Widget screen){
		var box = get_content_area () as Gtk.Box;

		box.remove (currScreen);
		currScreen = null;
		screens = {};
		addScreen (screen);
	}

	public Gtk.FileChooserDialog getFileChooser(){
		return new Gtk.FileChooserDialog (
			_("Select files or a folder to send"),
			this,
			Gtk.FileChooserAction.OPEN,
			_("_Cancel"),
			Gtk.ResponseType.CANCEL,
			_("_Open"),
			Gtk.ResponseType.ACCEPT
		);
	}

}