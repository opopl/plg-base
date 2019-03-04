create table if not exists files (
	id integer primary key asc,
	fileid varchar(255) unique,
	type varchar(255),
	file varchar(255)
)