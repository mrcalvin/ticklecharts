lappend auto_path [file dirname [file dirname [file dirname [file normalize [info script]]]]]


if {[catch {package present ticklecharts}]} {package require ticklecharts}

set chart [ticklecharts::chart new]

$chart SetOptions -title   {text "Temperature Change"} \
                 -legend  {show True} \
                 -tooltip {show True trigger "axis"}
               
$chart Xaxis -data [list {"Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"}] \
            -boundaryGap "False"
            
$chart Yaxis -axisLabel {formatter "<0123>value<0125> °C"}

                
$chart AddLineSeries -name "Highest" \
                -data [list {10 11 13 11 12 12 9}] \
                -markPoint {data {{type max name "Max"} {type min name "Min"}}} \
                -markLine  {data {objectItem {type average name "Avg"}}}
                
$chart AddLineSeries -name "Lowest" \
                -data [list {1 -2 2 5 3 2 0}] \
                -markPoint {data {{name "other" value -2 xAxis 1 yAxis 0}}} \
                -markLine  {data {
                                objectItem {type average name "Avg"}
                                lineItem {
                                        {symbol none x "90%" yAxis "max"} 
                                        {symbol circle label {position "start" formatter "Max"} type "max" name "other2"}
                                    }
                                    }
                            }  

set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$chart render -outfile [file join $dirname $fbasename.html] -title $fbasename