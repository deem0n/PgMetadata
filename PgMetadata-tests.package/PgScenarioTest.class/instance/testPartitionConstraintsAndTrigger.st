tests
testPartitionConstraintsAndTrigger
	| parent child trigger function constraint applicationFunctions |
	client execute: ('
CREATE TABLE {1}.events (id integer NOT NULL, payload text DEFAULT ''new'', CONSTRAINT positive_id CHECK (id > 0)) PARTITION BY RANGE(id);
CREATE TABLE {1}.events_low PARTITION OF {1}.events FOR VALUES FROM (1) TO (100);
CREATE FUNCTION {1}.normalize_event() RETURNS trigger LANGUAGE plpgsql AS $body$ BEGIN NEW.payload := upper(NEW.payload); RETURN NEW; END $body$;
CREATE TRIGGER normalize_event BEFORE INSERT ON {1}.events FOR EACH ROW EXECUTE FUNCTION {1}.normalize_event();
' format: { schemaName }).
	db extractObjects.
	parent := db getTables detect: [ :t | t name = 'events' ].
	child := db getTables detect: [ :t | t name = 'events_low' ].
	self assert: (child parents includes: parent).
	constraint := db getConstraints detect: [ :c | c name = 'positive_id' and: [ c owner = parent ] ].
	self assert: (constraint code includesSubstring: 'CHECK').
	self assert: (constraint code includesSubstring: 'id > 0').
	applicationFunctions := db getFunctions select: [ :f | f namespace name = schemaName ].
	self assert: applicationFunctions size equals: 1.
	function := applicationFunctions anyOne.
	self deny: function isStub.
	self assert: (function code includesSubstring: 'NEW.payload').
	trigger := db getTriggers detect: [ :t | t name = 'normalize_event' and: [ t table = parent ] ].
	self assert: trigger function identicalTo: function.
	self assert: trigger isBefore.
	self assert: trigger isInsert
