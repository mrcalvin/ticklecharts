lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# v1.0 : Initial example
# v2.0 : Replace 'render' method by 'Render' (Note the first letter in capital letter...)

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set chart [ticklecharts::chart new]
               
$chart Xaxis -data [list {"Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"}]
$chart Yaxis
$chart AddBarSeries -data [list {120 200 150 80 70 110 130}] \
                    -showBackground "True" \
                    -backgroundStyle {color "rgba(180, 180, 180, 0.2)"}


set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$chart Render -outfile [file join $dirname $fbasename.html] -title $fbasename