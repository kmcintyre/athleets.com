requirejs.config({
	urlArgs: "bust=beta",	
    "paths": {
      "jquery": "//ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min"
    },
	"shim": {
	  "jquery.cookie": ["jquery"],
	  "typeahead.jquery": ["jquery"]
	}
});
requirejs(["fifa_all"]);