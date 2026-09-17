tests
testReservedCharacters
	| parameters url client |
	parameters := PgConnection hostname: 'localhost' port: 5435 database: 'db/name'
		user: 'user@name' password: 'p@ss:/?#%'.
	url := parameters computeURL asUrl.
	self assert: url username equals: parameters user.
	self assert: url password equals: parameters password.
	self assert: url firstPathSegment equals: parameters database.
	client := parameters newClient.
	self assert: client user equals: parameters user.
	self assert: client password equals: parameters password.
	self assert: client database equals: parameters database
