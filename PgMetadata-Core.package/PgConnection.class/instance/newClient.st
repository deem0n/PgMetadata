connection
newClient
	^ P3Client new
		host: self hostname;
		port: self port;
		database: self database;
		user: self user;
		password: self password;
		yourself
