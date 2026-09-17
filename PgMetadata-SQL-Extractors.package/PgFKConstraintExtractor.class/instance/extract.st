action
extract
	| ownertable referencedTable |
	self database getTables
		do: [ :table | 
			| constraint |
			(self runSQLWith: {table oid}) recordsAsDictionaries 
				do: [ :result | 
					"create the constraint instance"
					ownertable := self database
						tableReferenceOf: (result at: #constrained_table).
					constraint := (constraintClasses at: (result at: #contype))
						oid: (result at: #oid)
						name: (result at: #constraint_name)
						owner: ownertable
						namespace: (self database schemaReferenceOf: (result at: #namespace_oid)).
					(constraint class = SqlCheckConstraint
						or: constraint class = SqlExclusionConstraint)
						ifTrue: [ constraint code: (result at: #consrc) ].
					"add the constrained column references, can be nil in case that the constraint is not applied on a column."
					(result at: #num_constrained_columns)
						ifNotNil: [ (result at: #num_constrained_columns)
								do: [ :num | 
									"0 means it is a function like: tstzrange(start_time, expiration_time, '()') WITH &&"
									num = 0
										ifFalse: [ constraint addConstrainedColumn: (ownertable columnAt: num) ] ] ].

					"add the referenced column references"
					(result at: #num_referenced_columns)
						ifNotNil: [ (result at: #num_referenced_columns)
								do: [ :num | 
									referencedTable := self database
										tableReferenceOf: (result at: #referenced_table).
									constraint
										addReferencedColumn: (referencedTable columnAt: num).

									"adding referenced object into the referenced objects of the constrained objects"
									(result at: #num_constrained_columns)
										do: [ :n | 
											(ownertable columnAt: n)
												addReferencedObject: (referencedTable columnAt: num) ]
									"Halt now." ] ].

					"add the constraint to the model"
					self database addObject: constraint ] ]