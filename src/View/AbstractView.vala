using Gtk;

public abstract class AbstractView : Gtk.Grid {

    public AbstractView? previous_child = null;

    protected TransporterWindow window;
    protected WormholeInterface wormhole;

    public AbstractView (TransporterWindow window) {
        this.window = window;
        this.wormhole = window.wormhole;
        this.setup ();
    }

    protected virtual void setup () {}

}
