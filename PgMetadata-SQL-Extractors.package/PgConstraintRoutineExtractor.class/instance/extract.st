action
extract
	| constraints functions |
	constraints := Dictionary new.
	self database getConstraints do: [ :constraint | constraints at: constraint oid put: constraint ].
	functions := Dictionary new.
	self database getFunctions do: [ :function | functions at: function oid put: function ].
	self runSQL recordsAsDictionaries do: [ :row |
		constraints at: (row at: #constraint_oid) ifPresent: [ :constraint |
			functions at: (row at: #function_oid) ifPresent: [ :function |
				constraint calledFunctions add: function ] ] ]
