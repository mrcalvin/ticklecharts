lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# v1.0 : Initial example
# v1.0 : Adds pieces.
# v2.0 : Adds markarea.
# v3.0 : Replace 'render' method by 'Render' (Note the first letter in capital letter...)

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set chart [ticklecharts::chart new]

$chart SetOptions -title {text "Distribution of Electricity" subtext "Fake Data"} \
                  -visualMap {
                                type "piecewise"
                                show "False"
                                dimension 0
                                pieces {
                                    {lte 6 color "green"}
                                    {gt 6 lte 8 color "red"}
                                    {gt 8 lte 14 color "green"}
                                    {gt 8 lte 14 color "green"}
                                    {gt 14 lte 17 color "red"}
                                    {gt 17 color "green"}
                                }
                            } \
                   -tooltip {trigger "axis" axisPointer {type cross}}
                            
                
$chart Xaxis -boundaryGap "False" \
             -data [list {00:00 01:15 02:30 03:45 05:00 06:15
                          07:30 08:45 10:00 11:15 12:30 13:45
                          15:00 16:15 17:30 18:45 20:00 21:15
                          22:30 23:45}]
                                        
$chart Yaxis -axisLabel   {formatter "<0123>value<0125> W"} \
             -axisPointer {snap "True"}

$chart AddLineSeries -smooth "True" \
                     -name {Electricity} \
                     -data [list {300 280 250 260 270
                                  300 550 500 400 390
                                  380 390 400 500 600
                                  750 800 700 600 400
                                  }] \
                    -markArea {
                        itemStyle {color "rgba(255, 173, 177, 0.4)"}
                        data {
                            {{name "Morning Peak" xAxis "07:30"} {xAxis "10:00"}}
                            {{name "Evening Peak" xAxis "17:30"} {xAxis "21:15"}}
                            }
                        }

set fbasename [file rootname [file tail [info script]]]
set dirname   [file dirname [info script]]

$chart Render -outfile [file join $dirname $fbasename.html] -title $fbasename