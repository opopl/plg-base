
CREATE TABLE IF NOT EXISTS buffers (	
	attr text,
	ext TEXT,
	fullname TEXT,
	line TEXT,
	path TEXT,
	pathtail TEXT,
	relativename TEXT,
	relativepath TEXT,
	shortname TEXT,
	num INTEGER UNIQUE,
	hasNoName INTEGER
);
