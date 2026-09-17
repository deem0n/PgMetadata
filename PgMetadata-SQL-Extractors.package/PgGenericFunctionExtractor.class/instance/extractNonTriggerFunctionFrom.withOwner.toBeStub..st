action
extractNonTriggerFunctionFrom: func withOwner: owner toBeStub: isStub
	| argtypes function argnames argmodes |
	function := (func at: #prokind) = 'a'
		ifTrue: [ SqlAggregateFunction
				oid: (func at: #oid)
				name: (func at: #proname)
				owner: owner
				stub: isStub ]
		ifFalse: [ SqlFunction
				oid: (func at: #oid)
				name: (func at: #proname)
				owner: owner
				stub: isStub ].
	argnames := func at: #proargnames.
	argmodes := func at: #proargmodes.
	argtypes := self extractArgumentsTypesFrom: func.
	argtypes withIndexDo: [ :argtype :index |
		| argumentName argument |
		argumentName := argnames ifNil: [ '' ] ifNotNil: [ argnames at: index ].
		argumentName ifEmpty: [ argumentName := '$' , index asString ].
		argument := SqlArgument name: argumentName datatype: argtype owner: function.
		argument position: index;
			mode: (argmodes ifNil: [ 'i' ] ifNotNil: [ argmodes at: index ]).
		function addArgument: argument ].
	^ function
