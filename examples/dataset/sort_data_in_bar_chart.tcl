lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set dimensions {name age profession score date}

set source {
        {"Hannah Krause" 41 "Engineer" 314 "2011-02-12"}
        {"Zhao Qian"     20 "Teacher"  351 "2011-03-01"}
        {"Jasmin Krause" 52 "Musician" 287 "2011-02-14"}
        {"Li Lei"        37 "Teacher"  219 "2011-02-18"}
        {"Karle Neumann" 25 "Engineer" 253 "2011-04-02"}
        {"Adrian Groß"   19 "Teacher"  "-" "2011-01-16"}
        {"Mia Neumann"   71 "Engineer" 165 "2011-03-19"}
        {"Böhm Fuchs"    36 "Musician" 318 "2011-02-24"}
        {"Han Meimei"    67 "Engineer" 366 "2011-03-12"}
      }

# dataset class
set dset [ticklecharts::dataset new -dimensions $dimensions \
                                    -source $source \
                                    -transform {{type "sort" config {dimension "score" order "desc"}}}]

set chart [ticklecharts::chart new]

$chart SetOptions -dataset $dset
               
$chart Xaxis -type "category" -axisLabel {interval 0 rotate 30}
$chart Yaxis -type "value"
$chart AddBarSeries -encode {x "name" y "score"} -datasetIndex 1 


set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$chart render -outfile [file join $dirname $fbasename.html] -title $fbasename