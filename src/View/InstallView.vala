public class InstallView : ReceiveView {

    private MyApp app;

	public InstallView(MyApp app, WormholeInterface wormhole){
		base(wormhole);
        this.app = app;
        Timeout.add_seconds(1, install);
	}

    protected override void setup(){
        title_label.set_text (_("Preparing Transporter"));
        subtitle_label.set_text (_("Installing magic-wormhole"));

        entry.hide ();
    }

    private bool install(){ 
        if(wormhole.install()){
            info("Installed magic-wormhole");
            app.addScreen (new WelcomeView (app));
        }
        else{
            warning("Error during magic-wormhole installation");
            title_label.set_text (_("Something's Wrong"));
            subtitle_label.set_text (_("Couldn't install magic-wormhole automatically"));
        }
        return false;
    }

}