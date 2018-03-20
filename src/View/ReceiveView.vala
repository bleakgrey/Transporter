public class ReceiveView : Gtk.Box {

    protected bool is_finished = false;

    protected TransporterWindow window;
    protected WormholeInterface wormhole;

    protected Gtk.Label title_label;
    protected Gtk.Label subtitle_label;
    protected Gtk.Entry entry;

    construct {
        title_label = new Gtk.Label (_("Enter Transfer ID"));
        title_label.justify = Gtk.Justification.CENTER;
        title_label.hexpand = true;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        subtitle_label = new Gtk.Label (_("Ask the sender to share it"));
        subtitle_label.justify = Gtk.Justification.CENTER;
        subtitle_label.hexpand = true;
        subtitle_label.wrap = true;
        subtitle_label.wrap_mode = Pango.WrapMode.WORD;

        var subtitle_label_context = subtitle_label.get_style_context ();
        subtitle_label_context.add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        subtitle_label_context.add_class (Granite.STYLE_CLASS_H2_LABEL);

        var items = new Gtk.Grid ();
        items.orientation = Gtk.Orientation.VERTICAL;
        items.row_spacing = 12;
        items.halign = Gtk.Align.CENTER;
        items.margin_top = 24;

        var content = new Gtk.Grid ();
        content.expand = true;
        content.margin = 12;
        content.orientation = Gtk.Orientation.VERTICAL;
        content.valign = Gtk.Align.CENTER;
        content.add (title_label);
        content.add (subtitle_label);
        content.add (items);

        entry = new Gtk.Entry ();
        entry.width_chars = 30;
        entry.grab_focus ();
        items.add (entry);

        add (content);
        show_all ();
    }

    public ReceiveView(TransporterWindow window){
        this.window = window;
        this.wormhole = window.wormhole;
        this.setup ();
    }

    protected virtual void setup(){
        entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear");
        entry.icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY)
                entry.set_text ("");
        });
        entry.activate.connect (() => {
            is_finished = false;
            unowned string str = entry.get_text ();
            entry.set_sensitive (false);
            wormhole.receive (str.strip());
        });

        wormhole.errored.connect(() => {
            is_finished = true;
            entry.set_sensitive (true);
        });
        wormhole.finished.connect (() => {
            is_finished = true;
            entry.hide();
            title_label.set_text (_("Transfer Complete"));
            subtitle_label.set_text (_("Saved in your Downloads folder"));
            wormhole.ding();
        });
        wormhole.closed.connect(() => {
            entry.set_sensitive (true);
            if(!is_finished)
                wormhole.errored (_("Connection closed unexpectedly."));
        });
        wormhole.progress.connect((percent) => {
            title_label.set_text (_("Transferring: ") + percent.to_string() + "%");
            subtitle_label.set_text (_("Please wait a moment"));
        });
    }

}