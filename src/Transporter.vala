using Gtk;
using Granite;

public class Transporter : Granite.Application {

    public static Transporter instance;
    public static bool open_send = false;
    public static bool open_receive = false;
    public TransporterWindow window;

    private new const GLib.OptionEntry[] options = {
            { "send", 0, 0, OptionArg.NONE, ref open_send, "Open Send view", null },
            { "receive", 0, 0, OptionArg.NONE, ref open_receive, "Open Receive view", null },
            { null }
    };

    construct {
            application_id = "com.github.bleakgrey.transporter";
            flags = ApplicationFlags.HANDLES_OPEN;
            program_name = "Transporter";
            build_version = "1.2.2";
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        try {
            var opt_context = new OptionContext ("- Options");
            opt_context.add_main_entries (options, null);
            opt_context.parse (ref args);
        }
        catch (GLib.OptionError e) {
            warning (e.message);
        }

        instance = new Transporter ();
        return instance.run (args);
    }

    protected override void startup () {
        base.startup ();
        Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        window = new TransporterWindow (this);
    }

    protected override void shutdown () {
        window.wormhole.close ();
        base.shutdown ();
    }

    protected override void activate () {
        window.present (); 

        if (open_send)
            window.append (new DropView (window));
        else if (open_receive)
            window.append (new ReceiveView (window));
    }

    public override void open (File[] files, string hint) {
        string[] paths = {};
        foreach (var file in files) {
            var path = file.get_path ();
            if (path != null) {
                info (path);
                paths += path;
            }
        }

        activate();

        if (paths.length > 0) {
            var view = new DropView(window);
            window.append (view);
            view.send (paths);
        }
    }

}