public class Utils{

	private static string dir = null;

	public static string get_send_path(string[] uris){
		int files = 0;
		int dirs = 0;
		string[] paths = {};

		foreach (string uri in uris) {
	    	var path = uri.replace ("%20", " ").replace ("file://", "");
	    	paths += path;

	    	if(is_path_directory (path))
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

	public static bool is_path_directory(string path){
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
		if(dir == null){
			dir = "/tmp/TRANSPORT-0";
			Process.spawn_command_line_sync ("mkdir " + dir);
			info("Creating symlinks at: "+dir);
		}

		warning(dir);
		return dir;
	}

}