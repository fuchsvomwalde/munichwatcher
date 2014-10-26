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
        var socket = io('localhost:3000');

        socket.on('newCamera', function(data){
            console.log(data);

            var image = 'img/mapcamNew.svg';
            addCamMarker(data, image, true);
        });
    }

    function initContent() {
        oContent = document.getElementById('content');
        oHeaderBar = document.querySelector('header');
        oGlassContent = document.querySelector("#glass-content");
        skipper = document.querySelector("#header-skipper");
        aAnimIn = document.querySelectorAll('.animation-init');
        language = document.getElementById('language-setting');

        oContent.style.height = window.innerHeight + 'px';
        oContent.height = window.innerHeight + 'px';

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
            addCamMarker(cam, image, false);
        };
        var imageCrime = 'img/crimeMarker.svg';
        for (var i = 0; i < crimeData.length; i++) {
            var crime = crimeData[i];
            addCrimeMarker(crime, imageCrime, false);
        };
        heatmap.setMap(map);
    }

    function closeAllInfoWindows() {
        for (var i = 0; i < infoWindows.length; i++) {
            infoWindows[i].close();
        }
    }

    function addCrimeMarker(crime, image, animated) {
        animated = animated ? google.maps.Animation.DROP : null;
        var marker = new google.maps.Marker({
            position: new google.maps.LatLng(crime.lat, crime.lng),
            map: map,
            icon: image,
            title: crime.owner,
            draggable: false,
            animation: animated
        });

        marker.info = new google.maps.InfoWindow({
            content: '<div class="popup-marker"><h2>' + crime.type.toUpperCase() + '</h2>' +
                '<div><b>Datum:</b><p>' + crime.time + '</p></div>' +
                '<div><b>Beschreibung:</b><p>' + crime.title + '</p></div>' +
                '</div>'
        });
        infoWindows.push(marker.info);
        google.maps.event.addListener(marker, 'click', function() {
            closeAllInfoWindows();
            marker.info.open(map, marker);
        });
    }

    function addCamMarker(cam, image, animated) {
        var lat, lng;
        if (typeof cam.lat == "string" && typeof cam.lng == "string") {
            // GPS Position are notated as strings and must be transformed
            // debugger
            cam.lat = cam.lat.replace(/\s+/g,"");
            cam.lng = cam.lng.replace(/\s+/g,"");
            var latParts = cam.lat.split(/[^\d\w]+/);
            var lngParts = cam.lng.split(/[^\d\w]+/);
            lat = ConvertDMSToDD(parseInt(latParts[0]), parseInt(latParts[1]), parseInt(latParts[2]), latParts[3]);
            lng = ConvertDMSToDD(parseInt(lngParts[0]), parseInt(lngParts[1]), parseInt(lngParts[2]), lngParts[3]);
        } else {
            lat = cam.lat;
            lng = cam.lng;
        }

        animated = animated ? google.maps.Animation.DROP : null;
        var marker = new google.maps.Marker({
            position: new google.maps.LatLng(lat, lng),
            map: map,
            icon: image,
            title: cam.owner,
            draggable: false,
            animation: animated
        });

        var audio = (cam.audio == "true") ? "Ja" : "Nein";
        var realtime = (cam.realtime == "true") ? "Ja" : "Nein";
        var oR = (cam.objectRecognition == "true") ? "Ja" : "Nein";

        var camImg = "";
        if (cam.img != "") {
            camImg = "<div class='cam-img' style='background-image: url("+cam.img+")'></div>"
        }

        var category = '';
        if (cam.category.indexOf("publicSecurity") > -1) category += "<i class='icon-shield'></i><span>Öffentliche Sicherheit </span>";
        if (cam.category.indexOf("traffic") > -1) category += "<i class='icon-road'></i><span>Verkehrsüberwachtung </span>";
        if (cam.category.indexOf("propertySec") > -1) category += "<i class='icon-building'></i><span>Objektschutz </span>";
        if (cam.category.indexOf("other") > -1) category += "<i class='icon-eye2'></i><span>Sonstiges </span>";

        var address = (cam.adress == "") ? cam.owner : cam.adress;

        marker.info = new google.maps.InfoWindow({
            content: '<div class="popup-marker"><h2>' + cam.owner + '</h2>' +
                camImg +
                '<div><b>Adresse:</b><span>' + address + '</span></div>' +
                '<div><b>Anzahl Kameras:</b><span>' + cam.count + '</span></div>' +
                '<div><b>Kategorie:</b><span>' + category + '</span></div>' +
                '<div class="'+audio+'"><i class="icon-audio"></i><b>Audiofähig:</b><span>' + audio + '</span></div>' +
                '<div class="'+realtime+'"><i class="icon-realtime"></i><b>Echtzeitübertragung:</b><span>' + realtime + '</span></div>' +
                '<div class="'+oR+'"><i class="icon-target"></i><b>Objekterkennung:</b><span>' + oR + '</span></div>' +
                '</div>'
        });
        infoWindows.push(marker.info);
        google.maps.event.addListener(marker, 'click', function() {
            closeAllInfoWindows();
            marker.info.open(map, marker);
        });
    }

    function ConvertDMSToDD(degrees, minutes, seconds, direction) {
        var dd = degrees + minutes / 60 + seconds / (60 * 60);

        if (direction == "S" || direction == "W") {
            dd = dd * -1;
        } // Don't do anything for N or E
        return dd;
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

        oContent.style.height = height + 'px';
        oContent.height = height + 'px';
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
    // var camData = [{
    //     owner: 'Staat',
    //     adress: 'ghjsdgjhfgsdjhfbkjs',
    //     count: 10,
    //     category: 'Traffic',
    //     audio: true,
    //     realtime: false,
    //     objectRecognition: true,
    //     lat: 48.1351253,
    //     lng: 11.5819806
    // }, {
    //     img: 'base64',
    //     owner: 'Staat',
    //     adress: 'ghjsdgjhfgsdjhfbkjs',
    //     count: 10,
    //     category: 'Traffic',
    //     audio: true,
    //     realtime: false,
    //     objectRecognition: true,
    //     lat: 48.1355553,
    //     lng: 11.5839806
    // }];
})();
