"undefined" == typeof jwplayer && (jwplayer = function (h) {
        if (jwplayer.api) return jwplayer.api.selectPlayer(h)
    }, jwplayer.version = "6.9.4867", jwplayer.vid = document.createElement("video"), jwplayer.audio = document.createElement("audio"), jwplayer.source = document.createElement("source"), function (h) {
        function d(c) {
            return function () {
                return a(c)
            }
        }

        function m(c, a, k, l, b) {
            return function () {
                var d, f;
                if (b) k(c);
                else {
                    try {
                        if (d = c.responseXML)
                            if (f = d.firstChild, d.lastChild && "parsererror" === d.lastChild.nodeName) {
                                l && l("Invalid XML",
                                    a, c);
                                return
                            }
                    } catch (g) {}
                    if (d && f) return k(c);
                    (d = e.parseXML(c.responseText)) && d.firstChild ? (c = e.extend({}, c, {
                        responseXML: d
                    }), k(c)) : l && l(c.responseText ? "Invalid XML" : a, a, c)
                }
            }
        }
        var j = document,
            g = window,
            b = navigator,
            e = h.utils = {};
        e.exists = function (c) {
            switch (typeof c) {
            case "string":
                return 0 < c.length;
            case "object":
                return null !== c;
            case "undefined":
                return !1
            }
            return !0
        };
        e.styleDimension = function (c) {
            return c + (0 < c.toString().indexOf("%") ? "" : "px")
        };
        e.getAbsolutePath = function (c, a) {
            e.exists(a) || (a = j.location.href);
            if (e.exists(c)) {
                var k;
                if (e.exists(c)) {
                    k = c.indexOf("://");
                    var l = c.indexOf("?");
                    k = 0 < k && (0 > l || l > k)
                } else k = void 0; if (k) return c;
                k = a.substring(0, a.indexOf("://") + 3);
                var l = a.substring(k.length, a.indexOf("/", k.length + 1)),
                    b;
                0 === c.indexOf("/") ? b = c.split("/") : (b = a.split("?")[0], b = b.substring(k.length + l.length + 1, b.lastIndexOf("/")), b = b.split("/").concat(c.split("/")));
                for (var d = [], f = 0; f < b.length; f++) b[f] && (e.exists(b[f]) && "." != b[f]) && (".." == b[f] ? d.pop() : d.push(b[f]));
                return k + l + "/" + d.join("/")
            }
        };
        e.extend = function () {
            var c = Array.prototype.slice.call(arguments,
                0);
            if (1 < c.length) {
                for (var a = c[0], k = function (c, l) {
                    void 0 !== l && null !== l && (a[c] = l)
                }, l = 1; l < c.length; l++) e.foreach(c[l], k);
                return a
            }
            return null
        };
        var p = window.console = window.console || {
            log: function () {}
        };
        e.log = function () {
            var c = Array.prototype.slice.call(arguments, 0);
            "object" === typeof p.log ? p.log(c) : p.log.apply(p, c)
        };
        var a = e.userAgentMatch = function (c) {
            return null !== b.userAgent.toLowerCase().match(c)
        };
        e.isFF = d(/firefox/i);
        e.isChrome = d(/chrome/i);
        e.isIPod = d(/iP(hone|od)/i);
        e.isIPad = d(/iPad/i);
        e.isSafari602 =
            d(/Macintosh.*Mac OS X 10_8.*6\.0\.\d* Safari/i);
        e.isIETrident = function (c) {
            return c ? (c = parseFloat(c).toFixed(1), a(RegExp("trident/.+rv:\\s*" + c, "i"))) : a(/trident/i)
        };
        e.isMSIE = function (c) {
            return c ? (c = parseFloat(c).toFixed(1), a(RegExp("msie\\s*" + c, "i"))) : a(/msie/i)
        };
        e.isIE = function (c) {
            return c ? (c = parseFloat(c).toFixed(1), 11 <= c ? e.isIETrident(c) : e.isMSIE(c)) : e.isMSIE() || e.isIETrident()
        };
        e.isSafari = function () {
            return a(/safari/i) && !a(/chrome/i) && !a(/chromium/i) && !a(/android/i)
        };
        e.isIOS = function (c) {
            return c ?
                a(RegExp("iP(hone|ad|od).+\\sOS\\s" + c, "i")) : a(/iP(hone|ad|od)/i)
        };
        e.isAndroidNative = function (c) {
            return e.isAndroid(c, !0)
        };
        e.isAndroid = function (c, b) {
            return b && a(/chrome\/[123456789]/i) && !a(/chrome\/18/) ? !1 : c ? (e.isInt(c) && !/\./.test(c) && (c = "" + c + "."), a(RegExp("Android\\s*" + c, "i"))) : a(/Android/i)
        };
        e.isMobile = function () {
            return e.isIOS() || e.isAndroid()
        };
        e.saveCookie = function (c, a) {
            j.cookie = "jwplayer." + c + "\x3d" + a + "; path\x3d/"
        };
        e.getCookies = function () {
            for (var c = {}, a = j.cookie.split("; "), k = 0; k < a.length; k++) {
                var l =
                    a[k].split("\x3d");
                0 === l[0].indexOf("jwplayer.") && (c[l[0].substring(9, l[0].length)] = l[1])
            }
            return c
        };
        e.isInt = function (c) {
            return 0 === c % 1
        };
        e.typeOf = function (c) {
            var a = typeof c;
            return "object" === a ? !c ? "null" : c instanceof Array ? "array" : a : a
        };
        e.translateEventResponse = function (c, a) {
            var k = e.extend({}, a);
            if (c == h.events.JWPLAYER_FULLSCREEN && !k.fullscreen) k.fullscreen = "true" === k.message, delete k.message;
            else if ("object" == typeof k.data) {
                var l = k.data;
                delete k.data;
                k = e.extend(k, l)
            } else "object" == typeof k.metadata &&
                e.deepReplaceKeyName(k.metadata, ["__dot__", "__spc__", "__dsh__", "__default__"], [".", " ", "-", "default"]);
            e.foreach(["position", "duration", "offset"], function (c, l) {
                k[l] && (k[l] = Math.round(1E3 * k[l]) / 1E3)
            });
            return k
        };
        e.flashVersion = function () {
            if (e.isAndroid()) return 0;
            var c = b.plugins,
                a;
            try {
                if ("undefined" !== c && (a = c["Shockwave Flash"])) return parseInt(a.description.replace(/\D+(\d+)\..*/, "$1"), 10)
            } catch (k) {}
            if ("undefined" != typeof g.ActiveXObject) try {
                if (a = new g.ActiveXObject("ShockwaveFlash.ShockwaveFlash")) return parseInt(a.GetVariable("$version").split(" ")[1].split(",")[0],
                    10)
            } catch (l) {}
            return 0
        };
        e.getScriptPath = function (c) {
            for (var a = j.getElementsByTagName("script"), k = 0; k < a.length; k++) {
                var l = a[k].src;
                if (l && 0 <= l.indexOf(c)) return l.substr(0, l.indexOf(c))
            }
            return ""
        };
        e.deepReplaceKeyName = function (c, a, k) {
            switch (h.utils.typeOf(c)) {
            case "array":
                for (var l = 0; l < c.length; l++) c[l] = h.utils.deepReplaceKeyName(c[l], a, k);
                break;
            case "object":
                e.foreach(c, function (l, b) {
                    var e;
                    if (a instanceof Array && k instanceof Array) {
                        if (a.length != k.length) return;
                        e = a
                    } else e = [a];
                    for (var d = l, f = 0; f < e.length; f++) d =
                        d.replace(RegExp(a[f], "g"), k[f]);
                    c[d] = h.utils.deepReplaceKeyName(b, a, k);
                    l != d && delete c[l]
                })
            }
            return c
        };
        var f = e.pluginPathType = {
            ABSOLUTE: 0,
            RELATIVE: 1,
            CDN: 2
        };
        e.getPluginPathType = function (c) {
            if ("string" == typeof c) {
                c = c.split("?")[0];
                var a = c.indexOf("://");
                if (0 < a) return f.ABSOLUTE;
                var k = c.indexOf("/");
                c = e.extension(c);
                return 0 > a && 0 > k && (!c || !isNaN(c)) ? f.CDN : f.RELATIVE
            }
        };
        e.getPluginName = function (c) {
            return c.replace(/^(.*\/)?([^-]*)-?.*\.(swf|js)$/, "$2")
        };
        e.getPluginVersion = function (c) {
            return c.replace(/[^-]*-?([^\.]*).*$/,
                "$1")
        };
        e.isYouTube = function (c) {
            return /^(http|\/\/).*(youtube\.com|youtu\.be)\/.+/.test(c)
        };
        e.youTubeID = function (c) {
            try {
                return /v[=\/]([^?&]*)|youtu\.be\/([^?]*)|^([\w-]*)$/i.exec(c).slice(1).join("").replace("?", "")
            } catch (a) {
                return ""
            }
        };
        e.isRtmp = function (c, a) {
            return 0 === c.indexOf("rtmp") || "rtmp" == a
        };
        e.foreach = function (c, a) {
            var k, l;
            for (k in c) "function" == e.typeOf(c.hasOwnProperty) ? c.hasOwnProperty(k) && (l = c[k], a(k, l)) : (l = c[k], a(k, l))
        };
        e.isHTTPS = function () {
            return 0 === g.location.href.indexOf("https")
        };
        e.repo = function () {
            var c = "http://p.jwpcdn.com/" + h.version.split(/\W/).splice(0, 2).join("/") + "/";
            try {
                e.isHTTPS() && (c = c.replace("http://", "https://ssl."))
            } catch (a) {}
            return c
        };
        e.ajax = function (c, a, k, l) {
            var b, d = !1;
            0 < c.indexOf("#") && (c = c.replace(/#.*$/, ""));
            if (c && 0 <= c.indexOf("://") && c.split("/")[2] != g.location.href.split("/")[2] && e.exists(g.XDomainRequest)) b = new g.XDomainRequest, b.onload = m(b, c, a, k, l), b.ontimeout = b.onprogress = function () {}, b.timeout = 5E3;
            else if (e.exists(g.XMLHttpRequest)) {
                var f = b = new g.XMLHttpRequest,
                    j = c;
                b.onreadystatechange = function () {
                    if (4 === f.readyState) switch (f.status) {
                    case 200:
                        m(f, j, a, k, l)();
                        break;
                    case 404:
                        k("File not found", j, f)
                    }
                }
            } else return k && k("", c, b), b;
            b.overrideMimeType && b.overrideMimeType("text/xml");
            var p = c,
                h = b;
            b.onerror = function () {
                k("Error loading file", p, h)
            };
            try {
                b.open("GET", c, !0)
            } catch (F) {
                d = !0
            }
            setTimeout(function () {
                if (d) k && k(c, c, b);
                else try {
                    b.send()
                } catch (a) {
                    k && k(c, c, b)
                }
            }, 0);
            return b
        };
        e.parseXML = function (c) {
            var a;
            try {
                if (g.DOMParser) {
                    if (a = (new g.DOMParser).parseFromString(c, "text/xml"),
                        a.childNodes && a.childNodes.length && "parsererror" == a.childNodes[0].firstChild.nodeName) return
                } else a = new g.ActiveXObject("Microsoft.XMLDOM"), a.async = "false", a.loadXML(c)
            } catch (b) {
                return
            }
            return a
        };
        e.filterPlaylist = function (a, b, k) {
            var l = [],
                d, f, g, j;
            for (d = 0; d < a.length; d++)
                if (f = e.extend({}, a[d]), f.sources = e.filterSources(f.sources, !1, k), 0 < f.sources.length) {
                    for (g = 0; g < f.sources.length; g++) j = f.sources[g], j.label || (j.label = g.toString());
                    l.push(f)
                }
            if (b && 0 === l.length)
                for (d = 0; d < a.length; d++)
                    if (f = e.extend({}, a[d]),
                        f.sources = e.filterSources(f.sources, !0, k), 0 < f.sources.length) {
                        for (g = 0; g < f.sources.length; g++) j = f.sources[g], j.label || (j.label = g.toString());
                        l.push(f)
                    }
            return l
        };
        e.between = function (a, b, k) {
            return Math.max(Math.min(a, k), b)
        };
        e.filterSources = function (a, b, k) {
            var l, d;
            if (a) {
                d = [];
                for (var f = 0; f < a.length; f++) {
                    var g = e.extend({}, a[f]),
                        j = g.file,
                        p = g.type;
                    j && (g.file = j = e.trim("" + j), p || (p = e.extension(j), g.type = p = e.extensionmap.extType(p)), b ? h.embed.flashCanPlay(j, p) && (l || (l = p), p == l && d.push(g)) : h.embed.html5CanPlay(j,
                        p, k) && (l || (l = p), p == l && d.push(g)))
                }
            }
            return d
        };
        e.canPlayHTML5 = function (a) {
            a = e.extensionmap.types[a];
            return !!a && !!h.vid.canPlayType && !!h.vid.canPlayType(a)
        };
        e.seconds = function (a) {
            a = a.replace(",", ".");
            var b = a.split(":"),
                k = 0;
            "s" == a.slice(-1) ? k = parseFloat(a) : "m" == a.slice(-1) ? k = 60 * parseFloat(a) : "h" == a.slice(-1) ? k = 3600 * parseFloat(a) : 1 < b.length ? (k = parseFloat(b[b.length - 1]), k += 60 * parseFloat(b[b.length - 2]), 3 == b.length && (k += 3600 * parseFloat(b[b.length - 3]))) : k = parseFloat(a);
            return k
        };
        e.serialize = function (a) {
            return null ===
                a ? null : "true" == a.toString().toLowerCase() ? !0 : "false" == a.toString().toLowerCase() ? !1 : isNaN(Number(a)) || 5 < a.length || 0 === a.length ? a : Number(a)
        };
        e.addClass = function (a, b) {
            a.className = a.className + " " + b
        };
        e.removeClass = function (a, b) {
            a.className = a.className.replace(RegExp(" *" + b, "g"), " ")
        }
    }(jwplayer), function (h) {
        function d(a) {
            var b = document.createElement("style");
            a && b.appendChild(document.createTextNode(a));
            b.type = "text/css";
            document.getElementsByTagName("head")[0].appendChild(b);
            return b
        }

        function m(a, l, c) {
            if (!b.exists(l)) return "";
            c = c ? " !important" : "";
            return "string" === typeof l && isNaN(l) ? /png|gif|jpe?g/i.test(l) && 0 > l.indexOf("url") ? "url(" + l + ")" : l + c : 0 === l || "z-index" === a || "opacity" === a ? "" + l + c : /color/i.test(a) ? "#" + b.pad(l.toString(16).replace(/^0x/i, ""), 6) + c : Math.ceil(l) + "px" + c
        }

        function j(a, b) {
            for (var c = 0; c < a.length; c++) {
                var e = a[c],
                    d, f;
                if (void 0 !== e && null !== e)
                    for (d in b) {
                        f = d;
                        f = f.split("-");
                        for (var g = 1; g < f.length; g++) f[g] = f[g].charAt(0).toUpperCase() + f[g].slice(1);
                        f = f.join("");
                        e.style[f] !== b[d] && (e.style[f] = b[d])
                    }
            }
        }

        function g(b) {
            var l =
                e[b].sheet,
                d, f, g;
            if (l) {
                d = l.cssRules;
                f = c[b];
                g = b;
                var j = a[g];
                g += " { ";
                for (var p in j) g += p + ": " + j[p] + "; ";
                g += "}";
                if (void 0 !== f && f < d.length && d[f].selectorText === b) {
                    if (g === d[f].cssText) return;
                    l.deleteRule(f)
                } else f = d.length, c[b] = f;
                try {
                    l.insertRule(g, f)
                } catch (h) {}
            }
        }
        var b = h.utils,
            e = {},
            p, a = {},
            f = null,
            c = {};
        b.cssKeyframes = function (a, b) {
            var c = e.keyframes;
            c || (c = d(), e.keyframes = c);
            var c = c.sheet,
                f = "@keyframes " + a + " { " + b + " }";
            try {
                c.insertRule(f, c.cssRules.length)
            } catch (g) {}
            f = f.replace(/(keyframes|transform)/g, "-webkit-$1");
            try {
                c.insertRule(f, c.cssRules.length)
            } catch (j) {}
        };
        var n = b.css = function (b, c, j) {
            a[b] || (a[b] = {});
            var h = a[b];
            j = j || !1;
            var u = !1,
                n, q;
            for (n in c) q = m(n, c[n], j), "" !== q ? q !== h[n] && (h[n] = q, u = !0) : void 0 !== h[n] && (delete h[n], u = !0);
            if (u) {
                if (!e[b]) {
                    c = p && p.sheet && p.sheet.cssRules && p.sheet.cssRules.length || 0;
                    if (!p || 5E4 < c) p = d();
                    e[b] = p
                }
                null !== f ? f.styleSheets[b] = a[b] : g(b)
            }
        };
        n.style = function (a, b, c) {
            if (!(void 0 === a || null === a)) {
                void 0 === a.length && (a = [a]);
                var d = {},
                    e;
                for (e in b) d[e] = m(e, b[e]);
                if (null !== f && !c) {
                    b = (b = a.__cssRules) || {};
                    for (var g in d) b[g] = d[g];
                    a.__cssRules = b;
                    0 > f.elements.indexOf(a) && f.elements.push(a)
                } else j(a, d)
            }
        };
        n.block = function (a) {
            null === f && (f = {
                id: a,
                styleSheets: {},
                elements: []
            })
        };
        n.unblock = function (a) {
            if (f && (!a || f.id === a)) {
                for (var b in f.styleSheets) g(b);
                for (a = 0; a < f.elements.length; a++) b = f.elements[a], j(b, b.__cssRules);
                f = null
            }
        };
        b.clearCss = function (b) {
            for (var c in a) 0 <= c.indexOf(b) && delete a[c];
            for (var f in e) 0 <= f.indexOf(b) && g(f)
        };
        b.transform = function (a, b) {
            var c = {};
            b = b || "";
            c.transform = b;
            c["-webkit-transform"] =
                b;
            c["-ms-transform"] = b;
            c["-moz-transform"] = b;
            c["-o-transform"] = b;
            "string" === typeof a ? n(a, c) : n.style(a, c)
        };
        b.dragStyle = function (a, b) {
            n(a, {
                "-webkit-user-select": b,
                "-moz-user-select": b,
                "-ms-user-select": b,
                "-webkit-user-drag": b,
                "user-select": b,
                "user-drag": b
            })
        };
        b.transitionStyle = function (a, b) {
            navigator.userAgent.match(/5\.\d(\.\d)? safari/i) || n(a, {
                "-webkit-transition": b,
                "-moz-transition": b,
                "-o-transition": b,
                transition: b
            })
        };
        b.rotate = function (a, c) {
            b.transform(a, "rotate(" + c + "deg)")
        };
        b.rgbHex = function (a) {
            a =
                String(a).replace("#", "");
            3 === a.length && (a = a[0] + a[0] + a[1] + a[1] + a[2] + a[2]);
            return "#" + a.substr(-6)
        };
        b.hexToRgba = function (a, b) {
            var c = "rgb",
                f = [parseInt(a.substr(1, 2), 16), parseInt(a.substr(3, 2), 16), parseInt(a.substr(5, 2), 16)];
            void 0 !== b && 100 !== b && (c += "a", f.push(b / 100));
            return c + "(" + f.join(",") + ")"
        }
    }(jwplayer), function (h) {
        var d = h.foreach,
            m = {
                mp4: "video/mp4",
                ogg: "video/ogg",
                oga: "audio/ogg",
                vorbis: "audio/ogg",
                webm: "video/webm",
                aac: "audio/mp4",
                mp3: "audio/mpeg",
                hls: "application/vnd.apple.mpegurl"
            },
            j = {
                mp4: m.mp4,
                f4v: m.mp4,
                m4v: m.mp4,
                mov: m.mp4,
                m4a: m.aac,
                f4a: m.aac,
                aac: m.aac,
                mp3: m.mp3,
                ogv: m.ogg,
                ogg: m.ogg,
                oga: m.vorbis,
                vorbis: m.vorbis,
                webm: m.webm,
                m3u8: m.hls,
                m3u: m.hls,
                hls: m.hls
            },
            g = h.extensionmap = {};
        d(j, function (b, d) {
            g[b] = {
                html5: d
            }
        });
        d({
            flv: "video",
            f4v: "video",
            mov: "video",
            m4a: "video",
            m4v: "video",
            mp4: "video",
            aac: "video",
            f4a: "video",
            mp3: "sound",
            smil: "rtmp",
            m3u8: "hls",
            hls: "hls"
        }, function (b, d) {
            g[b] || (g[b] = {});
            g[b].flash = d
        });
        g.types = m;
        g.mimeType = function (b) {
            var e;
            d(m, function (d, a) {
                !e && a == b && (e = d)
            });
            return e
        };
        g.extType =
            function (b) {
                return g.mimeType(j[b])
            }
    }(jwplayer.utils), function (h) {
        var d = h.loaderstatus = {
                NEW: 0,
                LOADING: 1,
                ERROR: 2,
                COMPLETE: 3
            },
            m = document;
        h.scriptloader = function (j) {
            function g(b) {
                a = d.ERROR;
                p.sendEvent(e.ERROR, b)
            }

            function b(b) {
                a = d.COMPLETE;
                p.sendEvent(e.COMPLETE, b)
            }
            var e = jwplayer.events,
                p = h.extend(this, new e.eventdispatcher),
                a = d.NEW;
            this.load = function () {
                if (a == d.NEW) {
                    var f = h.scriptloader.loaders[j];
                    if (f && (a = f.getStatus(), 2 > a)) {
                        f.addEventListener(e.ERROR, g);
                        f.addEventListener(e.COMPLETE, b);
                        return
                    }
                    var c =
                        m.createElement("script");
                    c.addEventListener ? (c.onload = b, c.onerror = g) : c.readyState && (c.onreadystatechange = function (a) {
                        ("loaded" == c.readyState || "complete" == c.readyState) && b(a)
                    });
                    m.getElementsByTagName("head")[0].appendChild(c);
                    c.src = j;
                    a = d.LOADING;
                    h.scriptloader.loaders[j] = this
                }
            };
            this.getStatus = function () {
                return a
            }
        };
        h.scriptloader.loaders = {}
    }(jwplayer.utils), function (h) {
        h.trim = function (d) {
            return d.replace(/^\s*/, "").replace(/\s*$/, "")
        };
        h.pad = function (d, h, j) {
            for (j || (j = "0"); d.length < h;) d = j + d;
            return d
        };
        h.xmlAttribute = function (d, h) {
            for (var j = 0; j < d.attributes.length; j++)
                if (d.attributes[j].name && d.attributes[j].name.toLowerCase() == h.toLowerCase()) return d.attributes[j].value.toString();
            return ""
        };
        h.extension = function (d) {
            if (!d || "rtmp" == d.substr(0, 4)) return "";
            var h;
            h = d.match(/manifest\(format=(.*),audioTrack/);
            h = !h || !h[1] ? !1 : h[1].split("-")[0];
            if (h) return h;
            d = d.substring(d.lastIndexOf("/") + 1, d.length).split("?")[0].split("#")[0];
            if (-1 < d.lastIndexOf(".")) return d.substr(d.lastIndexOf(".") + 1, d.length).toLowerCase()
        };
        h.stringToColor = function (d) {
            d = d.replace(/(#|0x)?([0-9A-F]{3,6})$/gi, "$2");
            3 == d.length && (d = d.charAt(0) + d.charAt(0) + d.charAt(1) + d.charAt(1) + d.charAt(2) + d.charAt(2));
            return parseInt(d, 16)
        }
    }(jwplayer.utils), function (h) {
        var d = "touchmove",
            m = "touchstart";
        h.touch = function (j) {
            function g(f) {
                f.type == m ? (a = !0, c = e(k.DRAG_START, f)) : f.type == d ? a && (n || (b(k.DRAG_START, f, c), n = !0), b(k.DRAG, f)) : (a && (n ? b(k.DRAG_END, f) : (f.cancelBubble = !0, b(k.TAP, f))), a = n = !1, c = null)
            }

            function b(a, b, c) {
                if (f[a] && (b.preventManipulation && b.preventManipulation(),
                    b.preventDefault && b.preventDefault(), b = c ? c : e(a, b))) f[a](b)
            }

            function e(a, b) {
                var f = null;
                b.touches && b.touches.length ? f = b.touches[0] : b.changedTouches && b.changedTouches.length && (f = b.changedTouches[0]);
                if (!f) return null;
                var d = p.getBoundingClientRect(),
                    f = {
                        type: a,
                        target: p,
                        x: f.pageX - window.pageXOffset - d.left,
                        y: f.pageY,
                        deltaX: 0,
                        deltaY: 0
                    };
                a != k.TAP && c && (f.deltaX = f.x - c.x, f.deltaY = f.y - c.y);
                return f
            }
            var p = j,
                a = !1,
                f = {},
                c = null,
                n = !1,
                k = h.touchEvents;
            document.addEventListener(d, g);
            document.addEventListener("touchend",
                function (f) {
                    a && n && b(k.DRAG_END, f);
                    a = n = !1;
                    c = null
                });
            document.addEventListener("touchcancel", g);
            j.addEventListener(m, g);
            j.addEventListener("touchend", g);
            this.addEventListener = function (a, b) {
                f[a] = b
            };
            this.removeEventListener = function (a) {
                delete f[a]
            };
            return this
        }
    }(jwplayer.utils), function (h) {
        h.touchEvents = {
            DRAG: "jwplayerDrag",
            DRAG_START: "jwplayerDragStart",
            DRAG_END: "jwplayerDragEnd",
            TAP: "jwplayerTap"
        }
    }(jwplayer.utils), function (h) {
        h.key = function (d) {
            var m, j, g;
            this.edition = function () {
                return g && g.getTime() <
                    (new Date).getTime() ? "invalid" : m
            };
            this.token = function () {
                return j
            };
            h.exists(d) || (d = "");
            try {
                d = h.tea.decrypt(d, "36QXq4W@GSBV^teR");
                var b = d.split("/");
                (m = b[0]) ? /^(free|pro|premium|enterprise|ads)$/i.test(m) ? (j = b[1], b[2] && 0 < parseInt(b[2]) && (g = new Date, g.setTime(String(b[2])))) : m = "invalid": m = "free"
            } catch (e) {
                m = "invalid"
            }
        }
    }(jwplayer.utils), function (h) {
        var d = h.tea = {};
        d.encrypt = function (g, b) {
            if (0 == g.length) return "";
            var e = d.strToLongs(j.encode(g));
            1 >= e.length && (e[1] = 0);
            for (var h = d.strToLongs(j.encode(b).slice(0,
                16)), a = e.length, f = e[a - 1], c = e[0], n, k = Math.floor(6 + 52 / a), l = 0; 0 < k--;) {
                l += 2654435769;
                n = l >>> 2 & 3;
                for (var r = 0; r < a; r++) c = e[(r + 1) % a], f = (f >>> 5 ^ c << 2) + (c >>> 3 ^ f << 4) ^ (l ^ c) + (h[r & 3 ^ n] ^ f), f = e[r] += f
            }
            e = d.longsToStr(e);
            return m.encode(e)
        };
        d.decrypt = function (g, b) {
            if (0 == g.length) return "";
            for (var e = d.strToLongs(m.decode(g)), h = d.strToLongs(j.encode(b).slice(0, 16)), a = e.length, f = e[a - 1], c = e[0], n, k = 2654435769 * Math.floor(6 + 52 / a); 0 != k;) {
                n = k >>> 2 & 3;
                for (var l = a - 1; 0 <= l; l--) f = e[0 < l ? l - 1 : a - 1], f = (f >>> 5 ^ c << 2) + (c >>> 3 ^ f << 4) ^ (k ^ c) + (h[l & 3 ^
                    n] ^ f), c = e[l] -= f;
                k -= 2654435769
            }
            e = d.longsToStr(e);
            e = e.replace(/\0+$/, "");
            return j.decode(e)
        };
        d.strToLongs = function (d) {
            for (var b = Array(Math.ceil(d.length / 4)), e = 0; e < b.length; e++) b[e] = d.charCodeAt(4 * e) + (d.charCodeAt(4 * e + 1) << 8) + (d.charCodeAt(4 * e + 2) << 16) + (d.charCodeAt(4 * e + 3) << 24);
            return b
        };
        d.longsToStr = function (d) {
            for (var b = Array(d.length), e = 0; e < d.length; e++) b[e] = String.fromCharCode(d[e] & 255, d[e] >>> 8 & 255, d[e] >>> 16 & 255, d[e] >>> 24 & 255);
            return b.join("")
        };
        var m = {
                code: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\x3d",
                encode: function (d, b) {
                    var e, h, a, f, c = [],
                        n = "",
                        k, l, r = m.code;
                    l = ("undefined" == typeof b ? 0 : b) ? j.encode(d) : d;
                    k = l.length % 3;
                    if (0 < k)
                        for (; 3 > k++;) n += "\x3d", l += "\x00";
                    for (k = 0; k < l.length; k += 3) e = l.charCodeAt(k), h = l.charCodeAt(k + 1), a = l.charCodeAt(k + 2), f = e << 16 | h << 8 | a, e = f >> 18 & 63, h = f >> 12 & 63, a = f >> 6 & 63, f &= 63, c[k / 3] = r.charAt(e) + r.charAt(h) + r.charAt(a) + r.charAt(f);
                    c = c.join("");
                    return c = c.slice(0, c.length - n.length) + n
                },
                decode: function (d, b) {
                    b = "undefined" == typeof b ? !1 : b;
                    var e, h, a, f, c, n = [],
                        k, l = m.code;
                    k = b ? j.decode(d) : d;
                    for (var r =
                        0; r < k.length; r += 4) e = l.indexOf(k.charAt(r)), h = l.indexOf(k.charAt(r + 1)), f = l.indexOf(k.charAt(r + 2)), c = l.indexOf(k.charAt(r + 3)), a = e << 18 | h << 12 | f << 6 | c, e = a >>> 16 & 255, h = a >>> 8 & 255, a &= 255, n[r / 4] = String.fromCharCode(e, h, a), 64 == c && (n[r / 4] = String.fromCharCode(e, h)), 64 == f && (n[r / 4] = String.fromCharCode(e));
                    f = n.join("");
                    return b ? j.decode(f) : f
                }
            },
            j = {
                encode: function (d) {
                    d = d.replace(/[\u0080-\u07ff]/g, function (b) {
                        b = b.charCodeAt(0);
                        return String.fromCharCode(192 | b >> 6, 128 | b & 63)
                    });
                    return d = d.replace(/[\u0800-\uffff]/g, function (b) {
                        b =
                            b.charCodeAt(0);
                        return String.fromCharCode(224 | b >> 12, 128 | b >> 6 & 63, 128 | b & 63)
                    })
                },
                decode: function (d) {
                    d = d.replace(/[\u00e0-\u00ef][\u0080-\u00bf][\u0080-\u00bf]/g, function (b) {
                        b = (b.charCodeAt(0) & 15) << 12 | (b.charCodeAt(1) & 63) << 6 | b.charCodeAt(2) & 63;
                        return String.fromCharCode(b)
                    });
                    return d = d.replace(/[\u00c0-\u00df][\u0080-\u00bf]/g, function (b) {
                        b = (b.charCodeAt(0) & 31) << 6 | b.charCodeAt(1) & 63;
                        return String.fromCharCode(b)
                    })
                }
            }
    }(jwplayer.utils), function (h) {
        h.events = {
            COMPLETE: "COMPLETE",
            ERROR: "ERROR",
            API_READY: "jwplayerAPIReady",
            JWPLAYER_READY: "jwplayerReady",
            JWPLAYER_FULLSCREEN: "jwplayerFullscreen",
            JWPLAYER_RESIZE: "jwplayerResize",
            JWPLAYER_ERROR: "jwplayerError",
            JWPLAYER_SETUP_ERROR: "jwplayerSetupError",
            JWPLAYER_MEDIA_BEFOREPLAY: "jwplayerMediaBeforePlay",
            JWPLAYER_MEDIA_BEFORECOMPLETE: "jwplayerMediaBeforeComplete",
            JWPLAYER_COMPONENT_SHOW: "jwplayerComponentShow",
            JWPLAYER_COMPONENT_HIDE: "jwplayerComponentHide",
            JWPLAYER_MEDIA_BUFFER: "jwplayerMediaBuffer",
            JWPLAYER_MEDIA_BUFFER_FULL: "jwplayerMediaBufferFull",
            JWPLAYER_MEDIA_ERROR: "jwplayerMediaError",
            JWPLAYER_MEDIA_LOADED: "jwplayerMediaLoaded",
            JWPLAYER_MEDIA_COMPLETE: "jwplayerMediaComplete",
            JWPLAYER_MEDIA_SEEK: "jwplayerMediaSeek",
            JWPLAYER_MEDIA_TIME: "jwplayerMediaTime",
            JWPLAYER_MEDIA_VOLUME: "jwplayerMediaVolume",
            JWPLAYER_MEDIA_META: "jwplayerMediaMeta",
            JWPLAYER_MEDIA_MUTE: "jwplayerMediaMute",
            JWPLAYER_MEDIA_LEVELS: "jwplayerMediaLevels",
            JWPLAYER_MEDIA_LEVEL_CHANGED: "jwplayerMediaLevelChanged",
            JWPLAYER_CAPTIONS_CHANGED: "jwplayerCaptionsChanged",
            JWPLAYER_CAPTIONS_LIST: "jwplayerCaptionsList",
            JWPLAYER_CAPTIONS_LOADED: "jwplayerCaptionsLoaded",
            JWPLAYER_PLAYER_STATE: "jwplayerPlayerState",
            state: {
                BUFFERING: "BUFFERING",
                IDLE: "IDLE",
                PAUSED: "PAUSED",
                PLAYING: "PLAYING"
            },
            JWPLAYER_PLAYLIST_LOADED: "jwplayerPlaylistLoaded",
            JWPLAYER_PLAYLIST_ITEM: "jwplayerPlaylistItem",
            JWPLAYER_PLAYLIST_COMPLETE: "jwplayerPlaylistComplete",
            JWPLAYER_DISPLAY_CLICK: "jwplayerViewClick",
            JWPLAYER_VIEW_TAB_FOCUS: "jwplayerViewTabFocus",
            JWPLAYER_CONTROLS: "jwplayerViewControls",
            JWPLAYER_USER_ACTION: "jwplayerUserAction",
            JWPLAYER_INSTREAM_CLICK: "jwplayerInstreamClicked",
            JWPLAYER_INSTREAM_DESTROYED: "jwplayerInstreamDestroyed",
            JWPLAYER_AD_TIME: "jwplayerAdTime",
            JWPLAYER_AD_ERROR: "jwplayerAdError",
            JWPLAYER_AD_CLICK: "jwplayerAdClicked",
            JWPLAYER_AD_COMPLETE: "jwplayerAdComplete",
            JWPLAYER_AD_IMPRESSION: "jwplayerAdImpression",
            JWPLAYER_AD_COMPANIONS: "jwplayerAdCompanions",
            JWPLAYER_AD_SKIPPED: "jwplayerAdSkipped",
            JWPLAYER_AD_PLAY: "jwplayerAdPlay",
            JWPLAYER_AD_PAUSE: "jwplayerAdPause",
            JWPLAYER_AD_META: "jwplayerAdMeta",
            JWPLAYER_CAST_AVAILABLE: "jwplayerCastAvailable",
            JWPLAYER_CAST_SESSION: "jwplayerCastSession",
            JWPLAYER_CAST_AD_CHANGED: "jwplayerCastAdChanged"
        }
    }(jwplayer),
    function (h) {
        var d = h.utils;
        h.events.eventdispatcher = function (m, j) {
            function g(b, a, f) {
                if (b)
                    for (var c = 0; c < b.length; c++) {
                        var e = b[c];
                        if (e) {
                            null !== e.count && 0 === --e.count && delete b[c];
                            try {
                                e.listener(a)
                            } catch (g) {
                                d.log('Error handling "' + f + '" event listener [' + c + "]: " + g.toString(), e.listener, a)
                            }
                        }
                    }
            }
            var b, e;
            this.resetEventListeners = function () {
                b = {};
                e = []
            };
            this.resetEventListeners();
            this.addEventListener = function (e, a, f) {
                try {
                    d.exists(b[e]) || (b[e] = []), "string" == d.typeOf(a) && (a = (new Function("return " + a))()), b[e].push({
                        listener: a,
                        count: f || null
                    })
                } catch (c) {
                    d.log("error", c)
                }
                return !1
            };
            this.removeEventListener = function (e, a) {
                if (b[e]) {
                    try {
                        if (void 0 === a) {
                            b[e] = [];
                            return
                        }
                        for (var f = 0; f < b[e].length; f++)
                            if (b[e][f].listener.toString() == a.toString()) {
                                b[e].splice(f, 1);
                                break
                            }
                    } catch (c) {
                        d.log("error", c)
                    }
                    return !1
                }
            };
            this.addGlobalListener = function (b, a) {
                try {
                    "string" == d.typeOf(b) && (b = (new Function("return " + b))()), e.push({
                        listener: b,
                        count: a || null
                    })
                } catch (f) {
                    d.log("error", f)
                }
                return !1
            };
            this.removeGlobalListener = function (b) {
                if (b) {
                    try {
                        for (var a = e.length; a--;) e[a].listener.toString() ==
                            b.toString() && e.splice(a, 1)
                    } catch (f) {
                        d.log("error", f)
                    }
                    return !1
                }
            };
            this.sendEvent = function (p, a) {
                d.exists(a) || (a = {});
                d.extend(a, {
                    id: m,
                    version: h.version,
                    type: p
                });
                j && d.log(p, a);
                g(b[p], a, p);
                g(e, a, p)
            }
        }
    }(window.jwplayer), function (h) {
        var d = {},
            m = {};
        h.plugins = function () {};
        h.plugins.loadPlugins = function (j, g) {
            m[j] = new h.plugins.pluginloader(new h.plugins.model(d), g);
            return m[j]
        };
        h.plugins.registerPlugin = function (j, g, b, e) {
            var p = h.utils.getPluginName(j);
            d[p] || (d[p] = new h.plugins.plugin(j));
            d[p].registerPlugin(j,
                g, b, e)
        }
    }(jwplayer), function (h) {
        h.plugins.model = function (d) {
            this.addPlugin = function (m) {
                var j = h.utils.getPluginName(m);
                d[j] || (d[j] = new h.plugins.plugin(m));
                return d[j]
            };
            this.getPlugins = function () {
                return d
            }
        }
    }(jwplayer), function (h) {
        var d = jwplayer.utils,
            m = jwplayer.events;
        h.pluginmodes = {
            FLASH: 0,
            JAVASCRIPT: 1,
            HYBRID: 2
        };
        h.plugin = function (j) {
            function g() {
                switch (d.getPluginPathType(j)) {
                case d.pluginPathType.ABSOLUTE:
                    return j;
                case d.pluginPathType.RELATIVE:
                    return d.getAbsolutePath(j, window.location.href)
                }
            }

            function b() {
                n =
                    setTimeout(function () {
                        p = d.loaderstatus.COMPLETE;
                        k.sendEvent(m.COMPLETE)
                    }, 1E3)
            }

            function e() {
                p = d.loaderstatus.ERROR;
                k.sendEvent(m.ERROR)
            }
            var p = d.loaderstatus.NEW,
                a, f, c, n, k = new m.eventdispatcher;
            d.extend(this, k);
            this.load = function () {
                if (p == d.loaderstatus.NEW)
                    if (0 < j.lastIndexOf(".swf")) a = j, p = d.loaderstatus.COMPLETE, k.sendEvent(m.COMPLETE);
                    else if (d.getPluginPathType(j) == d.pluginPathType.CDN) p = d.loaderstatus.COMPLETE, k.sendEvent(m.COMPLETE);
                else {
                    p = d.loaderstatus.LOADING;
                    var c = new d.scriptloader(g());
                    c.addEventListener(m.COMPLETE,
                        b);
                    c.addEventListener(m.ERROR, e);
                    c.load()
                }
            };
            this.registerPlugin = function (b, e, g, j) {
                n && (clearTimeout(n), n = void 0);
                c = e;
                g && j ? (a = j, f = g) : "string" == typeof g ? a = g : "function" == typeof g ? f = g : !g && !j && (a = b);
                p = d.loaderstatus.COMPLETE;
                k.sendEvent(m.COMPLETE)
            };
            this.getStatus = function () {
                return p
            };
            this.getPluginName = function () {
                return d.getPluginName(j)
            };
            this.getFlashPath = function () {
                if (a) switch (d.getPluginPathType(a)) {
                case d.pluginPathType.ABSOLUTE:
                    return a;
                case d.pluginPathType.RELATIVE:
                    return 0 < j.lastIndexOf(".swf") ?
                        d.getAbsolutePath(a, window.location.href) : d.getAbsolutePath(a, g())
                }
                return null
            };
            this.getJS = function () {
                return f
            };
            this.getTarget = function () {
                return c
            };
            this.getPluginmode = function () {
                if ("undefined" != typeof a && "undefined" != typeof f) return h.pluginmodes.HYBRID;
                if ("undefined" != typeof a) return h.pluginmodes.FLASH;
                if ("undefined" != typeof f) return h.pluginmodes.JAVASCRIPT
            };
            this.getNewInstance = function (a, b, c) {
                return new f(a, b, c)
            };
            this.getURL = function () {
                return j
            }
        }
    }(jwplayer.plugins), function (h) {
        var d = h.utils,
            m =
            h.events,
            j = d.foreach;
        h.plugins.pluginloader = function (g, b) {
            function e() {
                c && l.sendEvent(m.ERROR, {
                    message: n
                });
                f || (f = !0, a = d.loaderstatus.COMPLETE, l.sendEvent(m.COMPLETE))
            }

            function p() {
                k || e();
                if (!f && !c) {
                    var a = 0,
                        b = g.getPlugins();
                    d.foreach(k, function (f) {
                        f = d.getPluginName(f);
                        var g = b[f];
                        f = g.getJS();
                        var l = g.getTarget(),
                            g = g.getStatus();
                        if (g == d.loaderstatus.LOADING || g == d.loaderstatus.NEW) a++;
                        else if (f && (!l || parseFloat(l) > parseFloat(h.version))) c = !0, n = "Incompatible player version", e()
                    });
                    0 === a && e()
                }
            }
            var a = d.loaderstatus.NEW,
                f = !1,
                c = !1,
                n, k = b,
                l = new m.eventdispatcher;
            d.extend(this, l);
            this.setupPlugins = function (a, b, c) {
                var f = {
                        length: 0,
                        plugins: {}
                    },
                    e = 0,
                    l = {},
                    k = g.getPlugins();
                j(b.plugins, function (g, j) {
                    var h = d.getPluginName(g),
                        n = k[h],
                        p = n.getFlashPath(),
                        m = n.getJS(),
                        L = n.getURL();
                    p && (f.plugins[p] = d.extend({}, j), f.plugins[p].pluginmode = n.getPluginmode(), f.length++);
                    try {
                        if (m && b.plugins && b.plugins[L]) {
                            var r = document.createElement("div");
                            r.id = a.id + "_" + h;
                            r.style.position = "absolute";
                            r.style.top = 0;
                            r.style.zIndex = e + 10;
                            l[h] = n.getNewInstance(a,
                                d.extend({}, b.plugins[L]), r);
                            e++;
                            a.onReady(c(l[h], r, !0));
                            a.onResize(c(l[h], r))
                        }
                    } catch (O) {
                        d.log("ERROR: Failed to load " + h + ".")
                    }
                });
                a.plugins = l;
                return f
            };
            this.load = function () {
                if (!(d.exists(b) && "object" != d.typeOf(b))) {
                    a = d.loaderstatus.LOADING;
                    j(b, function (a) {
                        d.exists(a) && (a = g.addPlugin(a), a.addEventListener(m.COMPLETE, p), a.addEventListener(m.ERROR, r))
                    });
                    var c = g.getPlugins();
                    j(c, function (a, b) {
                        b.load()
                    })
                }
                p()
            };
            this.destroy = function () {
                l && (l.resetEventListeners(), l = null)
            };
            var r = this.pluginFailed = function () {
                c ||
                    (c = !0, n = "File not found", e())
            };
            this.getStatus = function () {
                return a
            }
        }
    }(jwplayer), function (h) {
        h.parsers = {
            localName: function (d) {
                return d ? d.localName ? d.localName : d.baseName ? d.baseName : "" : ""
            },
            textContent: function (d) {
                return d ? d.textContent ? h.utils.trim(d.textContent) : d.text ? h.utils.trim(d.text) : "" : ""
            },
            getChildNode: function (d, h) {
                return d.childNodes[h]
            },
            numChildren: function (d) {
                return d.childNodes ? d.childNodes.length : 0
            }
        }
    }(jwplayer), function (h) {
        var d = h.parsers;
        (d.jwparser = function () {}).parseEntry = function (m,
            j) {
            for (var g = [], b = [], e = h.utils.xmlAttribute, p = 0; p < m.childNodes.length; p++) {
                var a = m.childNodes[p];
                if ("jwplayer" == a.prefix) {
                    var f = d.localName(a);
                    "source" == f ? (delete j.sources, g.push({
                        file: e(a, "file"),
                        "default": e(a, "default"),
                        label: e(a, "label"),
                        type: e(a, "type")
                    })) : "track" == f ? (delete j.tracks, b.push({
                        file: e(a, "file"),
                        "default": e(a, "default"),
                        kind: e(a, "kind"),
                        label: e(a, "label")
                    })) : (j[f] = h.utils.serialize(d.textContent(a)), "file" == f && j.sources && delete j.sources)
                }
                j.file || (j.file = j.link)
            }
            if (g.length) {
                j.sources = [];
                for (p = 0; p < g.length; p++) 0 < g[p].file.length && (g[p]["default"] = "true" == g[p]["default"] ? !0 : !1, g[p].label.length || delete g[p].label, j.sources.push(g[p]))
            }
            if (b.length) {
                j.tracks = [];
                for (p = 0; p < b.length; p++) 0 < b[p].file.length && (b[p]["default"] = "true" == b[p]["default"] ? !0 : !1, b[p].kind = !b[p].kind.length ? "captions" : b[p].kind, b[p].label.length || delete b[p].label, j.tracks.push(b[p]))
            }
            return j
        }
    }(jwplayer), function (h) {
        var d = jwplayer.utils,
            m = d.xmlAttribute,
            j = h.localName,
            g = h.textContent,
            b = h.numChildren,
            e = h.mediaparser =
            function () {};
        e.parseGroup = function (h, a) {
            var f, c, n = [];
            for (c = 0; c < b(h); c++)
                if (f = h.childNodes[c], "media" == f.prefix && j(f)) switch (j(f).toLowerCase()) {
                case "content":
                    m(f, "duration") && (a.duration = d.seconds(m(f, "duration")));
                    0 < b(f) && (a = e.parseGroup(f, a));
                    m(f, "url") && (a.sources || (a.sources = []), a.sources.push({
                        file: m(f, "url"),
                        type: m(f, "type"),
                        width: m(f, "width"),
                        label: m(f, "label")
                    }));
                    break;
                case "title":
                    a.title = g(f);
                    break;
                case "description":
                    a.description = g(f);
                    break;
                case "guid":
                    a.mediaid = g(f);
                    break;
                case "thumbnail":
                    a.image ||
                        (a.image = m(f, "url"));
                    break;
                case "group":
                    e.parseGroup(f, a);
                    break;
                case "subtitle":
                    var k = {};
                    k.file = m(f, "url");
                    k.kind = "captions";
                    if (0 < m(f, "lang").length) {
                        var l = k;
                        f = m(f, "lang");
                        var r = {
                            zh: "Chinese",
                            nl: "Dutch",
                            en: "English",
                            fr: "French",
                            de: "German",
                            it: "Italian",
                            ja: "Japanese",
                            pt: "Portuguese",
                            ru: "Russian",
                            es: "Spanish"
                        };
                        f = r[f] ? r[f] : f;
                        l.label = f
                    }
                    n.push(k)
                }
                a.hasOwnProperty("tracks") || (a.tracks = []);
            for (c = 0; c < n.length; c++) a.tracks.push(n[c]);
            return a
        }
    }(jwplayer.parsers), function (h) {
        function d(b) {
            for (var a = {}, f = 0; f <
                b.childNodes.length; f++) {
                var c = b.childNodes[f],
                    d = e(c);
                if (d) switch (d.toLowerCase()) {
                case "enclosure":
                    a.file = m.xmlAttribute(c, "url");
                    break;
                case "title":
                    a.title = j(c);
                    break;
                case "guid":
                    a.mediaid = j(c);
                    break;
                case "pubdate":
                    a.date = j(c);
                    break;
                case "description":
                    a.description = j(c);
                    break;
                case "link":
                    a.link = j(c);
                    break;
                case "category":
                    a.tags = a.tags ? a.tags + j(c) : j(c)
                }
            }
            a = h.mediaparser.parseGroup(b, a);
            a = h.jwparser.parseEntry(b, a);
            return new jwplayer.playlist.item(a)
        }
        var m = jwplayer.utils,
            j = h.textContent,
            g = h.getChildNode,
            b = h.numChildren,
            e = h.localName;
        h.rssparser = {};
        h.rssparser.parse = function (j) {
            for (var a = [], f = 0; f < b(j); f++) {
                var c = g(j, f);
                if ("channel" == e(c).toLowerCase())
                    for (var h = 0; h < b(c); h++) {
                        var k = g(c, h);
                        "item" == e(k).toLowerCase() && a.push(d(k))
                    }
            }
            return a
        }
    }(jwplayer.parsers), function (h) {
        h.playlist = function (d) {
            var m = [];
            if ("array" == h.utils.typeOf(d))
                for (var j = 0; j < d.length; j++) m.push(new h.playlist.item(d[j]));
            else m.push(new h.playlist.item(d));
            return m
        }
    }(jwplayer), function (h) {
        var d = h.item = function (m) {
            var j = jwplayer.utils,
                g = j.extend({}, d.defaults, m),
                b, e;
            g.tracks = m && j.exists(m.tracks) ? m.tracks : [];
            0 === g.sources.length && (g.sources = [new h.source(g)]);
            for (b = 0; b < g.sources.length; b++) e = g.sources[b]["default"], g.sources[b]["default"] = e ? "true" == e.toString() : !1, g.sources[b] = new h.source(g.sources[b]);
            if (g.captions && !j.exists(m.tracks)) {
                for (m = 0; m < g.captions.length; m++) g.tracks.push(g.captions[m]);
                delete g.captions
            }
            for (b = 0; b < g.tracks.length; b++) g.tracks[b] = new h.track(g.tracks[b]);
            return g
        };
        d.defaults = {
            description: void 0,
            image: void 0,
            mediaid: void 0,
            title: void 0,
            sources: [],
            tracks: []
        }
    }(jwplayer.playlist), function (h) {
        var d = jwplayer,
            m = d.utils,
            j = d.events,
            g = d.parsers;
        h.loader = function () {
            function b(b) {
                try {
                    var c = b.responseXML.childNodes;
                    b = "";
                    for (var d = 0; d < c.length && !(b = c[d], 8 != b.nodeType); d++);
                    "xml" == g.localName(b) && (b = b.nextSibling);
                    if ("rss" != g.localName(b)) p("Not a valid RSS feed");
                    else {
                        var e = new h(g.rssparser.parse(b));
                        a.sendEvent(j.JWPLAYER_PLAYLIST_LOADED, {
                            playlist: e
                        })
                    }
                } catch (l) {
                    p()
                }
            }

            function d(a) {
                p(a.match(/invalid/i) ? "Not a valid RSS feed" :
                    "")
            }

            function p(b) {
                a.sendEvent(j.JWPLAYER_ERROR, {
                    message: b ? b : "Error loading file"
                })
            }
            var a = new j.eventdispatcher;
            m.extend(this, a);
            this.load = function (a) {
                m.ajax(a, b, d)
            }
        }
    }(jwplayer.playlist), function (h) {
        var d = jwplayer.utils,
            m = {
                file: void 0,
                label: void 0,
                type: void 0,
                "default": void 0
            };
        h.source = function (j) {
            var g = d.extend({}, m);
            d.foreach(m, function (b) {
                d.exists(j[b]) && (g[b] = j[b], delete j[b])
            });
            g.type && 0 < g.type.indexOf("/") && (g.type = d.extensionmap.mimeType(g.type));
            "m3u8" == g.type && (g.type = "hls");
            "smil" == g.type &&
                (g.type = "rtmp");
            return g
        }
    }(jwplayer.playlist), function (h) {
        var d = jwplayer.utils,
            m = {
                file: void 0,
                label: void 0,
                kind: "captions",
                "default": !1
            };
        h.track = function (j) {
            var g = d.extend({}, m);
            j || (j = {});
            d.foreach(m, function (b) {
                d.exists(j[b]) && (g[b] = j[b], delete j[b])
            });
            return g
        }
    }(jwplayer.playlist), function (h) {
        var d = h.cast = {},
            m = h.utils;
        d.adprovider = function (j, g) {
            function b() {
                c = {
                    message: n,
                    position: 0,
                    duration: -1
                }
            }

            function e(a, b) {
                var c = {
                    command: a
                };
                void 0 !== b && (c.args = b);
                g.sendMessage(j, c, p, function (a) {
                    d.error("message send error",
                        a)
                })
            }

            function p() {}
            var a = new d.provider(j, g),
                f = m.extend(this, a),
                c, n = "Loading ad",
                k = 0;
            f.init = function () {
                a.init();
                b()
            };
            f.destroy = function () {
                a.destroy()
            };
            f.updateModel = function (f, e) {
                (f.tag || f.newstate || f.sequence || f.companions) && d.log("received ad change:", f);
                f.tag && (c.tag && f.tag !== c.tag) && (d.error("ad messages not received in order. new model:", f, "old model:", c), b());
                h.utils.extend(c, f);
                a.updateModel(f, e)
            };
            f.getAdModel = function () {
                var a = m.extend({}, c);
                a.message = 0 < c.duration ? this.getAdMessage() : n;
                return a
            };
            f.resetAdModel = function () {
                b()
            };
            f.getAdMessage = function () {
                var a = c.message.replace(/xx/gi, "" + Math.min(c.duration | 0, Math.ceil(c.duration - c.position)));
                c.podMessage && 1 < c.podcount && (a = c.podMessage.replace(/__AD_POD_CURRENT__/g, "" + c.sequence).replace(/__AD_POD_LENGTH__/g, "" + c.podcount) + a);
                return a
            };
            f.skipAd = function (a) {
                e("skipAd", {
                    tag: a.tag
                })
            };
            f.clickAd = function (a) {
                k = 1 * new Date;
                e("clickAd", {
                    tag: a.tag
                })
            };
            f.timeSinceClick = function () {
                return 1 * new Date - k
            }
        }
    }(window.jwplayer), function (h, d) {
        function m(a, b) {
            a[b] &&
                (a[b] = g.getAbsolutePath(a[b]))
        }
        var j = d.cast,
            g = d.utils,
            b = d.events,
            e = b.state,
            p = {};
        j.NS = "urn:x-cast:com.longtailvideo.jwplayer";
        j.controller = function (a, f) {
            var c, n;

            function k(a) {
                a = a.availability === h.chrome.cast.ReceiverAvailability.AVAILABLE;
                M.available !== a && (M.available = a, u(b.JWPLAYER_CAST_AVAILABLE))
            }

            function l(a) {
                j.log("existing session", a);
                w || (J = a.session, J.addMessageListener(j.NS, r))
            }

            function r(c, e) {
                var g = JSON.parse(e);
                if (!g) throw "Message not proper JSON";
                if (g.reconcile) {
                    J.removeMessageListener(j.NS,
                        r);
                    var h = g.diff,
                        l = J;
                    if (!h.id || !g.appid || !g.pageUrl) h.id = d().id, g.appid = I.appid, g.pageUrl = P, J = w = null;
                    h.id === a.id && (g.appid === I.appid && g.pageUrl === P) && (w || (a.jwInstreamState() && a.jwInstreamDestroy(!0), F(l), f.sendEvent(b.JWPLAYER_PLAYER_STATE, {
                        oldstate: h.oldstate,
                        newstate: h.newstate
                    })), D(g));
                    J = null
                }
            }

            function x(a) {
                M.active = !!a;
                a = M;
                var c;
                c = w && w.receiver ? w.receiver.friendlyName : "";
                a.deviceName = c;
                u(b.JWPLAYER_CAST_SESSION, {})
            }

            function u(a) {
                var b = g.extend({}, M);
                f.sendEvent(a, b)
            }

            function t(a) {
                var b = h.chrome;
                a.code !== b.cast.ErrorCode.CANCEL && (j.log("Cast Session Error:", a, w), a.code === b.cast.ErrorCode.SESSION_ERROR && q())
            }

            function q() {
                w ? (G(), w.stop(A, E)) : A()
            }

            function E(a) {
                j.error("Cast Session Stop error:", a, w);
                A()
            }

            function F(l) {
                w = l;
                w.addMessageListener(j.NS, B);
                w.addUpdateListener(v);
                a.jwPause(!0);
                a.jwSetFullscreen(!1);
                N = f.getVideo();
                c = f.volume;
                n = f.mute;
                C = new j.provider(j.NS, w);
                C.init();
                f.setVideo(C);
                a.jwPlay = function (a) {
                    !1 === a ? C.pause() : C.play()
                };
                a.jwPause = function (b) {
                    a.jwPlay(!!b)
                };
                a.jwLoad = function (a) {
                    "number" ===
                    g.typeOf(a) && f.setItem(a);
                    C.load(a)
                };
                a.jwPlaylistItem = function (a) {
                    "number" === g.typeOf(a) && f.setItem(a);
                    C.playlistItem(a)
                };
                a.jwPlaylistNext = function () {
                    a.jwPlaylistItem(f.item + 1)
                };
                a.jwPlaylistPrev = function () {
                    a.jwPlaylistItem(f.item - 1)
                };
                a.jwSetVolume = function (a) {
                    g.exists(a) && (a = Math.min(Math.max(0, a), 100) | 0, L(a) && (a = Math.max(0, Math.min(a / 100, 1)), w.setReceiverVolumeLevel(a, y, function (a) {
                        j.error("set volume error", a);
                        y()
                    })))
                };
                a.jwSetMute = function (a) {
                    g.exists(a) || (a = !K.mute);
                    Q(a) && w.setReceiverMuted(!!a,
                        y, function (a) {
                            j.error("set muted error", a);
                            y()
                        })
                };
                a.jwGetVolume = function () {
                    return K.volume | 0
                };
                a.jwGetMute = function () {
                    return !!K.mute
                };
                a.jwIsBeforePlay = function () {
                    return !1
                };
                var k = a.jwSetCurrentCaptions;
                a.jwSetCurrentCaptions = function (a) {
                    k(a)
                };
                a.jwSkipAd = function (a) {
                    z && (z.skipAd(a), a = z.getAdModel(), a.complete = !0, f.sendEvent(b.JWPLAYER_CAST_AD_CHANGED, a))
                };
                a.jwClickAd = function (c) {
                    if (z && 300 < z.timeSinceClick() && (z.clickAd(c), f.state !== e.PAUSED)) {
                        var g = {
                            tag: c.tag
                        };
                        c.sequence && (g.sequence = c.sequence);
                        c.podcount &&
                            (g.podcount = c.podcount);
                        d(a.id).dispatchEvent(b.JWPLAYER_AD_CLICK, g);
                        h.open(c.clickthrough)
                    }
                };
                a.jwPlayAd = a.jwPauseAd = a.jwSetControls = a.jwForceState = a.jwReleaseState = a.jwSetFullscreen = a.jwDetachMedia = a.jwAttachMedia = O;
                var p = d(a.id).plugins;
                p.vast && p.vast.jwPauseAd !== O && (R = {
                    jwPlayAd: p.vast.jwPlayAd,
                    jwPauseAd: p.vast.jwPauseAd
                }, p.vast.jwPlayAd = p.vast.jwPauseAd = O);
                y();
                x(!0);
                l !== J && C.setup(H(), f)
            }

            function v(a) {
                j.log("Cast Session status", a);
                a ? y() : (C.sendEvent(b.JWPLAYER_PLAYER_STATE, {
                        oldstate: f.state,
                        newstate: e.BUFFERING
                    }),
                    A())
            }

            function A() {
                w && (G(), w = null);
                if (N) {
                    delete a.jwSkipAd;
                    delete a.jwClickAd;
                    a.initializeAPI();
                    var j = d(a.id).plugins;
                    j.vast && g.extend(j.vast, R);
                    f.volume = c;
                    f.mute = n;
                    f.setVideo(N);
                    f.duration = 0;
                    C && (C.destroy(), C = null);
                    z && (z.destroy(), z = null);
                    f.state !== e.IDLE ? (f.state = e.IDLE, a.jwPlay(!0), a.jwSeek(f.position)) : N.sendEvent(b.JWPLAYER_PLAYER_STATE, {
                        oldstate: e.BUFFERING,
                        newstate: e.IDLE
                    });
                    N = null
                }
                x(!1)
            }

            function G() {
                w.removeUpdateListener(v);
                w.removeMessageListener(j.NS, B)
            }

            function B(a, b) {
                var c = JSON.parse(b);
                if (!c) throw "Message not proper JSON";
                D(c)
            }

            function D(c) {
                if ("state" === c.type) {
                    if (z && (c.diff.newstate || c.diff.position)) z.destroy(), z = null, f.setVideo(C), f.sendEvent(b.JWPLAYER_CAST_AD_CHANGED, {
                        done: !0
                    });
                    C.updateModel(c.diff, c.type);
                    c = c.diff;
                    void 0 !== c.item && f.item !== c.item && (f.item = c.item, f.sendEvent(b.JWPLAYER_PLAYLIST_ITEM, {
                        index: f.item
                    }))
                } else if ("ad" === c.type) {
                    null === z && (z = new j.adprovider(j.NS, w), z.init(), f.setVideo(z));
                    z.updateModel(c.diff, c.type);
                    var d = z.getAdModel();
                    c.diff.clickthrough && (d.onClick =
                        a.jwClickAd);
                    c.diff.skipoffset && (d.onSkipAd = a.jwSkipAd);
                    f.sendEvent(b.JWPLAYER_CAST_AD_CHANGED, d);
                    c.diff.complete && z.resetAdModel()
                } else "connection" === c.type ? !0 === c.closed && q() : j.error("received unhandled message", c.type, c)
            }

            function H() {
                var a = g.extend({}, f.config);
                a.cast = g.extend({
                    pageUrl: P
                }, I);
                for (var b = "base autostart controls fallback fullscreen width height mobilecontrols modes playlistlayout playlistposition playlistsize primary stretching sharing related ga skin logo listbar".split(" "), c = b.length; c--;) delete a[b[c]];
                b = a.plugins;
                delete a.plugins;
                for (var d in b)
                    if (b.hasOwnProperty(d)) {
                        var e = b[d];
                        if (e.client && (/[\.\/]/.test(e.client) && m(e, "client"), -1 < e.client.indexOf("vast"))) {
                            c = a;
                            e = g.extend({}, e);
                            e.client = "vast";
                            delete e.companiondiv;
                            if (e.schedule) {
                                var j = void 0;
                                for (j in e.schedule) e.schedule.hasOwnProperty(j) && m(e.schedule[j].ad || e.schedule[j], "tag")
                            }
                            m(e, "tag");
                            c.advertising = e
                        }
                    }
                f.position && (a.position = f.position);
                0 < f.item && (a.item = f.item);
                return a
            }

            function y() {
                if (w && w.receiver) {
                    var a = w.receiver.volume;
                    if (a) {
                        var b =
                            100 * a.level | 0;
                        Q(!!a.muted);
                        L(b)
                    }
                }
            }

            function L(a) {
                var c = K.volume !== a;
                c && (K.volume = a, C.sendEvent(b.JWPLAYER_MEDIA_VOLUME, {
                    volume: a
                }));
                return c
            }

            function Q(a) {
                var c = K.mute !== a;
                c && (K.mute = a, C.sendEvent(b.JWPLAYER_MEDIA_MUTE, {
                    mute: a
                }));
                return c
            }

            function O() {}
            var w = null,
                M = {
                    available: !1,
                    active: !1,
                    deviceName: ""
                },
                K = {
                    volume: null,
                    mute: null
                },
                P = h.location.href,
                I, C = null,
                z = null,
                N = null;
            c = f.volume;
            n = f.mute;
            var J = null,
                R = null;
            I = g.extend({}, p, f.cast);
            m(I, "loadscreen");
            m(I, "endscreen");
            m(I, "logo");
            if (I.appid && (!h.cast ||
                !h.cast.receiver)) j.loader.addEventListener("availability", k), j.loader.addEventListener("session", l), j.loader.initialize();
            this.startCasting = function () {
                w || a.jwInstreamState() || h.chrome.cast.requestSession(F, t)
            };
            this.stopCasting = q
        };
        j.log = function () {
            if (j.debug) {
                var a = Array.prototype.slice.call(arguments, 0);
                console.log.apply(console, a)
            }
        };
        j.error = function () {
            var a = Array.prototype.slice.call(arguments, 0);
            console.error.apply(console, a)
        }
    }(window, jwplayer), function (h, d) {
        function m() {
            d && d.cast && d.cast.isAvailable &&
                !a.apiConfig ? (a.apiConfig = new d.cast.ApiConfig(new d.cast.SessionRequest(l), e, p, d.cast.AutoJoinPolicy.ORIGIN_SCOPED), d.cast.initialize(a.apiConfig, b, g)) : 15 > k++ && setTimeout(m, 1E3)
        }

        function j() {
            n && (n.resetEventListeners(), n = null)
        }

        function g() {
            a.apiConfig = null
        }

        function b() {}

        function e(b) {
            a.loader.sendEvent("session", {
                session: b
            });
            b.sendMessage(a.NS, {
                whoami: 1
            })
        }

        function p(b) {
            a.availability = b;
            a.loader.sendEvent("availability", {
                availability: b
            })
        }
        window.chrome = d;
        var a = h.cast,
            f = h.utils,
            c = h.events,
            n, k = 0,
            l = "C7EF2AC5";
        a.loader = f.extend({
            initialize: function () {
                null !== a.availability ? a.loader.sendEvent("availability", {
                    availability: a.availability
                }) : d && d.cast ? m() : n || (n = new f.scriptloader("https://www.gstatic.com/cv/js/sender/v1/cast_sender.js"), n.addEventListener(c.ERROR, j), n.addEventListener(c.COMPLETE, m), n.load())
            }
        }, new c.eventdispatcher("cast.loader"));
        a.availability = null
    }(window.jwplayer, window.chrome || {}), function (h) {
        function d(b) {
            return function () {
                return b
            }
        }

        function m() {}
        var j = h.cast,
            g = h.utils,
            b = h.events,
            e = b.state;
        j.provider = function (h, a) {
            function f(b, c) {
                var d = {
                    command: b
                };
                void 0 !== c && (d.args = c);
                a.sendMessage(h, d, m, function (a) {
                    j.error("message send error", a)
                })
            }

            function c(a) {
                l.oldstate = l.newstate;
                l.newstate = a;
                n.sendEvent(b.JWPLAYER_PLAYER_STATE, {
                    oldstate: l.oldstate,
                    newstate: l.newstate
                })
            }
            var n = g.extend(this, new b.eventdispatcher("cast.provider")),
                k = -1,
                l = {
                    newstate: e.IDLE,
                    oldstate: e.IDLE,
                    buffer: 0,
                    position: 0,
                    duration: -1,
                    audioMode: !1
                };
            n.isCaster = !0;
            n.init = function () {};
            n.destroy = function () {
                clearTimeout(k);
                a = null
            };
            n.updateModel = function (a, c) {
                a.newstate && (l.newstate = a.newstate, l.oldstate = a.oldstate || l.oldstate, n.sendEvent(b.JWPLAYER_PLAYER_STATE, {
                    oldstate: l.oldstate,
                    newstate: l.newstate
                }));
                if ("ad" !== c) {
                    if (void 0 !== a.position || void 0 !== a.duration) void 0 !== a.position && (l.position = a.position), void 0 !== a.duration && (l.duration = a.duration), n.sendEvent(b.JWPLAYER_MEDIA_TIME, {
                        position: l.position,
                        duration: l.duration
                    });
                    void 0 !== a.buffer && (l.buffer = a.buffer, n.sendEvent(b.JWPLAYER_MEDIA_BUFFER, {
                        bufferPercent: l.buffer
                    }))
                }
            };
            n.supportsFullscreen = function () {
                return !1
            };
            n.setup = function (a, b) {
                b.state && (l.newstate = b.state);
                void 0 !== b.buffer && (l.buffer = b.buffer);
                void 0 !== a.position && (l.position = a.position);
                void 0 !== a.duration && (l.duration = a.duration);
                c(e.BUFFERING);
                f("setup", a)
            };
            n.playlistItem = function (a) {
                c(e.BUFFERING);
                f("item", a)
            };
            n.load = function (a) {
                c(e.BUFFERING);
                f("load", a)
            };
            n.stop = function () {
                clearTimeout(k);
                k = setTimeout(function () {
                    c(e.IDLE);
                    f("stop")
                }, 0)
            };
            n.play = function () {
                f("play")
            };
            n.pause = function () {
                c(e.PAUSED);
                f("pause")
            };
            n.seek = function (a) {
                c(e.BUFFERING);
                n.sendEvent(b.JWPLAYER_MEDIA_SEEK, {
                    position: l.position,
                    offset: a
                });
                f("seek", a)
            };
            n.audioMode = function () {
                return l.audioMode
            };
            n.detachMedia = function () {
                j.error("detachMedia called while casting");
                return document.createElement("video")
            };
            n.attachMedia = function () {
                j.error("attachMedia called while casting")
            };
            var r;
            n.setContainer = function (a) {
                r = a
            };
            n.getContainer = function () {
                return r
            };
            n.volume = n.mute = n.setControls = n.setCurrentQuality = n.remove = n.resize = n.seekDrag = n.addCaptions =
                n.resetCaptions = n.setVisibility = n.fsCaptions = m;
            n.setFullScreen = n.getFullScreen = n.checkComplete = d(!1);
            n.getWidth = n.getHeight = n.getCurrentQuality = d(0);
            n.getQualityLevels = d(["Auto"])
        }
    }(window.jwplayer), function (h) {
        function d(a, b) {
            j.foreach(b, function (b, c) {
                var d = a[b];
                "function" == typeof d && d.call(a, c)
            })
        }

        function m(a, b, d) {
            var e = a.style;
            e.backgroundColor = "#000";
            e.color = "#FFF";
            e.width = j.styleDimension(d.width);
            e.height = j.styleDimension(d.height);
            e.display = "table";
            e.opacity = 1;
            d = document.createElement("p");
            e = d.style;
            e.verticalAlign = "middle";
            e.textAlign = "center";
            e.display = "table-cell";
            e.font = "15px/20px Arial, Helvetica, sans-serif";
            d.innerHTML = b.replace(":", ":\x3cbr\x3e");
            a.innerHTML = "";
            a.appendChild(d)
        }
        var j = h.utils,
            g = h.events,
            b = !0,
            e = !1,
            p = document,
            a = h.embed = function (f) {
                function c() {
                    if (!B)
                        if ("array" === j.typeOf(u.playlist) && 2 > u.playlist.length && (0 === u.playlist.length || !u.playlist[0].sources || 0 === u.playlist[0].sources.length)) l();
                        else if (!G)
                        if ("string" === j.typeOf(u.playlist)) A = new h.playlist.loader, A.addEventListener(g.JWPLAYER_PLAYLIST_LOADED,
                            function (a) {
                                u.playlist = a.playlist;
                                G = e;
                                c()
                            }), A.addEventListener(g.JWPLAYER_ERROR, function (a) {
                            G = e;
                            l(a)
                        }), G = b, A.load(u.playlist);
                        else if (v.getStatus() == j.loaderstatus.COMPLETE) {
                        for (var k = 0; k < u.modes.length; k++)
                            if (u.modes[k].type && a[u.modes[k].type]) {
                                var p = j.extend({}, u),
                                    m = new a[u.modes[k].type](y, u.modes[k], p, v, f);
                                if (m.supportsConfig()) return m.addEventListener(g.ERROR, n), m.embed(), j.css("object.jwswf, .jwplayer:focus", {
                                    outline: "none"
                                }), j.css(".jw-tab-focus:focus", {
                                    outline: "solid 2px #0B7EF4"
                                }), d(f,
                                    p.events), f
                            }
                        var q;
                        u.fallback ? (q = "No suitable players found and fallback enabled", D = setTimeout(function () {
                            r(q, b)
                        }, 10), j.log(q), new a.download(y, u, l)) : (q = "No suitable players found and fallback disabled", r(q, e), j.log(q), y.parentNode.replaceChild(H, y))
                    }
                }

                function n(a) {
                    x(E + a.message)
                }

                function k(a) {
                    f.dispatchEvent(g.JWPLAYER_ERROR, {
                        message: "Could not load plugin: " + a.message
                    })
                }

                function l(a) {
                    a && a.message ? x("Error loading playlist: " + a.message) : x(E + "No playable sources found")
                }

                function r(a, b) {
                    D && (clearTimeout(D),
                        D = null);
                    D = setTimeout(function () {
                        D = null;
                        f.dispatchEvent(g.JWPLAYER_SETUP_ERROR, {
                            message: a,
                            fallback: b
                        })
                    }, 0)
                }

                function x(a) {
                    B || (u.fallback ? (B = b, m(y, a, u), r(a, b)) : r(a, e))
                }
                var u = new a.config(f.config),
                    t = u.width,
                    q = u.height,
                    E = "Error loading player: ",
                    F = p.getElementById(f.id),
                    v = h.plugins.loadPlugins(f.id, u.plugins),
                    A, G = e,
                    B = e,
                    D = null,
                    H = null;
                u.fallbackDiv && (H = u.fallbackDiv, delete u.fallbackDiv);
                u.id = f.id;
                u.aspectratio ? f.config.aspectratio = u.aspectratio : delete f.config.aspectratio;
                var y = p.createElement("div");
                y.id = F.id;
                y.style.width = 0 < t.toString().indexOf("%") ? t : t + "px";
                y.style.height = 0 < q.toString().indexOf("%") ? q : q + "px";
                F.parentNode.replaceChild(y, F);
                this.embed = function () {
                    B || (v.addEventListener(g.COMPLETE, c), v.addEventListener(g.ERROR, k), v.load())
                };
                this.destroy = function () {
                    v && (v.destroy(), v = null);
                    A && (A.resetEventListeners(), A = null)
                };
                this.errorScreen = x;
                return this
            };
        h.embed.errorScreen = m
    }(jwplayer), function (h) {
        function d(b) {
            if (b.playlist)
                for (var d = 0; d < b.playlist.length; d++) b.playlist[d] = new g(b.playlist[d]);
            else {
                var h = {};
                j.foreach(g.defaults, function (a) {
                    m(b, h, a)
                });
                h.sources || (b.levels ? (h.sources = b.levels, delete b.levels) : (d = {}, m(b, d, "file"), m(b, d, "type"), h.sources = d.file ? [d] : []));
                b.playlist = [new g(h)]
            }
        }

        function m(b, d, g) {
            j.exists(b[g]) && (d[g] = b[g], delete b[g])
        }
        var j = h.utils,
            g = h.playlist.item;
        (h.embed.config = function (b) {
            var e = {
                fallback: !0,
                height: 270,
                primary: "html5",
                width: 480,
                base: b.base ? b.base : j.getScriptPath("/jwplayer/jwplayer.js"),
                aspectratio: ""
            };
            b = j.extend(e, h.defaults, b);
            var e = {
                    type: "html5",
                    src: b.base + "/jwplayer/jwplayer.html5.js"
                },
                g = {
                    type: "flash",
                    src: b.base + "/jwplayer/jwplayer.flash.swf"
                };
            b.modes = "flash" == b.primary ? [g, e] : [e, g];
            b.listbar && (b.playlistsize = b.listbar.size, b.playlistposition = b.listbar.position, b.playlistlayout = b.listbar.layout);
            b.flashplayer && (g.src = b.flashplayer);
            b.html5player && (e.src = b.html5player);
            d(b);
            g = b.aspectratio;
            if ("string" != typeof g || !j.exists(g)) e = 0;
            else {
                var a = g.indexOf(":"); - 1 == a ? e = 0 : (e = parseFloat(g.substr(0, a)), g = parseFloat(g.substr(a + 1)), e = 0 >= e || 0 >= g ? 0 : 100 * (g / e) + "%")
            } - 1 == b.width.toString().indexOf("%") ? delete b.aspectratio :
                e ? b.aspectratio = e : delete b.aspectratio;
            return b
        }).addConfig = function (b, e) {
            d(e);
            return j.extend(b, e)
        }
    }(jwplayer), function (h) {
        var d = h.utils,
            m = document;
        h.embed.download = function (j, g, b) {
            function e(a, b) {
                for (var c = m.querySelectorAll(a), e = 0; e < c.length; e++) d.foreach(b, function (a, b) {
                    c[e].style[a] = b
                })
            }

            function h(a, b, c) {
                a = m.createElement(a);
                b && (a.className = "jwdownload" + b);
                c && c.appendChild(a);
                return a
            }
            var a = d.extend({}, g),
                f = a.width ? a.width : 480,
                c = a.height ? a.height : 320,
                n;
            g = g.logo ? g.logo : {
                prefix: d.repo(),
                file: "logo.png",
                margin: 10
            };
            var k, l, r, a = a.playlist,
                x, u = ["mp4", "aac", "mp3"];
            if (a && a.length) {
                x = a[0];
                n = x.sources;
                for (a = 0; a < n.length; a++) {
                    var t = n[a],
                        q = t.type ? t.type : d.extensionmap.extType(d.extension(t.file));
                    t.file && d.foreach(u, function (a) {
                        q == u[a] ? (k = t.file, l = x.image) : d.isYouTube(t.file) && (r = t.file)
                    })
                }
                k ? (n = k, b = l, j && (a = h("a", "display", j), h("div", "icon", a), h("div", "logo", a), n && a.setAttribute("href", d.getAbsolutePath(n))), a = "#" + j.id + " .jwdownload", j.style.width = "", j.style.height = "", e(a + "display", {
                        width: d.styleDimension(Math.max(320,
                            f)),
                        height: d.styleDimension(Math.max(180, c)),
                        background: "black center no-repeat " + (b ? "url(" + b + ")" : ""),
                        backgroundSize: "contain",
                        position: "relative",
                        border: "none",
                        display: "block"
                    }), e(a + "display div", {
                        position: "absolute",
                        width: "100%",
                        height: "100%"
                    }), e(a + "logo", {
                        top: g.margin + "px",
                        right: g.margin + "px",
                        background: "top right no-repeat url(" + g.prefix + g.file + ")"
                    }), e(a + "icon", {
                        background: "center no-repeat url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAgNJREFUeNrs28lqwkAYB/CZqNVDDj2r6FN41QeIy8Fe+gj6BL275Q08u9FbT8ZdwVfotSBYEPUkxFOoks4EKiJdaDuTjMn3wWBO0V/+sySR8SNSqVRKIR8qaXHkzlqS9jCfzzWcTCYp9hF5o+59sVjsiRzcegSckFzcjT+ruN80TeSlAjCAAXzdJSGPFXRpAAMYwACGZQkSdhG4WCzehMNhqV6vG6vVSrirKVEw66YoSqDb7cqlUilE8JjHd/y1MQefVzqdDmiaJpfLZWHgXMHn8F6vJ1cqlVAkEsGuAn83J4gAd2RZymQygX6/L1erVQt+9ZPWb+CDwcCC2zXGJaewl/DhcHhK3DVj+KfKZrMWvFarcYNLomAv4aPRSFZVlTlcSPA5fDweW/BoNIqFnKV53JvncjkLns/n/cLdS+92O7RYLLgsKfv9/t8XlDn4eDyiw+HA9Jyz2eyt0+kY2+3WFC5hluej0Ha7zQQq9PPwdDq1Et1sNsx/nFBgCqWJ8oAK1aUptNVqcYWewE4nahfU0YQnk4ntUEfGMIU2m01HoLaCKbTRaDgKtaVLk9tBYaBcE/6Artdr4RZ5TB6/dC+9iIe/WgAMYADDpAUJAxjAAAYwgGFZgoS/AtNNTF7Z2bL0BYPBV3Jw5xFwwWcYxgtBP5OkE8i9G7aWGOOCruvauwADALMLMEbKf4SdAAAAAElFTkSuQmCC)"
                    })) :
                    r ? (g = r, j = h("iframe", "", j), j.src = "http://www.youtube.com/embed/" + d.youTubeID(g), j.width = f, j.height = c, j.style.border = "none") : b()
            }
        }
    }(jwplayer), function (h) {
        var d = h.utils,
            m = h.events,
            j = {};
        (h.embed.flash = function (b, e, p, a, f) {
            function c(a, b, c) {
                var d = document.createElement("param");
                d.setAttribute("name", b);
                d.setAttribute("value", c);
                a.appendChild(d)
            }

            function n(a, b, c) {
                return function () {
                    try {
                        c && document.getElementById(f.id + "_wrapper").appendChild(b);
                        var d = document.getElementById(f.id).getPluginConfig("display");
                        "function" == typeof a.resize && a.resize(d.width, d.height);
                        b.style.left = d.x;
                        b.style.top = d.h
                    } catch (e) {}
                }
            }

            function k(a) {
                if (!a) return {};
                var b = {},
                    c = [];
                d.foreach(a, function (a, e) {
                    var f = d.getPluginName(a);
                    c.push(a);
                    d.foreach(e, function (a, c) {
                        b[f + "." + a] = c
                    })
                });
                b.plugins = c.join(",");
                return b
            }
            var l = new h.events.eventdispatcher,
                r = d.flashVersion();
            d.extend(this, l);
            this.embed = function () {
                p.id = f.id;
                if (10 > r) return l.sendEvent(m.ERROR, {
                    message: "Flash version must be 10.0 or greater"
                }), !1;
                var g, h, t = f.config.listbar,
                    q = d.extend({},
                        p);
                if (b.id + "_wrapper" == b.parentNode.id) g = document.getElementById(b.id + "_wrapper");
                else {
                    g = document.createElement("div");
                    h = document.createElement("div");
                    h.style.display = "none";
                    h.id = b.id + "_aspect";
                    g.id = b.id + "_wrapper";
                    g.style.position = "relative";
                    g.style.display = "block";
                    g.style.width = d.styleDimension(q.width);
                    g.style.height = d.styleDimension(q.height);
                    if (f.config.aspectratio) {
                        var E = parseFloat(f.config.aspectratio);
                        h.style.display = "block";
                        h.style.marginTop = f.config.aspectratio;
                        g.style.height = "auto";
                        g.style.display =
                            "inline-block";
                        t && ("bottom" == t.position ? h.style.paddingBottom = t.size + "px" : "right" == t.position && (h.style.marginBottom = -1 * t.size * (E / 100) + "px"))
                    }
                    b.parentNode.replaceChild(g, b);
                    g.appendChild(b);
                    g.appendChild(h)
                }
                g = a.setupPlugins(f, q, n);
                0 < g.length ? d.extend(q, k(g.plugins)) : delete q.plugins;
                "undefined" != typeof q["dock.position"] && "false" == q["dock.position"].toString().toLowerCase() && (q.dock = q["dock.position"], delete q["dock.position"]);
                g = q.wmode ? q.wmode : q.height && 40 >= q.height ? "transparent" : "opaque";
                h = "height width modes events primary base fallback volume".split(" ");
                for (t = 0; t < h.length; t++) delete q[h[t]];
                h = d.getCookies();
                d.foreach(h, function (a, b) {
                    "undefined" == typeof q[a] && (q[a] = b)
                });
                h = window.location.href.split("/");
                h.splice(h.length - 1, 1);
                h = h.join("/");
                q.base = h + "/";
                j[b.id] = q;
                d.isMSIE() ? (h = '\x3cobject classid\x3d"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" " width\x3d"100%" height\x3d"100%"id\x3d"' + b.id + '" name\x3d"' + b.id + '" tabindex\x3d0""\x3e', h += '\x3cparam name\x3d"movie" value\x3d"' + e.src + '"\x3e', h += '\x3cparam name\x3d"allowfullscreen" value\x3d"true"\x3e\x3cparam name\x3d"allowscriptaccess" value\x3d"always"\x3e',
                    h += '\x3cparam name\x3d"seamlesstabbing" value\x3d"true"\x3e', h += '\x3cparam name\x3d"wmode" value\x3d"' + g + '"\x3e', h += '\x3cparam name\x3d"bgcolor" value\x3d"#000000"\x3e', h += "\x3c/object\x3e", b.outerHTML = h, g = document.getElementById(b.id)) : (h = document.createElement("object"), h.setAttribute("type", "application/x-shockwave-flash"), h.setAttribute("data", e.src), h.setAttribute("width", "100%"), h.setAttribute("height", "100%"), h.setAttribute("bgcolor", "#000000"), h.setAttribute("id", b.id), h.setAttribute("name",
                    b.id), h.className = "jwswf", c(h, "allowfullscreen", "true"), c(h, "allowscriptaccess", "always"), c(h, "seamlesstabbing", "true"), c(h, "wmode", g), b.parentNode.replaceChild(h, b), g = h);
                f.config.aspectratio && (g.style.position = "absolute");
                f.container = g;
                f.setPlayer(g, "flash")
            };
            this.supportsConfig = function () {
                if (r)
                    if (p) {
                        if ("string" == d.typeOf(p.playlist)) return !0;
                        try {
                            var a = p.playlist[0].sources;
                            if ("undefined" == typeof a) return !0;
                            for (var b = 0; b < a.length; b++)
                                if (a[b].file && g(a[b].file, a[b].type)) return !0
                        } catch (c) {}
                    } else return !0;
                return !1
            }
        }).getVars = function (b) {
            return j[b]
        };
        var g = h.embed.flashCanPlay = function (b, e) {
            if (d.isYouTube(b) || d.isRtmp(b, e) || "hls" == e) return !0;
            var g = d.extensionmap[e ? e : d.extension(b)];
            return !g ? !1 : !!g.flash
        }
    }(jwplayer), function (h) {
        function d(b, d, g) {
            if (null !== navigator.userAgent.match(/BlackBerry/i)) return !1;
            if ("youtube" === d || m.isYouTube(b)) return !0;
            var a = m.extension(b);
            d = d || j.extType(a);
            if ("hls" === d)
                if (g) {
                    g = m.isAndroidNative;
                    if (g(2) || g(3) || g("4.0")) return !1;
                    if (m.isAndroid()) return !0
                } else if (m.isAndroid()) return !1;
            if (m.isRtmp(b, d)) return !1;
            b = j[d] || j[a];
            if (!b || b.flash && !b.html5) return !1;
            var f;
            a: if (b = b.html5) {
                try {
                    f = !!h.vid.canPlayType(b);
                    break a
                } catch (c) {}
                f = !1
            } else f = !0;
            return f
        }
        var m = h.utils,
            j = m.extensionmap,
            g = h.events;
        h.embed.html5 = function (b, e, j, a, f) {
            function c(a, c, d) {
                return function () {
                    try {
                        var e = document.querySelector("#" + b.id + " .jwmain");
                        d && e.appendChild(c);
                        "function" == typeof a.resize && (a.resize(e.clientWidth, e.clientHeight), setTimeout(function () {
                            a.resize(e.clientWidth, e.clientHeight)
                        }, 400));
                        c.left = e.style.left;
                        c.top = e.style.top
                    } catch (f) {}
                }
            }

            function n(a) {
                k.sendEvent(a.type, {
                    message: "HTML5 player not found"
                })
            }
            var k = this,
                l = new g.eventdispatcher;
            m.extend(k, l);
            k.embed = function () {
                if (h.html5) {
                    a.setupPlugins(f, j, c);
                    b.innerHTML = "";
                    var d = h.utils.extend({}, j);
                    delete d.volume;
                    d = new h.html5.player(d);
                    f.container = document.getElementById(f.id);
                    f.setPlayer(d, "html5")
                } else d = new m.scriptloader(e.src), d.addEventListener(g.ERROR, n), d.addEventListener(g.COMPLETE, k.embed), d.load()
            };
            k.supportsConfig = function () {
                if (h.vid.canPlayType) try {
                    if ("string" ==
                        m.typeOf(j.playlist)) return !0;
                    for (var a = j.playlist[0].sources, b = 0; b < a.length; b++)
                        if (d(a[b].file, a[b].type, j.androidhls)) return !0
                } catch (c) {}
                return !1
            }
        };
        h.embed.html5CanPlay = d
    }(jwplayer), function (h) {
        var d = h.embed,
            m = h.utils,
            j = /\.(js|swf)$/;
        h.embed = m.extend(function (g) {
            function b() {
                t = "Adobe SiteCatalyst Error: Could not find Media Module"
            }
            var e = m.repo(),
                p = m.extend({}, h.defaults),
                a = m.extend({}, p, g.config),
                f = g.config,
                c = a.plugins,
                n = a.analytics,
                k = e + "jwpsrv.js",
                l = e + "sharing.js",
                r = e + "related.js",
                x = e + "gapro.js",
                p = h.key ? h.key : p.key,
                u = (new h.utils.key(p)).edition(),
                t, c = c ? c : {};
            "ads" == u && a.advertising && (j.test(a.advertising.client) ? c[a.advertising.client] = a.advertising : c[e + a.advertising.client + ".js"] = a.advertising);
            delete f.advertising;
            f.key = p;
            a.analytics && j.test(a.analytics.client) && (k = a.analytics.client);
            delete f.analytics;
            n && !("ads" === u || "enterprise" === u) && delete n.enabled;
            if ("free" == u || !n || !1 !== n.enabled) c[k] = n ? n : {};
            delete c.sharing;
            delete c.related;
            switch (u) {
            case "ads":
            case "enterprise":
                if (f.sitecatalyst) try {
                    window.s &&
                        window.s.hasOwnProperty("Media") ? new h.embed.sitecatalyst(g) : b()
                } catch (q) {
                    b()
                }
            case "premium":
                a.related && (j.test(a.related.client) && (r = a.related.client), c[r] = a.related), a.ga && (j.test(a.ga.client) && (x = a.ga.client), c[x] = a.ga);
            case "pro":
                a.sharing && (j.test(a.sharing.client) && (l = a.sharing.client), c[l] = a.sharing), a.skin && (f.skin = a.skin.replace(/^(beelden|bekle|five|glow|modieus|roundster|stormtrooper|vapor)$/i, m.repo() + "skins/$1.xml"))
            }
            f.plugins = c;
            g.config = f;
            g = new d(g);
            t && g.errorScreen(t);
            return g
        }, h.embed)
    }(jwplayer),
    function (h) {
        var d = jwplayer.utils;
        h.sitecatalyst = function (h) {
            function j(b) {
                a.debug && d.log(b)
            }

            function g(a) {
                a = a.split("/");
                a = a[a.length - 1];
                a = a.split("?");
                return a[0]
            }

            function b() {
                if (!l) {
                    l = !0;
                    var a = p.getPosition();
                    j("stop: " + c + " : " + a);
                    s.Media.stop(c, a)
                }
            }

            function e() {
                r || (b(), r = !0, j("close: " + c), s.Media.close(c), x = !0, k = 0)
            }
            var p = h,
                a = d.extend({}, p.config.sitecatalyst),
                f = {
                    onPlay: function () {
                        if (!x) {
                            var a = p.getPosition();
                            l = !1;
                            j("play: " + c + " : " + a);
                            s.Media.play(c, a)
                        }
                    },
                    onPause: b,
                    onBuffer: b,
                    onIdle: e,
                    onPlaylistItem: function (b) {
                        try {
                            x = !0;
                            e();
                            k = 0;
                            var f;
                            if (a.mediaName) f = a.mediaName;
                            else {
                                var h = p.getPlaylistItem(b.index);
                                f = h.title ? h.title : h.file ? g(h.file) : h.sources && h.sources.length ? g(h.sources[0].file) : ""
                            }
                            c = f;
                            n = a.playerName ? a.playerName : p.id
                        } catch (j) {
                            d.log(j)
                        }
                    },
                    onTime: function () {
                        if (x) {
                            var a = p.getDuration();
                            if (-1 == a) return;
                            r = l = x = !1;
                            j("open: " + c + " : " + a + " : " + n);
                            s.Media.open(c, a, n);
                            j("play: " + c + " : 0");
                            s.Media.play(c, 0)
                        }
                        a = p.getPosition();
                        if (3 <= Math.abs(a - k)) {
                            var b = k;
                            j("seek: " + b + " to " + a);
                            j("stop: " + c + " : " + b);
                            s.Media.stop(c, b);
                            j("play: " +
                                c + " : " + a);
                            s.Media.play(c, a)
                        }
                        k = a
                    },
                    onComplete: e
                },
                c, n, k, l = !0,
                r = !0,
                x;
            d.foreach(f, function (a) {
                p[a](f[a])
            })
        }
    }(jwplayer.embed), function (h, d) {
        var m = [],
            j = h.utils,
            g = h.events,
            b = g.state,
            e = document,
            p = "getBuffer getCaptionsList getControls getCurrentCaptions getCurrentQuality getDuration getFullscreen getHeight getLockState getMute getPlaylistIndex getSafeRegion getPosition getQualityLevels getState getVolume getWidth isBeforeComplete isBeforePlay releaseState".split(" "),
            a = "playlistNext stop forceState playlistPrev seek setCurrentCaptions setControls setCurrentQuality setVolume".split(" "),
            f = {
                onBufferChange: g.JWPLAYER_MEDIA_BUFFER,
                onBufferFull: g.JWPLAYER_MEDIA_BUFFER_FULL,
                onError: g.JWPLAYER_ERROR,
                onSetupError: g.JWPLAYER_SETUP_ERROR,
                onFullscreen: g.JWPLAYER_FULLSCREEN,
                onMeta: g.JWPLAYER_MEDIA_META,
                onMute: g.JWPLAYER_MEDIA_MUTE,
                onPlaylist: g.JWPLAYER_PLAYLIST_LOADED,
                onPlaylistItem: g.JWPLAYER_PLAYLIST_ITEM,
                onPlaylistComplete: g.JWPLAYER_PLAYLIST_COMPLETE,
                onReady: g.API_READY,
                onResize: g.JWPLAYER_RESIZE,
                onComplete: g.JWPLAYER_MEDIA_COMPLETE,
                onSeek: g.JWPLAYER_MEDIA_SEEK,
                onTime: g.JWPLAYER_MEDIA_TIME,
                onVolume: g.JWPLAYER_MEDIA_VOLUME,
                onBeforePlay: g.JWPLAYER_MEDIA_BEFOREPLAY,
                onBeforeComplete: g.JWPLAYER_MEDIA_BEFORECOMPLETE,
                onDisplayClick: g.JWPLAYER_DISPLAY_CLICK,
                onControls: g.JWPLAYER_CONTROLS,
                onQualityLevels: g.JWPLAYER_MEDIA_LEVELS,
                onQualityChange: g.JWPLAYER_MEDIA_LEVEL_CHANGED,
                onCaptionsList: g.JWPLAYER_CAPTIONS_LIST,
                onCaptionsChange: g.JWPLAYER_CAPTIONS_CHANGED,
                onAdError: g.JWPLAYER_AD_ERROR,
                onAdClick: g.JWPLAYER_AD_CLICK,
                onAdImpression: g.JWPLAYER_AD_IMPRESSION,
                onAdTime: g.JWPLAYER_AD_TIME,
                onAdComplete: g.JWPLAYER_AD_COMPLETE,
                onAdCompanions: g.JWPLAYER_AD_COMPANIONS,
                onAdSkipped: g.JWPLAYER_AD_SKIPPED,
                onAdPlay: g.JWPLAYER_AD_PLAY,
                onAdPause: g.JWPLAYER_AD_PAUSE,
                onAdMeta: g.JWPLAYER_AD_META,
                onCast: g.JWPLAYER_CAST_SESSION
            },
            c = {
                onBuffer: b.BUFFERING,
                onPause: b.PAUSED,
                onPlay: b.PLAYING,
                onIdle: b.IDLE
            };
        h.api = function (m) {
            function k(a, b) {
                j.foreach(a, function (a, c) {
                    q[a] = function (a) {
                        return b(c, a)
                    }
                })
            }

            function l(a, b) {
                var c = "jw" + b.charAt(0).toUpperCase() + b.slice(1);
                q[b] = function () {
                    var b = t.apply(this, [c].concat(Array.prototype.slice.call(arguments,
                        0)));
                    return a ? q : b
                }
            }

            function r(a) {
                G = [];
                D && D.destroy && D.destroy();
                h.api.destroyPlayer(a.id)
            }

            function x(a, b) {
                try {
                    a.jwAddEventListener(b, 'function(dat) { jwplayer("' + q.id + '").dispatchEvent("' + b + '", dat); }')
                } catch (c) {
                    j.log("Could not add internal listener")
                }
            }

            function u(a, b) {
                E[a] || (E[a] = [], v && A && x(v, a));
                E[a].push(b);
                return q
            }

            function t() {
                if (A) {
                    if (v) {
                        var a = Array.prototype.slice.call(arguments, 0),
                            b = a.shift();
                        if ("function" === typeof v[b]) {
                            switch (a.length) {
                            case 6:
                                return v[b](a[0], a[1], a[2], a[3], a[4], a[5]);
                            case 5:
                                return v[b](a[0], a[1], a[2], a[3], a[4]);
                            case 4:
                                return v[b](a[0], a[1], a[2], a[3]);
                            case 3:
                                return v[b](a[0], a[1], a[2]);
                            case 2:
                                return v[b](a[0], a[1]);
                            case 1:
                                return v[b](a[0])
                            }
                            return v[b]()
                        }
                    }
                    return null
                }
                G.push(arguments)
            }
            var q = this,
                E = {},
                F = {},
                v, A = !1,
                G = [],
                B, D, H = {},
                y = {};
            q.container = m;
            q.id = m.id;
            q.setup = function (a) {
                if (h.embed) {
                    var b = e.getElementById(q.id);
                    b && (a.fallbackDiv = b);
                    r(q);
                    b = h(q.id);
                    b.config = a;
                    D = new h.embed(b);
                    D.embed();
                    return b
                }
                return q
            };
            q.getContainer = function () {
                return q.container
            };
            q.addButton =
                function (a, b, c, d) {
                    try {
                        y[d] = c, t("jwDockAddButton", a, b, "jwplayer('" + q.id + "').callback('" + d + "')", d)
                    } catch (e) {
                        j.log("Could not add dock button" + e.message)
                    }
                };
            q.removeButton = function (a) {
                t("jwDockRemoveButton", a)
            };
            q.callback = function (a) {
                if (y[a]) y[a]()
            };
            q.getMeta = function () {
                return q.getItemMeta()
            };
            q.getPlaylist = function () {
                var a = t("jwGetPlaylist");
                "flash" == q.renderingMode && j.deepReplaceKeyName(a, ["__dot__", "__spc__", "__dsh__", "__default__"], [".", " ", "-", "default"]);
                return a
            };
            q.getPlaylistItem = function (a) {
                j.exists(a) ||
                    (a = q.getPlaylistIndex());
                return q.getPlaylist()[a]
            };
            q.getRenderingMode = function () {
                return q.renderingMode
            };
            q.setFullscreen = function (a) {
                j.exists(a) ? t("jwSetFullscreen", a) : t("jwSetFullscreen", !t("jwGetFullscreen"));
                return q
            };
            q.setMute = function (a) {
                j.exists(a) ? t("jwSetMute", a) : t("jwSetMute", !t("jwGetMute"));
                return q
            };
            q.lock = function () {
                return q
            };
            q.unlock = function () {
                return q
            };
            q.load = function (a) {
                t("jwInstreamDestroy");
                h(q.id).plugins.googima && t("jwDestroyGoogima");
                t("jwLoad", a);
                return q
            };
            q.playlistItem = function (a) {
                t("jwPlaylistItem",
                    parseInt(a, 10));
                return q
            };
            q.resize = function (a, b) {
                if ("flash" !== q.renderingMode) t("jwResize", a, b);
                else {
                    var c = e.getElementById(q.id + "_wrapper"),
                        d = e.getElementById(q.id + "_aspect");
                    d && (d.style.display = "none");
                    c && (c.style.display = "block", c.style.width = j.styleDimension(a), c.style.height = j.styleDimension(b))
                }
                return q
            };
            q.play = function (a) {
                if (a !== d) return t("jwPlay", a), q;
                a = q.getState();
                var c = B && B.getState();
                c ? c === b.IDLE || c === b.PLAYING || c === b.BUFFERING ? t("jwInstreamPause") : t("jwInstreamPlay") : a == b.PLAYING || a ==
                    b.BUFFERING ? t("jwPause") : t("jwPlay");
                return q
            };
            q.pause = function (a) {
                a === d ? (a = q.getState(), a == b.PLAYING || a == b.BUFFERING ? t("jwPause") : t("jwPlay")) : t("jwPause", a);
                return q
            };
            q.createInstream = function () {
                return new h.api.instream(this, v)
            };
            q.setInstream = function (a) {
                return B = a
            };
            q.loadInstream = function (a, b) {
                B = q.setInstream(q.createInstream()).init(b);
                B.loadItem(a);
                return B
            };
            q.destroyPlayer = function () {
                t("jwPlayerDestroy")
            };
            q.playAd = function (a) {
                var b = h(q.id).plugins;
                b.vast ? b.vast.jwPlayAd(a) : t("jwPlayAd", a)
            };
            q.pauseAd = function () {
                var a = h(q.id).plugins;
                a.vast ? a.vast.jwPauseAd() : t("jwPauseAd")
            };
            k(c, function (a, b) {
                F[a] || (F[a] = [], u(g.JWPLAYER_PLAYER_STATE, function (b) {
                    var c = b.newstate;
                    b = b.oldstate;
                    if (c == a) {
                        var d = F[c];
                        if (d)
                            for (var e = 0; e < d.length; e++) {
                                var f = d[e];
                                "function" == typeof f && f.call(this, {
                                    oldstate: b,
                                    newstate: c
                                })
                            }
                    }
                }));
                F[a].push(b);
                return q
            });
            k(f, u);
            j.foreach(p, function (a, b) {
                l(!1, b)
            });
            j.foreach(a, function (a, b) {
                l(!0, b)
            });
            q.remove = function () {
                if (!A) throw "Cannot call remove() before player is ready";
                r(this)
            };
            q.registerPlugin = function (a, b, c, d) {
                h.plugins.registerPlugin(a, b, c, d)
            };
            q.setPlayer = function (a, b) {
                v = a;
                q.renderingMode = b
            };
            q.detachMedia = function () {
                if ("html5" == q.renderingMode) return t("jwDetachMedia")
            };
            q.attachMedia = function (a) {
                if ("html5" == q.renderingMode) return t("jwAttachMedia", a)
            };
            q.removeEventListener = function (a, b) {
                var c = E[a];
                if (c)
                    for (var d = c.length; d--;) c[d] === b && c.splice(d, 1)
            };
            q.dispatchEvent = function (a, b) {
                var c = E[a];
                if (c)
                    for (var c = c.slice(0), d = j.translateEventResponse(a, b), e = 0; e < c.length; e++) {
                        var f =
                            c[e];
                        if ("function" === typeof f) try {
                            a === g.JWPLAYER_PLAYLIST_LOADED && j.deepReplaceKeyName(d.playlist, ["__dot__", "__spc__", "__dsh__", "__default__"], [".", " ", "-", "default"]), f.call(this, d)
                        } catch (h) {
                            j.log("There was an error calling back an event handler")
                        }
                    }
            };
            q.dispatchInstreamEvent = function (a) {
                B && B.dispatchEvent(a, arguments)
            };
            q.callInternal = t;
            q.playerReady = function (a) {
                A = !0;
                v || q.setPlayer(e.getElementById(a.id));
                q.container = e.getElementById(q.id);
                j.foreach(E, function (a) {
                    x(v, a)
                });
                u(g.JWPLAYER_PLAYLIST_ITEM,
                    function () {
                        H = {}
                    });
                u(g.JWPLAYER_MEDIA_META, function (a) {
                    j.extend(H, a.metadata)
                });
                u(g.JWPLAYER_VIEW_TAB_FOCUS, function (a) {
                    var b = q.getContainer();
                    !0 === a.hasFocus ? j.addClass(b, "jw-tab-focus") : j.removeClass(b, "jw-tab-focus")
                });
                for (q.dispatchEvent(g.API_READY); 0 < G.length;) t.apply(this, G.shift())
            };
            q.getItemMeta = function () {
                return H
            };
            return q
        };
        h.playerReady = function (a) {
            var b = h.api.playerById(a.id);
            b ? b.playerReady(a) : h.api.selectPlayer(a.id).playerReady(a)
        };
        h.api.selectPlayer = function (a) {
            var b;
            j.exists(a) ||
                (a = 0);
            a.nodeType ? b = a : "string" == typeof a && (b = e.getElementById(a));
            return b ? (a = h.api.playerById(b.id)) ? a : h.api.addPlayer(new h.api(b)) : "number" == typeof a ? m[a] : null
        };
        h.api.playerById = function (a) {
            for (var b = 0; b < m.length; b++)
                if (m[b].id == a) return m[b];
            return null
        };
        h.api.addPlayer = function (a) {
            for (var b = 0; b < m.length; b++)
                if (m[b] == a) return a;
            m.push(a);
            return a
        };
        h.api.destroyPlayer = function (a) {
            var b, c, f;
            j.foreach(m, function (d, e) {
                e.id === a && (b = d, c = e)
            });
            if (b === d || c === d) return null;
            j.clearCss("#" + c.id);
            if (f = e.getElementById(c.id +
                ("flash" == c.renderingMode ? "_wrapper" : ""))) {
                "html5" === c.renderingMode && c.destroyPlayer();
                var g = e.createElement("div");
                g.id = c.id;
                f.parentNode.replaceChild(g, f)
            }
            m.splice(b, 1);
            return null
        }
    }(window.jwplayer), function (h) {
        var d = h.events,
            m = h.utils,
            j = d.state;
        h.api.instream = function (g, b) {
            function e(a, d) {
                c[a] || (c[a] = [], b.jwInstreamAddEventListener(a, 'function(dat) { jwplayer("' + g.id + '").dispatchInstreamEvent("' + a + '", dat); }'));
                c[a].push(d);
                return this
            }

            function h(a, b) {
                n[a] || (n[a] = [], e(d.JWPLAYER_PLAYER_STATE,
                    function (b) {
                        var c = b.newstate,
                            d = b.oldstate;
                        if (c == a) {
                            var e = n[c];
                            if (e)
                                for (var f = 0; f < e.length; f++) {
                                    var g = e[f];
                                    "function" == typeof g && g.call(this, {
                                        oldstate: d,
                                        newstate: c,
                                        type: b.type
                                    })
                                }
                        }
                    }));
                n[a].push(b);
                return this
            }
            var a, f, c = {},
                n = {},
                k = this;
            k.type = "instream";
            k.init = function () {
                g.callInternal("jwInitInstream");
                return k
            };
            k.loadItem = function (b, c) {
                a = b;
                f = c || {};
                "array" == m.typeOf(b) ? g.callInternal("jwLoadArrayInstream", a, f) : g.callInternal("jwLoadItemInstream", a, f)
            };
            k.removeEvents = function () {
                c = n = {}
            };
            k.removeEventListener =
                function (a, b) {
                    var d = c[a];
                    if (d)
                        for (var e = d.length; e--;) d[e] === b && d.splice(e, 1)
                };
            k.dispatchEvent = function (a, b) {
                var d = c[a];
                if (d)
                    for (var d = d.slice(0), e = m.translateEventResponse(a, b[1]), f = 0; f < d.length; f++) {
                        var g = d[f];
                        "function" == typeof g && g.call(this, e)
                    }
            };
            k.onError = function (a) {
                return e(d.JWPLAYER_ERROR, a)
            };
            k.onMediaError = function (a) {
                return e(d.JWPLAYER_MEDIA_ERROR, a)
            };
            k.onFullscreen = function (a) {
                return e(d.JWPLAYER_FULLSCREEN, a)
            };
            k.onMeta = function (a) {
                return e(d.JWPLAYER_MEDIA_META, a)
            };
            k.onMute = function (a) {
                return e(d.JWPLAYER_MEDIA_MUTE,
                    a)
            };
            k.onComplete = function (a) {
                return e(d.JWPLAYER_MEDIA_COMPLETE, a)
            };
            k.onPlaylistComplete = function (a) {
                return e(d.JWPLAYER_PLAYLIST_COMPLETE, a)
            };
            k.onPlaylistItem = function (a) {
                return e(d.JWPLAYER_PLAYLIST_ITEM, a)
            };
            k.onTime = function (a) {
                return e(d.JWPLAYER_MEDIA_TIME, a)
            };
            k.onBuffer = function (a) {
                return h(j.BUFFERING, a)
            };
            k.onPause = function (a) {
                return h(j.PAUSED, a)
            };
            k.onPlay = function (a) {
                return h(j.PLAYING, a)
            };
            k.onIdle = function (a) {
                return h(j.IDLE, a)
            };
            k.onClick = function (a) {
                return e(d.JWPLAYER_INSTREAM_CLICK, a)
            };
            k.onInstreamDestroyed = function (a) {
                return e(d.JWPLAYER_INSTREAM_DESTROYED, a)
            };
            k.onAdSkipped = function (a) {
                return e(d.JWPLAYER_AD_SKIPPED, a)
            };
            k.play = function (a) {
                b.jwInstreamPlay(a)
            };
            k.pause = function (a) {
                b.jwInstreamPause(a)
            };
            k.hide = function () {
                g.callInternal("jwInstreamHide")
            };
            k.destroy = function () {
                k.removeEvents();
                g.callInternal("jwInstreamDestroy")
            };
            k.setText = function (a) {
                b.jwInstreamSetText(a ? a : "")
            };
            k.getState = function () {
                return b.jwInstreamState()
            };
            k.setClick = function (a) {
                b.jwInstreamClick && b.jwInstreamClick(a)
            }
        }
    }(window.jwplayer),
    function (h) {
        var d = h.api,
            m = d.selectPlayer;
        d.selectPlayer = function (d) {
            return (d = m(d)) ? d : {
                registerPlugin: function (d, b, e) {
                    h.plugins.registerPlugin(d, b, e)
                }
            }
        }
    }(jwplayer));
