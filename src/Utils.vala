public class Utils{

	private static const string dir = "/tmp/Transporter";
	private static string zip = null;

	public static string get_send_path(string[] uris){
		int files = 0;
		int dirs = 0;
		string[] paths = {};

		foreach (string uri in uris) {
	    	var path = GLib.Filename.from_uri(uri);
	    	paths += path;

	    	if(is_directory (path))
	    		dirs++;
	    	else
	    		files++;
	    }

	    info("Sending %d files and %d directories".printf(files, dirs));

	    if(uris.length == 1 && files == 1)
	    	return paths[0];
	    else if(uris.length == 1 && dirs == 1)
	    	return paths[0];
	    else
	    	return get_temp_path(paths);
	}

	public static bool is_directory(string path){
		string stdout = "";
		Process.spawn_sync (
		        "/",
		        {"file", "-b", "--mime-type", path},
		        Environ.get (),
		        SpawnFlags.SEARCH_PATH,
		        null,
		        out stdout,
		        null,
		        null);

		return "directory" in stdout;
	}

	private static string get_temp_path(string[] paths){
		info ("Preparing zip file at: "+dir);
		clean_temp();

		//Create temp folder
		zip = "Transfer-" + new GLib.DateTime.now_local ().to_unix ().to_string ();
		var zip_path = "%s/%s".printf(dir, zip);
		Process.spawn_command_line_sync ("mkdir " + dir);

		//Create symlinks for each file
		foreach (string path in paths) {
			info ("Linking: " + path);
			Process.spawn_sync (
		        dir, {"ln", "-s", path},
		        Environ.get (),
		        SpawnFlags.SEARCH_PATH, null, null, null, null);
		}

		//Zip them up
		Process.spawn_sync (
			dir,
			{"zip", "-r", zip+".zip", "."},
			Environ.get (),
			SpawnFlags.SEARCH_PATH,
			null,
			null,
			null,
			null);

		return zip_path+".zip";
	}

	public static void clean_temp(){
		if(dir != null && dir != "/"){
			info("Cleaning up temporary files");
			Process.spawn_command_line_async ("rm -rf /tmp/Transporter");
		}
	}

}