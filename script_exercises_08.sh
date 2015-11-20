#/bin/sh
# linea de comandos para orden
csvsort -d'^' -c nb_engines -r $1 | csvgrep -c manufacturer -m $2 | csvcut -c model| head -2 | csvlook 
