# stroke animation available for echarts 5.3.0 and above...
# cdn changed to 5.3.0... for this example

lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set chart [ticklecharts::chart new]

$chart AddGraphic -elements [list \
                                [list \
                                    type "text" left "center" top "center" \
                                    style [list \
                                                text "Apache ECharts" fontSize 80 \
                                                fontWeight "bold" lineDash [list {0 200}] \
                                                lineDashOffset 0 fill "transparent" \
                                                stroke "#000" lineWidth 1 \
                                        ] \
                                    keyframeAnimation [list \
                                                            [list duration 3000 \
                                                                loop "True" \
                                                                keyframes [list \
                                                                                [list percent 0.7 \
                                                                                    style [list fill "transparent" \
                                                                                                lineDashOffset 200 \
                                                                                                lineDash [list {200 0}]
                                                                                        ] \
                                                                                ] \
                                                                                {percent 0.8 style {fill "transparent"}} \
                                                                                {percent 1   style {fill "black"}} \
                                                                            ] \
                                                            ] \
                                                    ] \
                                ]\
                            ]

set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$chart render -outfile [file join $dirname $fbasename.html] \
              -title $fbasename \
              -jschartvar "mychart" \
              -divid "id_chart" \
              -jsecharts "https://cdn.jsdelivr.net/npm/echarts@5.3.0/dist/echarts.min.js"