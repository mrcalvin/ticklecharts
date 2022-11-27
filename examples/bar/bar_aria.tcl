lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set chart [ticklecharts::chart new]

$chart SetOptions -aria {enabled "True" decal {show "True"}}
               
$chart Xaxis -data [list {"Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"}]
$chart Yaxis
$chart AddBarSeries -data [list {120 200 150 80 70 110 130}]
$chart AddBarSeries -data [list {20 40 90 40 30 70 120}]
$chart AddBarSeries -data [list {140 230 120 50 30 150 120}]

set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$chart Render -outfile [file join $dirname $fbasename.html] -title $fbasename