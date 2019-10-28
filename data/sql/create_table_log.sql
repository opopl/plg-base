
CREATE TABLE IF NOT EXISTS log (
	msg TEXT,
	time INTEGER,
	elapsed INTEGER,
	loglevel TEXT,
	func TEXT,
	plugin TEXT,
	prf TEXT,
	v_exception TEXT
);
