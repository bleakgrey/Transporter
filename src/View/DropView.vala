public class DropView : Gtk.Box {

	private string STYLE = """
	.drop{
		border: 2px dashed rgba(0,0,0,.25);
		border-radius: 5px;
		padding: 32px;
	}
	""";

    protected WormholeInterface wormhole;

	construct {
		Granite.Widgets.Utils.set_theming_for_screen (
		    this.get_screen(),
		    STYLE,
		    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
		);

		this.border_width = 10;

		var drop = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		drop.hexpand = true;
		drop.vexpand = true;
		drop.get_style_context().add_class("drop");

		var title = new Gtk.Label (_("Drag files and folders here"));
		title.get_style_context ().add_class ("h2");
		title.hexpand = true;
		title.vexpand = true;
		drop.add (title);

		add (drop);
		show_all ();
	}

    public DropView(WormholeInterface wormhole){
        this.wormhole = wormhole;
    }

}