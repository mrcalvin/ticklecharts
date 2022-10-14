# test all files...
lappend auto_path [file dirname [file dirname [file dirname [file normalize [info script]]]]]

package require ticklecharts

# set theme if you want...
# set ::ticklecharts::theme "basic"

# Replaces some huddle/ehuddle procedures by C procedures...
# ticklecharts::eHuddleCritcl 1

set charts {
    bar
    line
    pie
    funnel
    radar
    scatter
    heatmap
    graphic
    sunburst
    tree
    themeriver
    sankey
    layout
    dataset
    pictorialBar
    candlestick
    parallel
    timeline
    gauge
    graph
}

set dir [file dirname [info script]]

# all charts...
foreach fc [split $charts "\n"] {
    set chart [string trim $fc]
    if {[string length $chart] == 0 || [string first "#" $chart] > -1} {continue}
    foreach chartfile [glob -directory [file join $dir $chart] -types f *.tcl] {
        source $chartfile
    }
}