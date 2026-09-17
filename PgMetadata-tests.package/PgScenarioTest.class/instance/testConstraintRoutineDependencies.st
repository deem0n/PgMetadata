tests
testConstraintRoutineDependencies
	| check exclusion |
	client execute: ('
CREATE FUNCTION {1}.positive(integer) RETURNS boolean LANGUAGE sql IMMUTABLE AS $body$ SELECT $1 > 0 $body$;
CREATE FUNCTION {1}.span(integer) RETURNS int4range LANGUAGE sql IMMUTABLE AS $body$ SELECT int4range($1,$1+1) $body$;
CREATE TABLE {1}.checked (id integer, CONSTRAINT positive CHECK ({1}.positive(id)), CONSTRAINT nonoverlap EXCLUDE USING gist ({1}.span(id) WITH &&));
' format: { schemaName }).
	db extractObjects.
	check := db getConstraints detect: [ :c | c name = 'positive' ].
	exclusion := db getConstraints detect: [ :c | c name = 'nonoverlap' ].
	self assert: (check calledFunctions collect: #name) equals: #('positive') asSet.
	self assert: (exclusion calledFunctions collect: #name) equals: #('span') asSet.
	self assert: check oid isNotNil.
	self assert: exclusion oid isNotNil
