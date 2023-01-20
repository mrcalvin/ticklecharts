lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set jsX [ticklecharts::jsfunc new {function (u, v) {
          return Math.sin(v) * Math.sin(u);
        },
    }]

set jsY [ticklecharts::jsfunc new {function (u, v) {
          return Math.sin(v) * Math.cos(u);
        },
    }]

set jsZ [ticklecharts::jsfunc new {function (u, v) {
          return Math.cos(v);
        },
    }]

set chart3D [ticklecharts::chart3D new]

$chart3D SetOptions -tooltip {} \
                    -grid3D {} \
                    -visualMap  [list \
                                type "continuous" \
                                show "False" \
                                dimension 2 \
                                min -1 max 1 \
                                inRange [list color [list {#313695 #4575b4 #74add1 #abd9e9 #e0f3f8 #ffffbf #fee090 #fdae61 #f46d43 #d73027 #a50026}]] \
                            ]

$chart3D Xaxis3D
$chart3D Yaxis3D
$chart3D Zaxis3D

$chart3D AddSurfaceSeries -parametric "True" \
                          -parametricEquation [list \
                            u [list min -3.14 max 3.14 step [expr {3.14 / 20.}]] \
                            v [list min 0     max 3.14 step [expr {3.14 / 20.}]] \
                            x $jsX \
                            y $jsY \
                            z $jsZ \
                          ]

set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$chart3D Render -outfile [file join $dirname $fbasename.html] \
                -title $fbasename