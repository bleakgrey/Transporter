public class InstallView : ReceiveView {

	public InstallView(TransporterWindow window){
		base (window);
	}

    protected override void setup(){
        title_label.set_text (_("Preparing Transporter"));
        subtitle_label.set_text (_("Installing magic-wormhole"));
        entry.hide ();

        wormhole.finished.connect(() => {
            window.replaceScreen (new WelcomeView (window));
        });

        if(Thread.supported ()){
            new Thread<bool>.try ("InstallThread", () => {
                wormhole.install ();
                return false;
            });
        }
        else
            wormhole.install ();
    }

}