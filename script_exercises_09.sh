#/bin/sh
# linea de comandos para orden
csvgrep -d'^' -c nb_engines -m $2 $1 | wc -l    