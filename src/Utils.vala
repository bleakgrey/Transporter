public class Utils{

	public static string get_send_path(string[] uris){
		foreach (string uri in uris) {
	    	uri = uri.replace ("%20", " ").replace ("file://", "");
	    	warning (uri);
	    }

		return "";
	}

}