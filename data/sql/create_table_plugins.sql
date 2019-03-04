create table if not exists plugins (
	id integer primary key asc,
	plugin varchar(255) unique
)