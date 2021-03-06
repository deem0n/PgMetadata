action
extract
	self runSQL do: [ :item |
		| trigger |
		trigger := (SqlTrigger oid: (item atName: #oid) name: (item atName: #triggername) owner: self database).
		"trigger table: ((self database getTables) detect: [ :t | t oid = (item atName: #table_oid) asInteger ])."
		"trigger actually may be assigned to view!"
		trigger table: (self database getObjectWithOID: (item atName: #table_oid) asInteger).
		trigger function: ((self database getTriggerFunctions) detect: [ :f | f oid = (item atName: #function_oid) asInteger ]).
		
		(trigger table) ifNotNil: [ trigger addReferencedObject: trigger table ].
		(trigger function) ifNotNil: [ trigger addReferencedObject: trigger function ].
		trigger type: (item atName: #tgtype) asInteger.
		self database addObject: trigger.
	]
