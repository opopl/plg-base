create table if not exists exefiles (
	id integer primary key asc,
	fileid varchar(255) unique,
	file varchar(255),
	pc varchar(255)
)