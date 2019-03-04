create table if not exists datfiles (
	id integer primary key asc,
	key varchar(255) unique,
	plugin varchar(255),
	type varchar(255),
	datfile varchar(255)
)