importScripts('d3/d3.min.js', 'trianglify.min.js');

self.addEventListener('message', function(e) {
    var data = e.data;
    switch (data.cmd) {
        case 'trianglify':
            var t = new Trianglify();
            t.options.x_gradient = Trianglify.randomColor();
            t.options.y_gradient = t.options.x_gradient.map(function(c) {
                return d3.rgb(c).brighter(0.5);
            });
            t.options.cellsize = data.cellsize || 60;
            var pattern = t.generate(data.width, data.height); // svg width, height
            // pattern.svg // SVG DOM Node object
            // pattern.svgString // String representation of the svg element
            // pattern.base64 // Base64 representation of the svg element
            // pattern.dataUri // data-uri string
            // pattern.dataUrl // data-uri string wrapped in url() for use in css
            // pattern.append() // append pattern to <body> .Useful for testing.
             self.postMessage(pattern.dataUrl);
            break;
        case 'stop':
            self.postMessage('WORKER STOPPED: ' + data.msg + '. (buttons will no longer work)');
            self.close(); // Terminates the worker.
            break;
        default:
            self.postMessage('Unknown command: ' + data.msg);
    };
}, false);
