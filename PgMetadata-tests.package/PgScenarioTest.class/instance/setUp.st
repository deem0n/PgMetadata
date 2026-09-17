running
setUp
	super setUp.
	db := PgDatabase name: self class connectionParameters database
		connection: self class connectionParameters.
	db connect.
	client := db connection.
	schemaName := 'pgmetadata_test_' , (UUID new asString copyWithout: $-).
	client execute: 'CREATE SCHEMA ' , schemaName
