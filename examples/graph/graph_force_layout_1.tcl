lappend auto_path [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

# source all.tcl
if {[catch {package present ticklecharts}]} {package require ticklecharts}

try {
    # https://wiki.tcl-lang.org/page/HTTPS
    #
    package require http 2
    package require tls 1.7
    package require json

    http::register https 443 [list ::tls::socket -autoservername true]
    set token [http::geturl https://raw.githubusercontent.com/apache/echarts-examples/gh-pages/public/data/asset/data/les-miserables.json]

    set htmldata [::http::data $token]
    set datajson [json::json2dict $htmldata]

    set chart [ticklecharts::chart new]

    $chart SetOptions -title {text "Les Miserables" subtext "Default layout" top "bottom" left "right"} \
                      -tooltip {} \
                      -legend [list dataLegendItem [dict get $datajson categories]]

    $chart AddGraphSeries -name "Les Miserables" \
                          -layout "force" \
                          -data [lmap v [dict get $datajson nodes] {format {%s symbolSize 5} $v}] \
                          -links [dict get $datajson links] \
                          -categories [dict get $datajson categories] \
                          -roam "True" \
                          -label {show "False" position "right"} \
                          -force {repulsion 100}

    set fbasename [file rootname [file tail [info script]]]
    set dirname [file dirname [info script]]

    $chart Render -outfile [file join $dirname $fbasename.html] -title $fbasename -height 900px -width 900px

} on error {result options} {
    puts stderr "[info script] : $result"
}

