public class InstallView : ReceiveView {

    public InstallView(TransporterWindow window){
        base (window);
    }

    protected override void setup(){
        title_label.set_text (_("Preparing Transporter"));
        subtitle_label.set_text (_("Installing magic-wormhole"));
        entry.hide ();

        wormhole.finished.connect(() => Timeout.add (1000, replace));

        try{
            if(Thread.supported ())
                new Thread<bool>.try ("InstallThread", () => {
                    wormhole.install ();
                    return false;
                });
            else
                wormhole.install ();
        }
        catch(GLib.Error e){
            warning (e.message);
        }
    }

    public bool replace(){
        wormhole.ding ();
        window.replace (new WelcomeView (window));
        return false;
    }

}
