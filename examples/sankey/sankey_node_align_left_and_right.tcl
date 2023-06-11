lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# v1.0 : Initial example
# v2.0 : Update example with the new 'Add' method for chart series.

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

try {
    # https://wiki.tcl-lang.org/page/HTTPS
    #
    package require http 2
    package require tls 1.7
    package require json

    http::register https 443 [list ::tls::socket -autoservername true]
    set token [http::geturl https://raw.githubusercontent.com/apache/echarts-examples/gh-pages/public/data/asset/data/energy.json]

    set htmldata [::http::data $token]
    set datajson [json::json2dict $htmldata]

    set chart [ticklecharts::chart new]

    # first file
    $chart SetOptions -title {text "Node Align Right"} \
                      -tooltip {trigger "item" triggerOn "mousemove"}


    $chart Add "sankeySeries" -nodeAlign "left" -data [dict get $datajson nodes] -links [dict get $datajson links] \
                              -emphasis {focus "adjacency"} \
                              -lineStyle {color "gradient" curveness 0.5 opacity 0.2}
            

    set fbasename "sankey_node_align_left"
    set dirname [file dirname [info script]]

    $chart Render -outfile [file join $dirname $fbasename.html] -title $fbasename -width 1200px -height 1000px

    # second file
    set chart [ticklecharts::chart new]

    $chart SetOptions -title {text "Node Align Left"} \
                      -tooltip {trigger "item" triggerOn "mousemove"}


    $chart Add "sankeySeries" -nodeAlign "right" -data [dict get $datajson nodes] -links [dict get $datajson links] \
                              -emphasis {focus "adjacency"} \
                              -lineStyle {color "gradient" curveness 0.5 opacity 0.2}
            

    set fbasename "sankey_node_align_right"
    set dirname [file dirname [info script]]

    $chart Render -outfile [file join $dirname $fbasename.html] -title $fbasename -width 1200px -height 1000px
    
} on error {result options} {
    puts stderr "[info script] : $result"
}

