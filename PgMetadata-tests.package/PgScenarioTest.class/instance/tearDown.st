running
tearDown
	[ client ifNotNil: [
		[ schemaName ifNotNil: [ client execute: 'DROP SCHEMA IF EXISTS ' , schemaName , ' CASCADE' ] ]
			ensure: [ db close ] ] ] ensure: [ super tearDown ]
