(function() {
    "use strict";

    // Bootstrap
    window.addEventListener('load', function(e) {
        initHeader();
        initContent();
        addListeners();
        initWebSocket();
        setTimeout(function() {
            window.scrollTo(0, 0);
        }, 1);
    }, false);

    // Declaration & Initializing
    var width, height, hideLangageList, largeHeader, language, oContent, aContactItems, oGlassContent, skipper, oHeaderBar, aImgItems, canvas, ctx, circles, target, animateHeader = true,
        isBgrAnimating = false,
        isSkipperAnimating = false,
        iCurrentBgr = 0,
        bgrInterval, noscroll = true,
        isRevealed = false,
        aAnimIn, t,
        map, pointarray, heatmap,
        infoWindows = [];

    // Event handling
    function addListeners() {
        window.addEventListener('resize', resize);
        window.addEventListener('scroll', scroll);
        skipper.addEventListener('click', function() {
            toggle(1);
        });
        if (!language) return;
        for (var i = 0; i < language.children.length; i++) {
            language.children[i].addEventListener('click', function(e) {
                if (e.currentTarget.nodeName === 'A') {
                    languageDialog();
                } else {
                    selectLanguage(e);
                }
            });
        }
    }

    function initHeader() {
        width = window.innerWidth;
        height = window.innerHeight;
        target = {
            x: 0,
            y: height
        };

        largeHeader = document.getElementById('large-header');
        largeHeader.style.height = height + 'px';

        canvas = document.getElementById('header-canvas');
        canvas.width = width;
        canvas.height = height;
        ctx = canvas.getContext('2d');

        // create particles
        circles = [];
        var numberCircles = 100; //width * 0.5;
        for (var x = 0; x < numberCircles; x++) {
            var c = new Circle();
            circles.push(c);
        }
        limitLoop(animateHeaderCanvas, 60);

        aImgItems = document.querySelector('ul.image-wrap').children;
        bgrInterval = setInterval(animateBackgroundTransition, 5000);

        aContactItems = document.querySelectorAll('.btn-wrapper');

        var i = 0;
        var timeoutAnimation = function() {
            setTimeout(function() {
                if (aContactItems.length == 0) return;
                aContactItems[i].className = aContactItems[i].className + ' fxFlipInX';
                i++;
                if (i < aContactItems.length) timeoutAnimation();
            }, 100);
        }

        disable_scroll();
        timeoutAnimation();
    }

    function initWebSocket() {
        var connection = new WebSocket('ws://echo.websocket.org');

        // When the connection is open, send some data to the server
        connection.onopen = function() {
            connection.send('Ping'); // Send the message 'Ping' to the server
        };

        // Log errors
        connection.onerror = function(error) {
            console.log('WebSocket Error ' + error);
        };

        // Log messages from the server
        connection.onmessage = function(e) {
            console.log('Server: ' + e.data);

            var newCam = {
                img: 'base64',
                owner: 'Staat',
                adress: 'ghjsdgjhfgsdjhfbkjs',
                count: 10,
                category: 'Traffic',
                audio: true,
                realtime: false,
                objectRecognition: true,
                lat: 48.1355553,
                lng: 11.5839806
            };

            var image = 'img/mapcamNew.svg';
            addMarker(newCam, image, true);
        };
    }

    function initContent() {
        oContent = document.getElementById('content');
        oHeaderBar = document.querySelector('header');
        oGlassContent = document.querySelector("#glass-content");
        skipper = document.querySelector("#header-skipper");
        aAnimIn = document.querySelectorAll('.animation-init');
        language = document.getElementById('language-setting');

        oContent.style.height = window.innerHeight;

        // var worker = new Worker('scripts/renderer.js');
        // worker.addEventListener('message', function(e) {
        //     document.body.setAttribute('style', 'background-image: ' + e.data);
        // }, false);

        // var body = document.body;
        // var html = document.documentElement;
        // var height = Math.max(body.scrollHeight, body.offsetHeight,
        //     html.clientHeight, html.scrollHeight, html.offsetHeight);

        // worker.postMessage({
        //     'cmd': 'trianglify',
        //     'cellsize': '60',
        //     'width': body.offsetWidth,
        //     'height': height
        // });

        // t = new Trianglify();
        // t.options.x_gradient = Trianglify.randomColor();
        // t.options.y_gradient = t.options.x_gradient.map(function(c) {
        //     return d3.rgb(c).brighter(0.5);
        // });
        // t.options.cellsize = 150;
        // var body = document.body;
        // var html = document.documentElement;
        // var height = Math.max( body.scrollHeight, body.offsetHeight, 
        //                html.clientHeight, html.scrollHeight, html.offsetHeight );
        // var pattern = t.generate(body.offsetWidth, height); // svg width, height
        // // pattern.svg // SVG DOM Node object
        // // pattern.svgString // String representation of the svg element
        // // pattern.base64 // Base64 representation of the svg element
        // // pattern.dataUri // data-uri string
        // // pattern.dataUrl // data-uri string wrapped in url() for use in css
        // // pattern.append() // append pattern to <body>. Useful for testing.
        // body.setAttribute('style', 'height: 5rem; background-size: cover; background-image: ' + pattern.dataUrl);
        // // oGlassContent.innerHTML = pattern.svgString;

        // limitLoop(colorize, 10);

        var mapOptions = {
            zoom: 14,
            center: new google.maps.LatLng(48.1351253, 11.5819806)
        };
        map = new google.maps.Map(document.getElementById('map-canvas'),
            mapOptions);

        var pointArray = new google.maps.MVCArray(crimeData.map(function(crime) {
            return new google.maps.LatLng(crime.lat, crime.lng);
        }));

        heatmap = new google.maps.visualization.HeatmapLayer({
            data: pointArray
        });
        heatmap.set('radius', heatmap.get('radius') ? null : 50);
        var gradient = [
            'rgba(255, 255, 255, 0)',
            'rgba(255, 0, 0, 1)',
            'rgba(255, 0, 0, 1)',
            'rgba(255, 0, 0, 1)',
            'rgba(255, 0, 0, 1)',
            'rgba(255, 0, 0, 1)',
            'rgba(240, 0, 0, 1)',
            'rgba(220, 0, 0, 1)',
            'rgba(200, 0, 0, 1)',
            'rgba(180, 0, 0, 1)',
            'rgba(160, 0, 0, 1)',
            'rgba(140, 0, 0, 1)',
            'rgba(120, 0, 0, 1)',
            'rgba(100, 0, 0, 1)',
            'rgba(80, 0, 0, 1)',
            'rgba(60, 0, 0, 1)',
            'rgba(40, 0, 0, 1)',
            'rgba(20, 0, 0, 1)',
            'rgba(0, 0, 0, 1)'
        ];
        heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);

        var image = 'img/mapcam.svg';
        for (var i = 0; i < camData.length; i++) {
            var cam = camData[i];
            addMarker(cam, image, false);
        };
        heatmap.setMap(map);
    }

    function closeAllInfoWindows() {
        for (var i = 0; i < infoWindows.length; i++) {
            infoWindows[i].close();
        }
    }

    function addMarker(cam, image, animated) {
        animated = animated ? google.maps.Animation.DROP : null;
        var marker = new google.maps.Marker({
            position: new google.maps.LatLng(cam.lat, cam.lng),
            map: map,
            icon: image,
            title: cam.owner,
            draggable: false,
            animation: animated
        });

        var audio = cam.audio ? "Ja" : "Nein";
        var realtime = cam.realtime ? "Ja" : "Nein";
        var oR = cam.objectRecognition ? "Ja" : "Nein";

        marker.info = new google.maps.InfoWindow({
            content: '<div class="popup-marker"><h2>' + cam.owner + '</h2>' +
                '<div><b>Adresse:</b><p>' + cam.adress + '</p></div>' +
                '<div><b>Anzahl Kameras:</b><p>' + cam.count + '</p></div>' +
                '<div><b>Kategorie</b><p>' + cam.category + '</p></div>' +
                '<div><b>Audiofähig:</b><p>' + audio + '</p></div>' +
                '<div><b>Echtzeitübertragung:</b><p>' + realtime + '</p></div>' +
                '<div><b>Objekterkennung:</b><p>' + oR + '</p></div>' +
                '</div>'
        });
        infoWindows.push(marker.info); 
        google.maps.event.addListener(marker, 'click', function() {
            closeAllInfoWindows();
            marker.info.open(map, marker);
        });
    }

    function colorize() {
        t.options.x_gradient = Trianglify.randomColor();
        t.options.y_gradient = t.options.x_gradient.map(function(c) {
            return d3.rgb(c).brighter(0.5);
        });
    }

    function languageDialog() {
        if (language.className === '') {
            language.className = 'language-select';
            clearTimeout(hideLangageList);
            hideLangageList = setTimeout(languageDialog, 4000);
        } else {
            language.className = '';
        }
    }

    function selectLanguage(e) {
        if (e.currentTarget.classList.contains('language-selected')) {
            e.preventDefault();
        } else {
            e.currentTarget.parentNode.querySelector('.language-selected').className = '';
            e.currentTarget.className = 'language-selected';
            var currentLanguage = e.currentTarget.getAttribute('data-language');
        };
        clearTimeout(hideLangageList);
        hideLangageList = setTimeout(languageDialog, 4000);
    }

    function disable_scroll() {
        var preventDefault = function(e) {
            e = e || window.event;
            if (e.preventDefault)
                e.preventDefault();
            e.returnValue = false;
        };
        document.body.ontouchmove = function(e) {
            preventDefault(e);
        };
    }

    function enable_scroll() {
        window.onmousewheel = document.onmousewheel = document.onkeydown = document.body.ontouchmove = null;
    }

    function scroll() {
        // Update Glass header
        // var iOffset = window.pageYOffset;
        // if (oGlassContent) oGlassContent.style.marginTop = (iOffset * -1) + 'px';

        // Upate Large Header
        var scrollVal = window.pageYOffset || largeHeader.scrollTop;
        if (noscroll) {
            if (scrollVal < 0) return false;
            window.scrollTo(0, 0);
        }
        if (isSkipperAnimating) {
            return false;
        }
        if (scrollVal <= 0 && isRevealed) {
            toggle(0);
        } else if (scrollVal > 0 && !isRevealed) {
            toggle(1);
        }

        // Animate Sections
        for (var i = 0; i < aAnimIn.length; i++) {
            var animationElement = aAnimIn[i];

            var docViewTop = window.pageYOffset;
            var docViewBottom = docViewTop + window.innerHeight;

            var elemTop = animationElement.offsetTop;
            // var elemBottom = elemTop + animationElement.offsetHeight;

            if (elemTop <= docViewBottom - animationElement.offsetHeight / 3) {
                if (animationElement.classList.contains('animate-in') == false) {
                    animationElement.className = animationElement.className + ' animate-in';
                }
            }
        }
    }

    function resize() {
        width = window.innerWidth;
        height = window.innerHeight;
        largeHeader.style.height = height + 'px';
        canvas.width = width;
        canvas.height = height;

        oContent.style.height = height;
    }

    function toggle(reveal) {
        isSkipperAnimating = true;

        if (reveal) {
            document.body.className = 'revealed';
        } else {
            animateHeader = true;
            noscroll = true;
            disable_scroll();
            document.body.className = '';
            // Reset animated content
            for (var i = 0; i < aAnimIn.length; i++) {
                var animationElement = aAnimIn[i];
                animationElement.className = animationElement.className.replace(' animate-in', '');
            }
        }

        // simulating the end of the transition:
        setTimeout(function() {
            isRevealed = !isRevealed;
            isSkipperAnimating = false;
            if (reveal) {
                animateHeader = false;
                noscroll = false;
                enable_scroll();
            }
        }, 1200);
    }

    function animateBackgroundTransition(dir) {
        if (isBgrAnimating) return false;
        isBgrAnimating = true;
        var cntAnims = 0;
        var itemsCount = aImgItems.length;
        dir = dir || 'next';

        var currentItem = aImgItems[iCurrentBgr];
        if (dir === 'next') {
            iCurrentBgr = (iCurrentBgr + 1) % itemsCount;
        } else if (dir === 'prev') {
            iCurrentBgr = (iCurrentBgr - 1) % itemsCount;
        }
        var nextItem = aImgItems[iCurrentBgr];

        var classAnimIn = dir === 'next' ? 'navInNext' : 'navInPrev'
        var classAnimOut = dir === 'next' ? 'navOutNext' : 'navOutPrev';

        var onEndAnimationCurrentItem = function() {
            currentItem.className = '';
            ++cntAnims;
            if (cntAnims === 2) {
                isBgrAnimating = false;
            }
        }

        var onEndAnimationNextItem = function() {
            nextItem.className = 'current';
            ++cntAnims;
            if (cntAnims === 2) {
                isBgrAnimating = false;
            }
        }

        setTimeout(onEndAnimationCurrentItem, 2000);
        setTimeout(onEndAnimationNextItem, 2000);

        currentItem.className = currentItem.className + ' ' + classAnimOut;
        nextItem.className = nextItem.className + classAnimIn;
    }

    var animateHeaderCanvas = function() {
        if (animateHeader) {
            ctx.clearRect(0, 0, width, height);
            for (var i in circles) {
                circles[i].draw();
            }
        }
    }

    var limitLoop = function(fn, fps) {

        // Use var then = Date.now(); if you
        // don't care about targetting < IE9
        var then = new Date().getTime();

        // custom fps, otherwise fallback to 60
        fps = fps || 60;
        var interval = 1000 / fps;

        return (function loop(time) {
            requestAnimationFrame(loop);

            // again, Date.now() if it's available
            var now = new Date().getTime();
            var delta = now - then;

            if (delta > interval) {
                // Update time
                // now - (delta % interval) is an improvement over just 
                // using then = now, which can end up lowering overall fps
                then = now - (delta % interval);

                // call the fn
                fn();
            }
        }(0));
    };

    // Canvas manipulation
    function Circle() {
        var _this = this;

        // constructor
        (function() {
            _this.pos = {};
            init();
        })();

        function init() {
            _this.pos.x = Math.random() * width;
            _this.pos.y = height + Math.random() * 100;
            _this.alpha = 0.1 + Math.random() * 0.3;
            _this.scale = 0.1 + Math.random() * 0.3;
            _this.velocity = Math.random();
        }

        this.draw = function() {
            if (_this.alpha <= 0) {
                init();
            }
            _this.pos.y -= _this.velocity;
            _this.alpha -= 0.0005;
            ctx.beginPath();
            ctx.arc(_this.pos.x, _this.pos.y, _this.scale * 10, 0, 2 * Math.PI, false);
            ctx.fillStyle = 'rgba(255,255,255,' + _this.alpha + ')';
            ctx.fill();
        };
    }

    // var crimeData = require('data/incidents.json');
    // [{
    //     title: "gjhfbv",
    //     adress: 'ghjsdgjhfgsdjhfbkjs',
    //     time: 7386489723697,
    //     type: "Raub",
    //     lat: 48.16646,
    //     lng: 11.57276
    // }, {
    //     title: "hdbvsjhdbhvb",
    //     adress: 'ghjsdgjhfgsdjhfbkjs',
    //     time: 7386489723697,
    //     type: "Mord",
    //     lat: 48.16166,
    //     lng: 11.57496
    // }];
    var camData = [{
        owner: 'Staat',
        adress: 'ghjsdgjhfgsdjhfbkjs',
        count: 10,
        category: 'Traffic',
        audio: true,
        realtime: false,
        objectRecognition: true,
        lat: 48.1351253,
        lng: 11.5819806
    }, {
        img: 'base64',
        owner: 'Staat',
        adress: 'ghjsdgjhfgsdjhfbkjs',
        count: 10,
        category: 'Traffic',
        audio: true,
        realtime: false,
        objectRecognition: true,
        lat: 48.1355553,
        lng: 11.5839806
    }];
})();
