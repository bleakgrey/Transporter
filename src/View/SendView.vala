public class SendView : ReceiveView {

    protected Gtk.Clipboard clipboard;

	public SendView(WormholeInterface wormhole, Gtk.Clipboard clipboard){
		base (wormhole);
        this.clipboard = clipboard;
	}

    protected override void setup(){
        title_label.set_text (_("Starting Transfer..."));
        subtitle_label.set_text ("");

        entry.set_sensitive (false);
        entry.set_editable (false);
        entry.set_text (_("Generating ID..."));
        entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-copy-symbolic");
        entry.icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY)
                clipboard.set_text (entry.get_text(), -1);
        });

        wormhole.code_generated.connect ((id) => {
            title_label.set_text (_("Your Transfer ID"));
            subtitle_label.set_text (_("Share it with the recipient"));
            entry.show ();
            entry.set_sensitive (true);
            entry.set_text (id);
        });

        wormhole.closed.connect(() => {
            entry.hide ();
            title_label.set_text (_("Transfer Complete"));
            subtitle_label.set_text (_("Connection has been closed"));
        });
    }

}