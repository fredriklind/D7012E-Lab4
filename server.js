var Pusher = require('pusher');
var fileName = 'output.txt'
var pusher = new Pusher({
    appId: '75558',
    key: 'd889e86646d3314749ce',
    secret: '7e01f1fc5ee3e4aee4e9'
});

var chokidar = require('chokidar');
var watcher = chokidar.watch(fileName, {
    ignored: /[\/\\]\./,
    persistent: true
});

watcher.on('change', function(path, stats) {
    fs = require('fs');
    fs.readFile(fileName, 'utf8', function(err, data) {
        if (err) {
            return console.log(err);
        }
        console.log(data);
        pusher.trigger('file-changes', 'file-changed', {
            "message": data
        });
    });
});
/*var fs = require('fs'); // require the filesystem api
var file2watch = "output.txt"; // which file to watch
function readXML(err, data) { // function for reading XML files
    if (err) { // if there's an error
        throw err; // throw the error message
    }
    console.log(data); // show the data in the conosle.
    
}

function iSeeYou(curr, prev) {
    if (curr.size != prev.size) { // if there's been a change to the file (size change)
        fs.readFile(file2watch, 'utf8', readXML) // read the file contents, call readXML
    }
}
fs.watchFile(file2watch, iSeeYou); // add a watcher to a file*/