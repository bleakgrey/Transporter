public class DropView : Gtk.EventBox {

    protected WormholeInterface wormhole;

	construct {
	}

    public DropView(WormholeInterface wormhole){
        this.wormhole = wormhole;
    }

}