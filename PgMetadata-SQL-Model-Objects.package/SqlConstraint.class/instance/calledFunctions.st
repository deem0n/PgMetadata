accessing
calledFunctions
	^ self privateState at: #calledFunctions ifAbsentPut: [ Set new ]
