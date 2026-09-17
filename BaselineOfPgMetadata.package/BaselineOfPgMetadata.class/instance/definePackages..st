baselines
definePackages: spec
	^ spec
		package: 'PgMetadata-Core' with: [ spec requires: #('P3') ];
		package: 'PgMetadata-SQL-Extractors' with: [ spec requires: #('PgMetadata-Core' 'PgMetadata-SQL-Model-Objects') ];
		package: 'PgMetadata-SQL-Model-Objects' with: [ spec requires: #('PgMetadata-Core') ];
		package: 'PgMetadata-tests' with: [ spec requires: #('PgMetadata-Core' 'PgMetadata-SQL-Model-Objects' 'PgMetadata-SQL-Extractors') ];
		yourself