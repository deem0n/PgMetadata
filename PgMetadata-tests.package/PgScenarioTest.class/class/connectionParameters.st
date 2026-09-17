accessing
connectionParameters
	^ ConnectionParameters ifNil: [
		PgConnection hostname: 'localhost' port: 5432 database: 'postgres'
			user: 'postgres' password: 'postgres' ]
