lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# v1.0 : Initial example
# v2.0 : Update example with the new 'Add' method for chart series.

proc fakerRandomData {min max len} {

    set range [expr {$max - $min}]
    set fakerdata {}

    for {set i 0} {$i < $len} {incr i} {
        lappend fakerdata [expr {int(rand() * $range) + $min}]
    }

    return $fakerdata
}

proc fakerRandomXaxisData {} {

    set month {"Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"}

    set fakermonthdata {}
    set len [llength $month]

    for {set i 0} {$i < $len} {incr i} {
        lappend fakermonthdata [lindex $month [expr {int(rand() * $len)}]]
    }

    return $fakermonthdata
}

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set timeline [ticklecharts::timeline new]

$timeline SetOptions -axisType "category"

for {set i 2018} {$i < 2023} {incr i} {
    set chart [ticklecharts::chart new]
    $chart SetOptions -legend {} -tooltip {} -title [list text $i]

    $chart Xaxis -type category -data [list [fakerRandomXaxisData]] 
    $chart Yaxis -type value

    $chart Add "barSeries" -data [list [fakerRandomData 10 100 12]]
    $chart Add "barSeries" -data [list [fakerRandomData 50 200 12]]

    $timeline Add $chart -data [list value $i]

}

                 
set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$timeline Render -outfile [file join $dirname $fbasename.html] -title $fbasename