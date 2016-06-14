
-- Unificamos la tabla de clientes con el segmento al que pertenece cada uno
	drop table tablon;
	create table tablon as
	select
		*
	from clientes_unicos as a
		inner join segmentacion as b
			on a.document_number = b.cliente;
	--738.533


	select count(*) from clientes_unicos;--738.533
	select count(*) from segmentacion;--231.973
	select count(*) from tablon;--738.533


-- Creamos una tabla para las visualizaciones de tableau

	-- Características de la segmentación
	drop table variables_am;
	create table variables_am as
	select
		segmento,
		document_number,
		creation_date,
		frecuencia,
		recencia,
		money,
		gender,
		age,
		case 
			when cabin_code = 'Y' then 'Economy'
			when cabin_code in ('F','C') then 'First'
			when cabin_code = 'J' then 'Business'
			when cabin_code = 'W' then 'Economy Premium'
			else 'Otros'
		end as cabin_code,
		to_char(departure_date_leg, 'Day') as dia_semana_vuelo,
		to_char(creation_date, 'Day') as dia_semana_compra,
		advance_purchase,
		board_point,
		board_continent_code,
		off_point,
		off_continent_code,
		route,
		case 
			when flight_type = 'D' then 'Domestico'
			when flight_type = 'I' then 'Internacional'
			else 'Otros'
		end as flight_type,
		fuel_surcharge_amount_seg
	from tablon as a
	;

	--Duración vuelos
	drop table duracion_viaje;
	create table duracion_viaje as
	select
		document_number,
		segmento,
		creation_date,
		max(departure_date_leg) - min (departure_date_leg) as duracion,
		to_char(min(departure_date_leg), 'Day') as dia_ida,
		to_char(max(departure_date_leg), 'Day') as dia_vuelta,
		to_char(creation_date, 'Day') as dia_semana_compra
	from tablon
	group by 1,2,3;

	-- Preparamos la tabla para las coordenadas de los aeropuertos
	--Coordenadas aeropuertos
	drop table public.coordenadas;
	create table public.coordenadas as
	select
		a.route as path,
		a.board_point,
		a.board_country_code,
		a.board_lat,
		a.board_lon,
		a.off_point,
		a.off_country_code,
		a.off_lat,
		a.off_lon,
		a.distance_seg,
		count(*) as num_trayectos
	from public.clientes_unicos as a
		inner join public.segmentacion as b
			on a.document_number = b.cliente
	group by 
		a.route,
		a.board_point,
		a.board_country_code,
		a.board_lat,
		a.board_lon,
		a.off_point,
		a.off_country_code,
		a.off_lat,
		a.off_lon,
		a.distance_seg
	order by 2,3,5,6;
	
	
	
	drop table paths;
	create table public.paths as
	select 
		a.*,
		1 as path_order
	from public.coordenadas as a
	union all
	select 
		a.*,
		2 as path_order
	from public.coordenadas as a
	order by path,path_order
	;
	
	-- Tabla de la que tomará los datos Tableau
	drop table aeropuertos;
	create table aeropuertos as
	select 
		a.segmento,
		c.*,
		case when path_order = 1 then b.board_lat else b.off_lat end as latitude,
		case when path_order = 1 then b.board_lon else b.off_lon end as longitude,
		count(*) as num_trayectos_segmento
		
	from segmentacion as a
		inner join clientes_unicos as b
			on a.cliente = b.document_number
		inner join paths as c
			on b.board_lat = c.board_lat
			and b.board_lon = c.board_lon
			and b.off_lat = c.off_lat
			and b.off_lon = c.off_lon
	group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	order by path,path_order;