tests
checkFunction: aSqlFunction withArgs: aCollection withReturnType: aReturnTypeName

	| args |
	args := aSqlFunction arguments collect: [ :arg | 
		        arg name -> arg datatype name ].
	self assert: args asSet equals: aCollection asSet.
	self assert: aSqlFunction returnType name equals: aReturnTypeName