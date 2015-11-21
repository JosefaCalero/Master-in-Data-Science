dsc: opentraveldata % csvlook -d'^' optd_airlines.csv less -S                                                                           
dsc: opentraveldata 2 % csvlook -d'^' optd_airlines.csv | less -S                                                                       
dsc: opentraveldata 1 % cp *.csv /tmp                                                                                                   
dsc: opentraveldata % chmod a+r /tmp/*.csv                                                                                              
dsc: opentraveldata % cvssql -d '^' optd_airlines.csv                                                                                   
dsc: opentraveldata 127 % csvsql -d '^' optd_airlines.csv                                                                               
dsc: opentraveldata % csvsql -d '^' optd_airlines.csv -i postgresql | psql optd                                                         
dsc: opentraveldata % csvsql -d '^' ref_airline_nb_of_flights.csv -i postgresql | psql optd                                         
CREATE TABLE
dsc: opentraveldata % psql optd  
optd=# copy optd_airlines from '/tmp/optd_airlines.csv' delimiter '^' csv header
copy ref_airline_nb_of_flights from '/tmp/ref_airline_nb_of_flights.csv' delimiter '^' csv header;

COMENZAMOS A HACER QUERIES CON LEFT AND RIGTH JOIN

Queremos añadir por ejemplo el nombre de las aerolineas a la tabla de los metadatos de la aerolinea 

codigo airline | num vuelos | nombre aerolinea

SELECT airline_code_2c, name, flight_freq 
FROM ref_airline_nb_of_flights AS r
LEFT OUTER JOIN optd_airlines AS o
ON o."2char_code" = r.airline_code_2c;
Comprobamos si hay duplicados o no
optd=# select count(*) from ref_airline_nb_of_flights;  

Como hay valores duplicados no podemos modificar la query para que lo evite, lo unico que podemos hacer es arreglar la tabla de origen. No podemmos confiar en el codigo IATA porque lo duplica. 

Hay que comprobar que la clave que estas utilizando para unir es única para evitar estos problemas de duplicados

Ahora vammos a sacar el top ten de aerolineas por numero de vuelos

SELECT airline_code_2c, name, flight_freq 
FROM ref_airline_nb_of_flights AS r
LEFT OUTER JOIN optd_airlines AS o
ON o."2char_code" = r.airline_code_2c 
order by flight_freq DESC limit 10;


Ahora invertimos las tablas. A optd es la de la izquierda a la que le agregamos los datos de las aerolineas. 
SELECT airline_code_2c, name, flight_freq 
FROM optd_airlines AS o
LEFT OUTER JOIN ref_airline_nb_of_flights AS r
ON o."2char_code" = r.airline_code_2c 
order by flight_freq DESC limit 10;

Vamos ahora a hacer un right outer join

SELECT airline_code_2c, name, flight_freq 
FROM ref_airline_nb_of_flights AS r
right OUTER JOIN optd_airlines AS o
ON o."2char_code" = r.airline_code_2c 
;

SELECT airline_code_2c, name, flight_freq 
FROM optd_airlines AS o
right OUTER JOIN ref_airline_nb_of_flights AS r
ON o."2char_code" = r.airline_code_2c 
order by flight_freq DESC limit 10;

Ahora vamos a hacer queries dentro de una query
ejemplo: Ciudades con una altitud por encima de la media

SELECT name, country_name, elevation 
from optd_por_public
where elevation > (SELECT avg(elevation) from
optd_por_public) and location_type='C'
limit 10;

Comprobamos el valor medio de las elevaciones solo de las ciudades
optd=# select avg(elevation) from optd_por_public where elevation is not null and location_type ='C';

SELECT country_name, count(*) 
from optd_por_public
having elevation > (SELECT avg(elevation) from
optd_por_public) where elevation is not null and location_type='C'
group by country_name
limit 10;

El top tres de ciudades con una elevacion mayor a la media
SELECT country_name, count(*) as n 
from optd_por_public
where elevation > (
    SELECT avg(elevation) from optd_por_public 
    where elevation is not null and location_type='C') and location_type='C'
group by country_name 
having count(*) >=3;





