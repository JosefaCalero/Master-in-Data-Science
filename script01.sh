#/bin/sh
# linea de comandos para orden
csvsort -d '^' -c $2 -r $1 | head -2 | csvcut -c model | tail -n 1