#/bin/sh
# linea de comandos para orden
csvsort -d '^' -c nb_engines -r optd_aircraft.csv | head -2 | csvcut -c model | tail -n 1