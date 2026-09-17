tests
testUnnamedArguments
	| function |
	client execute: ('CREATE FUNCTION {1}.unnamed(integer, text) RETURNS integer LANGUAGE sql AS $body$ SELECT $1 $body$;' format: { schemaName }).
	db extractObjects.
	function := db getFunctions detect: [ :f | f name = 'unnamed' and: [ f namespace name = schemaName ] ].
	self assert: (function arguments collect: #name) asArray equals: #('$1' '$2').
	self assert: (function arguments collect: #position) asArray equals: #(1 2).
	self assert: (function arguments collect: [ :arg | arg datatype name ]) asArray equals: #('int4' 'text').
	self assert: (function arguments collect: #mode) asArray equals: #('i' 'i')
