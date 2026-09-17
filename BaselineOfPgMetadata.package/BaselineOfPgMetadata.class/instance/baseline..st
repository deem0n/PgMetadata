baselines
baseline: spec
	<baseline>
	spec for: #common do: [
		self definePackages: spec; defineDependencies: spec.
		spec
			group: 'default' with: #('Core');
			group: 'Core' with: #('PgMetadata-Core' 'PgMetadata-SQL-Model-Objects' 'PgMetadata-SQL-Extractors');
			group: 'Tests' with: #('Core' 'PgMetadata-tests') ]
