tests
testSQLStandardBody
	| function |
	db postgresql databaseMajorVersion < 14 ifTrue: [ self skip ].
	client execute: ('CREATE FUNCTION {1}.standard_body(integer) RETURNS integer LANGUAGE sql RETURN $1 + 1;' format: { schemaName }).
	db extractObjects.
	function := db getFunctions detect: [ :f | f name = 'standard_body' and: [ f namespace name = schemaName ] ].
	self assert: (function code includesSubstring: 'RETURN').
	self assert: (function code includesSubstring: '$1')
