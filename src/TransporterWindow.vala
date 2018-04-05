using Gtk;

public class TransporterWindow: Gtk.Dialog {

	HeaderBar headerbar;
	Button back_button;
	Button settings_button;
	Spinner spinner;
	Stack stack;
	AbstractView current_screen = null;

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
			var view = new ErrorView (this, title, err);

			if(critical)
				replace (view);
			else
				append (view);
        });

		if(wormhole.bin_present ())
			append (new WelcomeView (this));
		else
			append (new InstallView (this));
	} 

	construct{
		get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		get_content_area ().set_size_request (400, 400);

		stack = new Stack();
		stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
		stack.show ();

		spinner = new Spinner ();
		spinner.active = true;

		back_button = new Button.with_label (_("Back"));
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
        back_button.clicked.connect (() => back ());

        settings_button = new Button ();
        settings_button.tooltip_text = _("Settings");
        settings_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        settings_button.clicked.connect (() => append (new SettingsView (this)));

		headerbar = new HeaderBar ();
		headerbar.set_show_close_button (true);
		headerbar.title = "Transporter";
		headerbar.pack_end (settings_button);
		headerbar.pack_end (spinner);
		headerbar.pack_start (back_button);
		headerbar.show ();

		get_content_area ().add (stack);
	}

	private void update_header(){
		back_button.visible = !(current_screen is WelcomeView) && stack.get_children ().length() > 1;
		settings_button.visible = current_screen is WelcomeView;
	}

	public void back(){
		if(wormhole.is_running()){
			Gtk.MessageDialog msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.YES_NO,
				_("Are you sure you want to cancel transaction?"));
			msg.response.connect ((response_id) => {
				switch (response_id) {
					case Gtk.ResponseType.YES:
						wormhole.close ();
						pop ();
						break;
					default:
						break;
				}
				msg.destroy();
			});
			msg.show ();
		}
		else{
			pop ();
		}

	}

	public void append(AbstractView screen){
		screen.previous_child = current_screen;
		current_screen = screen;
		stack.add (current_screen);
		stack.set_visible_child (current_screen);

		update_header ();
	}

	private void pop(){
		if(current_screen.previous_child == null)
			return;

		stack.set_visible_child (current_screen.previous_child);
		stack.remove (current_screen);
		var _view = current_screen.previous_child;
		current_screen.destroy ();
		current_screen = _view;
		update_header ();
	}

	public void replace(AbstractView screen){
		stack.forall(view => pop ());
		append (screen);
	}

}