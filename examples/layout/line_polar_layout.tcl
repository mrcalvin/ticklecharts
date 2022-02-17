lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set num  {1 2 3 4 5}
set num1 {2 3.6 6 2 10}

set line [ticklecharts::chart new]
                  
$line SetOptions -title   {text "Line..." top "55%"} \
                 -tooltip {show "True"}          
    
$line Xaxis -data [list $num] -boundaryGap "False"
$line Yaxis
$line AddLineSeries -data [list $num]  -areaStyle {} -smooth true
$line AddLineSeries -data [list $num1] -smooth true


set polar [ticklecharts::chart new]

$polar SetOptions -polar {radius "50%"} \
                  -title   {text "Polar..."} \
                  -legend {}

$polar RadiusAxis -data [list {v w x y z}] -type "category" -z 10
$polar AngleAxis  -max 2 -startAngle 30 -splitLine {show "false"}

$polar AddBarSeries -data [list {4 3 2 1 0}] \
                    -coordinateSystem "polar" \
                    -name "Without Round Cap" \
                    -itemStyle {borderColor "red" opacity 0.8 borderWidth 1}


set layout [ticklecharts::Gridlayout new]
$layout Add $line  -top    "60%"
$layout Add $polar -center [list {"50%" "30%"}]

set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$layout render -outfile [file join $dirname $fbasename.html] \
               -title $fbasename \
               -width 1900px \
               -height 1000px