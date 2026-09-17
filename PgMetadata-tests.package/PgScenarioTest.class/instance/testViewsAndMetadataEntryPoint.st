tests
testViewsAndMetadataEntryPoint
	| otherSchema metadata views materialized |
	otherSchema := schemaName , '_other'.
	[
		client execute: ('CREATE SCHEMA {2}; CREATE VIEW {1}.same_name AS SELECT 1 AS value; CREATE VIEW {2}.same_name AS SELECT 2 AS value; CREATE MATERIALIZED VIEW {1}.snapshot AS SELECT 3 AS value;' format: { schemaName. otherSchema }).
		metadata := (PgMetadata database: self class connectionParameters database
			connection: self class connectionParameters) extractMetadata.
		self assert: metadata name equals: self class connectionParameters database.
		views := metadata getViews select: [ :v | v name = 'same_name' ].
		self assert: views size equals: 2.
		self assert: (views detect: [ :v | v namespace name = schemaName ]) code
			equals: ' SELECT 1 AS value'.
		self assert: (views detect: [ :v | v namespace name = otherSchema ]) code
			equals: ' SELECT 2 AS value'.
		materialized := metadata getMaterializedViews detect: [ :v | v name = 'snapshot' ].
		self assert: materialized namespace name equals: schemaName.
		self assert: (materialized code includesSubstring: '3 AS value')
	] ensure: [ client execute: 'DROP SCHEMA IF EXISTS ' , otherSchema , ' CASCADE' ]
