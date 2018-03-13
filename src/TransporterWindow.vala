using Gtk;

public class TransporterWindow: Gtk.Dialog {

	HeaderBar headerbar;
	Button back_button;
	Button settings_button;
	Spinner spinner;

	Widget current_screen;
	Widget[] screens;

	public WormholeInterface wormhole;

	public TransporterWindow (Gtk.Application application) {
	     Object (application: application,
	     icon_name: "com.github.bleakgrey.transporter",
	        title: "Transporter",
	        resizable: false
	    );
	    this.wormhole = new WormholeInterface ();
		this.window_position = WindowPosition.CENTER;
		this.set_titlebar (headerbar);

		wormhole.started.connect (() => spinner.show ());
		wormhole.closed.connect (() => spinner.hide ());
		wormhole.errored.connect ((err, title, critical) => {
			spinner.hide ();
			var view = new Granite.Widgets.AlertView (title, err, "dialog-warning");
			view.show_all ();

			if(critical)
				replaceScreen (view);
			else
				addScreen (view);
        });

		if(wormhole.bin_present ())
			addScreen (new WelcomeView (this));
		else
			addScreen (new InstallView (this, wormhole));
	} 

	construct{
		get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		get_content_area ().set_size_request (400, 400);

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

	private void update_header(){
		back_button.visible = !(current_screen is WelcomeView) && screens.length > 1;
		settings_button.visible = current_screen is WelcomeView;
	}

	public void addScreen(Widget screen){
		var box = get_content_area () as Gtk.Box;

		if(screens.length > 0 && current_screen != null)
			box.remove (current_screen);

		screens += screen;
		current_screen = screen;
		box.add (current_screen);
		current_screen.show ();
		update_header ();
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
			popScreen ();
		}

	}

	private void popScreen(){
		if(screens.length <= 1)
			return;
		var box = get_content_area () as Gtk.Box;

		box.remove (current_screen);
		screens.resize (screens.length - 1);
		current_screen = screens[screens.length - 1];
		box.add (current_screen);
		current_screen.show ();
		update_header ();
	}

	public void replaceScreen(Widget screen){
		var box = get_content_area () as Gtk.Box;

		box.remove (current_screen);
		current_screen = null;
		screens = {};
		addScreen (screen);
	}

}