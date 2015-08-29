var fs = require("fs");

var relative_path = require("path").relative;

var chokidar = require('chokidar');

var express = require('express');

var server = express();

server.get("/init.lua",function(req,res) {
	res.sendFile("/init.lua",{root: __dirname});
});

server.use("/",express.static('web'));

var file_table={};

function mount(dir) {
	server.use("/"+dir+"/",express.static(dir));

	var watcher = chokidar.watch(dir,{ignorePermissionErrors: true});

	function add_edit_callback(name,stat) {
		var path = relative_path(__dirname,name).split(/\/|\\/);
		var ct = file_table;
		for (var i=0;i<path.length-1;i++) {
			ct=ct[path[i]];
		}

		var item = stat.isDirectory()?{}:stat.mtime;
		ct[path[path.length-1]]=item;
		
		path.push(item);
		feed(JSON.stringify(path));
	}

	watcher.on("add",add_edit_callback);
	watcher.on("addDir",add_edit_callback);
	watcher.on("change",add_edit_callback);

	function delete_callback(name) {
		var path = relative_path(__dirname,name).split(/\/|\\/);
		var ct = file_table;
		for (var i=0;i<path.length-1;i++) {
			ct=ct[path[i]];
			if (!ct) return;
		}
		//if (ct)
		delete ct[path[path.length-1]];

		path.push(null);
		feed(JSON.stringify(path));
	}

	watcher.on("unlink",delete_callback);
	watcher.on("unlinkDir",delete_callback);

	watcher.on("error", function(error) { console.log('WATCH-ERR: ', error); });
}

mount("engine");
mount("game");

server.get("/index.json",function(req,res) {
	res.send(file_table);
});

var feeders = new Set();

function feed(data) {
	feeders.forEach(function(res) {
		res.write("data: "+data+"\n\n");
	});
}

server.get("/feed/",function(req,res) {
	req.socket.setTimeout(999999999);

	res.writeHead(200,{
		"Content-Type": "text/event-stream",
		"Cache-Control": "no-cache",
		"Connection": "keep-alive"
	});

	feeders.add(res);

	req.on("close",function() {
		feeders.delete(res);
	});
});

server.use(function(req,res) {
	res.status(404).send("404 - Resource Not Found");
});

server.use(function(err,req,res,next) {
	console.log('<500> '+err);
	res.status(500).send("500 - Internal Error");
});

server.listen(8080,function() {
	console.log('Server running.');
});