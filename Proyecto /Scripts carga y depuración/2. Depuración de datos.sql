--Comprobaciones

	--Vemos el número de registros de la tabla
	SELECT 
	  count(*),
	  count(distinct rloc)
	FROM 
	  vuelos
	;--9546302	2605835


	--documentos distintos
	select 
		count(document_number)
	from vuelos
	where document_number is not null;--828.875


	--Fechas de salida de los vuelos
	create table fechas_salida_vuelos as
	select 
		departure_date_leg,
		count(*)
	from vuelos 
	group by departure_date_leg
	order by 1
	;



--depuración de la tabla para eliminar ruido
	create table vuelos_clientes
	select * 
	from vuelos
	where 
		departure_date_leg between '2013-01-01'::date and '2014-04-07'::date
		and quality_index = 1
		and document_number is not null
		and booking_status_code='HK'
	order by document_number,rloc,departure_date_leg;--

	select count(*) from vuelos_clientes;--777978
	select count(distinct document_number) from vuelos_clientes;--235331





--Eliminamos clientes duplicados
	--Nos quedamos con los documentos que no estén duplicados
	create table documentos_unicos as
	select document_number,count(*) from (
		select
			document_number,
			gender,
			date_of_birth,
			nationality,
			count(*) as count
		from clientes
		group by document_number,
			gender,
			date_of_birth,
			nationality
	) as a
	group by document_number 
	having count(*)=1
	;--231974



	--Cruzamos los documentos no duplicados con nuestra tabla origen
	create table clientes_unicos as
	select
		a.*
	from clientes as a
		inner join documentos_unicos as b
			on a.document_number = b.document_number
	;

	select count(*) from clientes_unicos;--738.533
	select count(distinct document_number) from clientes_unicos;--231.974


-- Preparación de las variables de la segmentación
	create table rfm_doc_unicos as
	select 
		document_number,
		count(distinct(document_number || '-' || rloc)) as frecuencia,
		 '2014-04-07'::date - max(departure_date_leg) as recencia,
		sum(revenue_amount_seg) as money
	from clientes_unicos
	group by document_number;
