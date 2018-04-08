using Gtk;

public class TransporterWindow: Gtk.Dialog {

    HeaderBar headerbar;
    Button back_button;
    Button settings_button;
    Spinner spinner;
    Stack stack;
    AbstractView? current_screen = null;

    public WormholeInterface wormhole;

    private const string STYLE = """
    @define-color colorAccent #7a36b1;
    .drop{
        border: 2px dashed rgba(0,0,0,.25);
        border-radius: 5px;
        padding: 32px;
    }
    """;

    public TransporterWindow (Gtk.Application application) {
         Object (application: application,
         icon_name: "com.github.bleakgrey.transporter",
            title: "Transporter",
            resizable: false
        );
        this.wormhole = new WormholeInterface ();
        this.window_position = WindowPosition.CENTER;
        this.set_titlebar (headerbar);

        wormhole.started.connect (() => update_header ());
        wormhole.closed.connect (() => update_header ());
        wormhole.errored.connect ((err, title, critical) => {
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

        Granite.Widgets.Utils.set_theming_for_screen (
            get_screen(),
            STYLE,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        stack = new Stack();
        stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        stack.show ();

        spinner = new Spinner ();
        spinner.active = true;

        back_button = new Button.with_label (_("Back"));
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
        back_button.clicked.connect (() => {
            if (back_button.sensitive)
                back ();
        });
        back_button.show ();

        settings_button = new Button ();
        settings_button.tooltip_text = _("Settings");
        settings_button.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        settings_button.clicked.connect (() => {
            if (settings_button.sensitive)
                append (new SettingsView (this));
        });

        headerbar = new HeaderBar ();
        headerbar.set_show_close_button (true);
        headerbar.title = "Transporter";
        headerbar.pack_start (back_button);
        headerbar.pack_end (settings_button);
        headerbar.pack_end (spinner);
        headerbar.show ();

        get_content_area ().add (stack);
    }

    private void update_header(){
        var back_visible = !(current_screen is WelcomeView) && stack.get_children ().length() > 1;
        update_header_widget (back_button, back_visible);

        var settings_visible = !(current_screen is SettingsView);
        update_header_widget (settings_button, settings_visible);

        settings_button.visible = !(current_screen is SettingsView || current_screen is InstallView || wormhole.is_running ());
        spinner.visible = (current_screen is InstallView || wormhole.is_running ());
    }

    private void update_header_widget(Widget widget, bool visible){
        if (visible) {
            widget.opacity = 1;
            widget.sensitive = true;
        }
        else {
            widget.opacity = 0;
            widget.sensitive = false;
        }
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
        stack.add (screen);
        stack.set_visible_child (screen);
        current_screen = screen;

        update_header ();
    }

    private void pop(){
        if(current_screen.previous_child == null){
            stack.remove (current_screen);
            current_screen.destroy ();
            current_screen = null;
            return;
        };

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
