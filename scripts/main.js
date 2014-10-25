(function() {
    "use strict";

    // Bootstrap
    window.addEventListener('load', function(e) {
        initHeader();
        initContent();
        addListeners();
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
        map, pointarray, heatmap;

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
            'rgba(255, 255, 159, 1)',
            'rgba(255, 0, 0, 1)'
        ];
        heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);

        var citymap = {};
        citymap['munich'] = {
            center: new google.maps.LatLng(48.1351253, 11.5819806),
            population: 350
        };
        citymap['munich2'] = {
            center: new google.maps.LatLng(48.16646, 11.57276),
            population: 350
        };
        for (var city in citymap) {
            var populationOptions = {
                strokeColor: '#000000',
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillColor: '#000000',
                fillOpacity: 0.35,
                map: map,
                center: citymap[city].center,
                radius: Math.sqrt(citymap[city].population) * 100
            };
            // Add the circle for this city to the map.
            var cityCircle = new google.maps.Circle(populationOptions);
        }
        heatmap.setMap(map);
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

    var crimeData = [{
        lat: 48.16646,
        lng: 11.57276
    }];
})();
