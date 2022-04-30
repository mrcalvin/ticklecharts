lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

set source {
      {"score" "amount" "product"}
      {89.3 58212 "Matcha Latte"}
      {57.1 78254 "Milk Tea"}
      {74.4 41032 "Cheese Cocoa"}
      {50.1 12755 "Cheese Brownie"}
      {89.7 20145 "Matcha Cocoa"}
      {68.1 79146 "Tea"}
      {19.6 91852 "Orange Juice"}
      {10.6 101852 "Lemon Juice"}
      {32.7 20112 "Walnut Brownie"}
      }


# dataset class
set dset [ticklecharts::dataset new -source $source]
set chart [ticklecharts::chart new]

# no need to add -dimensions, it is in source header...
$chart SetOptions -dataset $dset \
                  -visualMap [list type "continuous" orient "horizontal" \
                                   left "center" min 10 max 100 text [list {"High Score" "Low Score"}] \
                                   dimension 0 inRange [list color [list {#65B581 #FFCE34 #FD665F}]]]
                  
               
$chart Xaxis -type "value"    -name "amount"
$chart Yaxis -type "category" -name "category" -boundaryGap "True"
# Map the "amount" column to X axis. + Map the "product" column to Y axis
$chart AddBarSeries -encode {x "amount" y "product"}


set fbasename [file rootname [file tail [info script]]]
set dirname [file dirname [info script]]

$chart render -outfile [file join $dirname $fbasename.html] -title $fbasename