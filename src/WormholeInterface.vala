using GLib;

public class WormholeInterface : Object { // paplay /usr/share/sounds/freedesktop/stereo/complete.oga

	int pid = -1;
	TransporterSettings settings;

	public signal void errored (string error, string title = _("Error"), bool critical = false);
	public signal void code_generated (string wormhole_id);
	public signal void progress (int percent);
	public signal void started ();
	public signal void finished ();
	public signal void closed ();

	public string home_path = null;
	public string wormhole_path = null;
	public string downloads_path = null;
	public const string[] WORMHOLE_LOCATIONS = {"/bin/wormhole", "/usr/sbin/wormhole", "~/.local/bin/wormhole"};

	public const string ERR_INVALID_ID = "reenter the key";
	public const string ERR_CROWDED = "crowded";
	public const string ERR_REJECTED = "transfer rejected";
	public const string ERR_ALREADY_EXISTS = "overwrite existing";
	public const string ERR_MISMATCHED_ID = "confirmation failed";
	public const string ERR_RELAY_UNRESPONSIVE = "We had a problem connecting to the relay";
	public const string ID_GENERATED = "wormhole receive";
	public const string FINISH_RECEIVE = "Received file written";
	public const string PERCENT_RECEIVE = "%|";

	construct{
		home_path = GLib.Environment.get_home_dir ();
		downloads_path = GLib.Environment.get_user_special_dir (UserDirectory.DOWNLOAD);
		settings = TransporterSettings.get_default();
	}

	public bool bin_present(){
		var found = false;

		foreach (var path in WORMHOLE_LOCATIONS) {
			try{
				string[] env = Environ.get ();
				string[] cmd = {path.replace ("~", home_path), "--version"};
				Process.spawn_sync (home_path, cmd, env, SpawnFlags.STDERR_TO_DEV_NULL, null, null, null, null);
				found = true;
				wormhole_path = path;
				info ("Found magic-wormhole at: "+wormhole_path);
			}
			catch (SpawnError e){}
		}

		if(!found)
			info ("Can't find magic-wormhole");

		return found;
	}

	public bool install(){
		started ();
		try{
			Process.spawn_command_line_sync ("pip install --user --no-input magic-wormhole");
		}
		catch (GLib.SpawnError e){
			warning(e.message);
			errored(e.message, _("Installation Error"), true);
			return false;
		}
		closed ();

		var found = bin_present ();
		if(!found)
			errored(_("Couldn't install magic-wormhole automatically."), _("Installation Error"), true);
		else
			finished ();

		return found;
	}

	public bool is_running(){
		return pid > 0;
	}

	public void close(){
			if(!is_running ()) return;
			try {
				info ("Closing wormhole with PID "+ pid.to_string ());
				Process.spawn_command_line_sync ("kill " + pid.to_string ());
				pid = -1;
				closed ();
			} catch (SpawnError e) {
				warning ("Can't close wormhole: %s\n", e.message);
			}		
	}

	private void open(string[] argv, string work_dir){
		if (is_running ()) return;

		int standard_err;
		int standard_out;

		info("Opening wormhole");
		started ();

		try{
		    Process.spawn_async_with_pipes (
		        work_dir,
		        argv,
		        null,
		        SpawnFlags.SEARCH_PATH,
		        null,
		        out pid,
		        null,
		        out standard_out,
		        out standard_err);

			var channel_out = new IOChannel.unix_new (standard_out);
			channel_out.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
				return process_line (channel, condition);
			});
			var channel_err = new IOChannel.unix_new (standard_err);
			channel_err.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
				return process_line (channel, condition);
			});
		}
		catch(GLib.SpawnError e){
			errored(e.message);
			closed();
		}

	}

	private string[] get_launch_args(){
		string[] args = {wormhole_path.replace ("~", home_path)};

		var relay = settings.server_relay;
		if(relay != null){
			args += "--relay-url";
			args += relay;
		}

		var transit = settings.server_transit;
		if(transit != null){
			args += "--transit-helper";
			args += transit;
		}

		return args;
	}

	public void send(string file){
		string[] args = get_launch_args();
		args += "send";
		args += file;

		var words = settings.words;
		if(words > -1){
			args += "--code-length";
			args += words.to_string();
		}
		open (args, home_path);
	}
	public void receive(string id){
		string[] args = get_launch_args();
		args += "receive";
		args += "--accept-file";
		args += id;
		open (args, downloads_path);
	}

	private bool process_line (IOChannel channel, IOCondition condition) {
		if(condition == IOCondition.HUP){
			if(is_running ()){
				debug (">>STREAM END<<");
				close ();
			}
			return false;
		}

		try {
			string line;
			channel.read_line (out line, null, null);
			debug ("%s> %s", condition.to_string(), line);

			if(ERR_INVALID_ID in line || ERR_MISMATCHED_ID in line){
				errored (_("Please verify your ID and try again."), _("Invalid ID"));
				close ();
				return false;
			}
			if(ERR_CROWDED in line){
				errored (_("Server is crowded at the moment. "), _("Server Error"));
				close ();
				return false;
			}
			if(ERR_ALREADY_EXISTS in line){
				errored (_("Received file already exists in Downloads folder."), _("File Conflict"));
				close ();
				return false;
			}
			if(ERR_ALREADY_EXISTS in line){
				errored (_("Received file already exists in Downloads folder."), _("File Conflict"));
				close ();
				return false;
			}
			if(ERR_RELAY_UNRESPONSIVE in line){
				errored (_("Relay server unresponsive."), _("Server Error"));
				close ();
				return false;
			}

			if(PERCENT_RECEIVE in line){
				var percent = line.split ("%", 2) [0];
				progress (int.parse (percent));
			}
			if(ID_GENERATED in line){
				var id = line.split (" ", 3)[2];
				code_generated (id.strip ().replace ("\n",""));
				return false;
			}
			if(FINISH_RECEIVE in line){
				finished ();
				close ();
			}


		} catch (IOChannelError e) {
			warning ("IOChannelError: %s\n", e.message);
			return false;
		} catch (ConvertError e) {
			warning ("ConvertError: %s\n", e.message);
			return false;
		}

		while (Gtk.events_pending ())
			Gtk.main_iteration ();

		return true;
	}

}