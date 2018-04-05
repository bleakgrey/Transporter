using Gtk;

public class ErrorView : AbstractView {

	public ErrorView(TransporterWindow window, string title, string err){
		base (window);

		var view = new Granite.Widgets.AlertView (title, err, "dialog-warning");
		view.get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);
		add(view);
		show_all();
	}

}