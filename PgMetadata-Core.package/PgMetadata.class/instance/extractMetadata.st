action
extractMetadata
	| db |
	db := PgDatabase name: self database connection: self connection.
	[ db connect ] ensure: [ db close ].
	^db
