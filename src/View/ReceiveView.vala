public class ReceiveView : Gtk.EventBox {

    protected WormholeInterface wormhole;

    protected Gtk.Label title_label;
    protected Gtk.Label subtitle_label;
    protected Gtk.Entry entry;

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);

        title_label = new Gtk.Label (_("Enter Transfer ID"));
        title_label.justify = Gtk.Justification.CENTER;
        title_label.hexpand = true;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        subtitle_label = new Gtk.Label (_("Ask your partner to send you it"));
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
        items.add (entry);

        add (content);
        show_all ();
    }

    public ReceiveView(WormholeInterface wormhole){
        this.wormhole = wormhole;
        this.setup ();
    }

    protected virtual void setup(){
        entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear");
        entry.icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY)
                entry.set_text ("");
        });
        entry.activate.connect (() => {
            unowned string str = entry.get_text ();
            entry.set_sensitive (false);
            wormhole.receive (str.strip());
        });

        wormhole.finished.connect ((isSuccessful) => {
            entry.hide();
            if(isSuccessful){
                title_label.set_text (_("Transfer Complete"));
                subtitle_label.set_text (_("Saved in your Downloads folder"));
            }
            else{
                title_label.set_text (_("Transfer Failed"));
                subtitle_label.set_text (_("Try again in a bit"));
                entry.set_sensitive(true);
            }
        });

        wormhole.progress.connect((percent) => {
            title_label.set_text (_("Transferring: ") + percent.to_string() + "%");
            subtitle_label.set_text (_("Please wait a moment"));
        });
    }

}