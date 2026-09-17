tests
testTable

	| schema |
	client execute: ('
CREATE TABLE {1}.employees (
	id SERIAL,
	last_name varchar(64) DEFAULT NULL,
	first_name varchar(64) DEFAULT NULL,
	email varchar(64) DEFAULT NULL,
	department varchar(64) DEFAULT NULL,
	salary DECIMAL(10,2) DEFAULT NULL,
	PRIMARY KEY (id)
);
INSERT INTO {1}.employees (id,last_name,first_name,email,department,salary) VALUES (1,''Doe'',''John'',''john.doe@foo.com'',''HR'',55000.00);
' format: { schemaName }).
	db extractObjects.
	schema := db getSchemas detect: [ :s | s name = schemaName ].
	self
		shouldnt: [ db getTables detect: [ :t | t namespace = schema ] ]
		raise: NotFound