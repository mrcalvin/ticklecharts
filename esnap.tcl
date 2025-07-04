# Copyright (c) 2022-2025 Nicolas ROBERT.
# Distributed under MIT license. Please see LICENSE for details.
#
namespace eval ticklecharts {
    variable snapdebug 0  ; # debug message
}
foreach class {
    ticklecharts::chart
    ticklecharts::Gridlayout
    ticklecharts::timeline
} {
    oo::define $class {

        method SnapShot {args} {
            # Export Chart to png|svg|base64.
            #
            # args - Options described below.
            # 
            # -address           - Local adress.
            # -port              - Port number.
            # -exe               - Full path executable.
            # -html              - Html fragment.
            # -renderer          - base64, png or svg.
            # -outfile           - Full path file.
            # -excludecomponents - Excluded components.
            # -timeout           - Time to execute JS function.
            #
            # Returns full path if 'png|svg' renderer,
            # data if 'base64' renderer or '-1' if there is an error.
            try {

                my variable browser
                my variable forever
                my variable isrendered
                my variable renderer
                my variable outfile
                my variable imginfo
                my variable js
                my variable connection
                my variable timeout
                my variable jschartvar

                package require huddle::json
                package require websocket

                if {[llength $args] % 2} {
                    error "wrong # args: should be \"[self] [self method]\
                          ?-port port? ...\""
                }

                set imginfo -1
                set connection 0
                set isrendered 0
                # Gets arguments options
                foreach {key info} [ticklecharts::renderOptions $args [self method]] {
                    set k  [string map {- ""} $key]
                    set $k [lindex $info 0]
                }

                if {$html eq "nothing"} {
                    if {$renderer eq "svg"} {
                        set htmlopts [ticklecharts::renderOptions {
                            -renderer svg
                        } "toHTML"]
                    } else {
                        set htmlopts [ticklecharts::renderOptions {} "toHTML"]
                    }
                    set html [my toHTML {*}$htmlopts]
                }

                # Try to find out if 'animation' is actived.
                # The animation causes a delay in image display.
                if {[my getType] in {gridlayout timeline}} {
                    set charts [my charts]
                } else {
                    set charts [self]
                }
                if {[my getType] eq "gridlayout"} {
                    if {[my globalOptions] ne ""} {
                        if {[dict exists [my globalOptions] @B=animation]} {
                            if {[dict get [my globalOptions] @B=animation]} {
                                error "'animation' property should be disabled\
                                        in 'SetGlobalOptions' when 'SnapShot'\
                                        method is used."
                            }
                        }
                    }
                }
                foreach c $charts {
                    foreach {keyP value} [my getTrace] {
                        # 'track' list filter.
                        if {[string match -nocase {*animation*} $keyP]} {
                            if {$value ni {null nothing}} {
                                if {([ticklecharts::typeOf $value] eq "bool") && $value} {
                                    error "'animation' property should be disabled\
                                            in '$keyP' when 'SnapShot' method is used."
                                }
                            }
                        }
                    }
                }

                if {($renderer in {png svg}) && ($outfile ne "")} {
                    if {[file extension $outfile] ne ".$renderer"} {
                        error "wrong # args: file extension for '-outfile'\
                               property should be '.$renderer'"
                    }
                }

                # Try to find out if 'gridlayout' or 'timeline'
                # class contains 'chart3D' chart type.
                if {[my getType] in {gridlayout timeline}} {
                    foreach c [my charts] {
                        if {[$c getType] eq "chart3D"} {
                            error "'[my getType]' class should not\
                                    contain 'chart3D'."
                        }
                    }
                }

                # Exclude components or not.
                set exc {}
                if {$excludecomponents ne "nothing"} {
                    set len [llength {*}$excludecomponents]
                    set frt [format [string repeat "'%s', " $len] \
                        {*}[join $excludecomponents] \
                    ]
                    set exc $frt
                }

                # Gets variable value from self.
                set jschartvar [set [my varname _jschartvar]]

                # JS function.
                set js [subst -nocommands {
                    try {
                        if ('$renderer' === 'svg') {
                            var svg_${jschartvar};
                            svg_${jschartvar} = ${jschartvar}.renderToSVGString();
                        } else {
                            var img_${jschartvar} = new Image();
                            img_${jschartvar}.src = ${jschartvar}.getDataURL({
                                pixelRatio: 1,
                                excludeComponents : [$exc]
                            });
                        }
                    } catch(e) {
                        throw new Error('Unexpected error: ' + e.message);
                    }
                }]
                
                # A temporary file is created when the command is executed.
                # This may change in future versions of 'ticklEcharts'
                set htmltmpfile [ticklecharts::htmlTmpFile $html]
                my StartBrowser $exe $port $address $htmltmpfile

                if {$browser != 2} {
                    set url "http://${address}:${port}/json"
                    my ConnectLocalHost $url $htmltmpfile
                    vwait [my varname forever]
                }

                return $imginfo

            } on error {result options} {
                error "error(snap): [dict get $options -errorinfo]"
            } finally {
                # Delete temporary file.
                catch {file delete -force $htmltmpfile}
            }
        }

        method StartBrowser {exe port address tmpfile} {
            # Start Browser.
            #
            # exe      - full path executable.
            # port     - port number.
            # adress   - adress local host.
            # tempfile - full path html temporary file.
            #
            my variable browser

            if {$::tcl_platform(platform) eq "windows"} {
                set fileUrl "file:///[string map {\\ /} $tmpfile]"
            } else {
                set fileUrl "file://$tmpfile"
            }

            set cmd [list $exe \
                        --remote-debugging-port=$port \
                        --remote-debugging-address=$address \
                        --headless=new \
                        --disable-gpu \
                        --no-sandbox \
                        --allow-file-access-from-files \
                        --disable-extensions \
                        --disable-background-networking \
                        $fileUrl]

            set f [open "|$cmd 2>@1" r]
            fconfigure $f -blocking 0
            fileevent $f readable [callback ReadBrowser $f]
            vwait [my varname browser]

            if {$browser != 1} {
                error "error(snap): Chrome failed to start properly."
            }

            if {$::ticklecharts::snapdebug} {
                puts stderr "DEBUG: Chrome started, \
                    waiting before connecting..."
            }
        }

        method ReadBrowser {f} {
            # Capture stderr, stdout '-exe' file.
            #
            # f - open file
            #
            my variable browser

            set status [catch {gets $f line} result]
            if {$status != 0} {
                puts stderr "error(snap): $result"
                set browser 2
            } elseif {$result >= 0} {
                if {[string match {*ERROR:*} $line]} {
                    # Errors to ignore (specific to Edge/Chrome)
                    if {
                        [string match "*error code 577*" $line] ||
                        [string match "*EDGE_IDENTITY:*" $line] ||
                        [string match "*edge_auth_errors*" $line] ||
                        [string match "*kImplicitSignInFailure*" $line] ||
                        [string match "*kAccountProviderFetchError*" $line]
                    } {
                        if {$::ticklecharts::snapdebug} {
                            puts stdout "Browser warning (ignored): \
                                [string range $line 0 100]..."
                        }
                        set browser 1
                    } else {
                        # Real error
                        puts stderr "error(snap): $line"
                        set browser 2
                    }
                } elseif {[string match {*WARNING:*} $line]} {
                    if {$::ticklecharts::snapdebug} {
                        puts stdout $line
                    }
                    set browser 1
                } else {
                    set browser 1
                }
            } elseif {[eof $f]} {
                set browser 2
            } elseif {[fblocked $f]} {
                # do nothing
            }
        }

        method ConnectLocalHost {url htmltmpfile} {
            # Connection to local host.
            #
            # url         - string url
            # htmltmpfile - full path html temporary file
            #

            if {$::ticklecharts::snapdebug} {
                puts stderr "DEBUG: Fetching $url"
            }

            set response [http::geturl $url]
            set data [http::data $response]
            http::cleanup $response

            if {$::ticklecharts::snapdebug} {
                puts stderr "DEBUG: Response data: \
                    [string range $data 0 200]..."
            }

            set pages [ticklecharts::messageToDict $data]

            if {$::ticklecharts::snapdebug} {
                puts stderr "DEBUG: Found [llength $pages] pages"
            }
            
            set page ""
            foreach p $pages {
                set pageUrl [dict get $p url]
                if {$::ticklecharts::snapdebug} {
                    puts stderr "DEBUG: Page - URL: $pageUrl,\
                        Type: [dict get $p type]"
                }
                if {
                    ([dict get $p type] eq "page") &&
                    [string match "*[file tail $htmltmpfile]*" $pageUrl]
                } {
                    set page $p
                    break
                }
            }

            if {$page eq ""} {
                error "error(snap): Could not find page\
                    with our HTML file."
            }

            set wsDebuggerUrl [dict get $page webSocketDebuggerUrl]
            if {$::ticklecharts::snapdebug} {
                puts stderr "DEBUG: WebSocket URL: $wsDebuggerUrl"
            }


            set websocketUrl $wsDebuggerUrl
            set ws [websocket::open $websocketUrl [callback Handler]]

            after 300 [callback Runtime $ws]

        }

        method BrowserRender {msg sock} {
            # Save image.
            #
            # msg  - message from websocket
            # sock - websocket
            #
            my variable isrendered
            my variable renderer
            my variable outfile
            my variable imginfo

            try {
                set d [ticklecharts::messageToDict $msg]
                set data [dict get $d result result value]
                set data [string map {data:image/png;base64, ""} $data]
                set isrendered 1
                set mode wb+
                if {$renderer eq "base64"} {
                    set imginfo $data
                } else {
                    switch -exact -- $renderer {
                        png {set dataImg [binary decode base64 $data]}
                        svg {set dataImg $data ; set mode w+}
                    }
                    set fp [open $outfile $mode]
                    puts $fp $dataImg
                    if {$::ticklecharts::htmlstdout} {
                        puts stdout [format "${renderer}:%s" \
                            [file nativename $outfile] \
                        ]
                    }
                    set imginfo $outfile
                }
            } on error {result options} {
                set imginfo -1
                error "error(snap): [dict get $options -errorinfo]"
            } finally {
                catch {close $fp}
                my CloseBrowser $sock
            }
        }

        method Handler {sock type msg} {
            # Capture messages from websocket.
            #
            # sock    - websocket
            # type    - type message websocket
            # msg     - message websocket
            # timeout - time to execute JS function (milliseconds)
            #
            my variable forever
            my variable isrendered
            my variable browser
            my variable imginfo
            my variable connection
            my variable jschartvar

            if {$browser == 2} {return}

            switch -exact -- $type {
                text {
                    if {
                        [string match {*data:image/png;base64*} $msg] ||
                        [string match {*<svg *} $msg]
                    } {
                        my BrowserRender $msg $sock
                    } elseif {[string match {*TypeError*} $msg]} {
                        puts stderr "error(snap): '$msg'"
                        set imginfo -1
                        my CloseBrowser $sock
                    } elseif {[string match {*target_closed*} $msg]} {
                        ::websocket::close $sock
                        set forever 1
                    } elseif {
                        [string match {*"result":{}*} $msg] && 
                        !$isrendered && ($connection == 2)
                    } {
                        puts stderr "warning(snap): 'jsondata' is not available, try\
                                     to increase `-timeout` property in the 'SnapShot'\
                                     method argument options."
                        set imginfo -1
                        my CloseBrowser $sock
                    } elseif {
                        [string match {*ReferenceError*} $msg] &&
                        !$isrendered
                    } {
                        set d [ticklecharts::messageToDict $msg]
                        if {[dict exists $d result result description]} {
                            set info [dict get $d result result description]
                        } else {
                            set info $msg
                        }
                        # Try running the command again.
                        if {
                            ($connection <= 2) &&
                            [string match "*$jschartvar is not defined*" $info]
                        } {
                            my Runtime $sock
                            incr connection
                        } else {
                            puts stderr "error(snap): $info"
                            set imginfo -1
                            my CloseBrowser $sock
                        }
                    } elseif {[string match {*"id":99,"result"*} $msg]} {
                        if {$::ticklecharts::snapdebug} {
                            puts stderr "DEBUG PAGE INFO: $msg"
                        }
                    } elseif {[string match {*"exception":*} $msg]} {
                        set d [ticklecharts::messageToDict $msg]
                        if {[dict exists $d result result description]} {
                            puts stderr "error(snap): [dict get $d result result description]"
                        }
                        set imginfo -1
                        my CloseBrowser $sock
                    } else {
                        if {$::ticklecharts::snapdebug} {
                            puts stderr "DEBUG INFO: $msg"
                        }
                    }
                }
            }
        }

        method Runtime {sock} {
            # Execute Js function.
            #
            # sock - websocket
            #
            # Return nothing
            my variable js
            my variable timeout
            my variable jschartvar

            set conninfo [websocket::conninfo $sock state]

            if {$::ticklecharts::snapdebug} {
                puts stderr "DEBUG: Runtime - WebSocket state: $conninfo"
            }

            if {$conninfo ne "CONNECTED"} {
                puts stderr "warning(snap): [websocket::conninfo $sock state]"
                my CloseBrowser $sock
            } else {
                after $timeout
                if {$::ticklecharts::snapdebug} {
                    set debugScript [subst {
                        JSON.stringify({
                            url: window.location.href,
                            title: document.title,
                            bodyLength: document.body ? document.body.innerHTML.length : 0,
                            scripts: Array.from(document.scripts).map(s => ({
                                src: s.src || 'inline',
                                loaded: s.src ? s.complete : true
                            })),
                            hasEcharts: typeof echarts !== 'undefined',
                            chartVars: Object.keys(window).filter(k => k.startsWith('${jschartvar}')),
                            echartsVersion: typeof echarts !== 'undefined' ? echarts.version : 'not loaded'
                        })
                    }]
                    # Debug page info.
                    set debugCmd [subst {
                        {
                            "id": 99,
                            "method": "Runtime.evaluate",
                            "params": {
                                "expression": "$debugScript"
                            }
                        }
                    }]

                    websocket::send $sock text $debugCmd
                    after $timeout
                }
                set jsonData [subst {
                    { 
                        "id": 1,
                        "method": "Runtime.evaluate",
                        "params": {
                            "expression": "$js"
                        }
                    }
                }]
                websocket::send $sock text $jsonData
            }

            return {}
        }

        method CloseBrowser {sock} {
            # Try to close the browser properly.
            #
            # sock - websocket
            #
            # Return nothing
            my variable forever

            if {
                ($sock ne "") && 
                ![catch {websocket::conninfo $sock state} state]
            } {
                if {$state eq "CONNECTED"} {
                    set jsonData {{"id": 1, "method": "Browser.close"}}
                    websocket::send $sock text $jsonData
                }
                websocket::close $sock
            }

            set forever 1

            return {}
        }

        # export new method.
        export SnapShot
    }
}

proc ticklecharts::htmlTmpFile {html} {
    # Create a temporary file.
    #
    # html - html string
    #
    # Returns full path.
    set tmpdir ""
    foreach tmp {TMP TEMP TMPDIR} {
        if {[info exists ::env($tmp)]} {
            set tmpdir $::env($tmp)
            break
        }
    }
    # Temp directory not found, writes file 
    # according to script directory.
    if {$tmpdir eq ""} {set tmpdir [info script]}

    set htmltmpfile [file join $tmpdir [clock click].html]
    set fp [open $htmltmpfile w+]
    puts $fp $html
    close $fp

    return $htmltmpfile
}

proc ticklecharts::messageToDict {msg} {
    # Transform Json to dict.
    #
    # msg - json data
    #
    # Returns dict.
    set h [huddle::json2huddle $msg]

    return [huddle get_stripped $h]
}