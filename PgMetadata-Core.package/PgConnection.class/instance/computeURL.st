action
computeURL
	^ (ZnUrl new
		scheme: 'psql';
		host: self hostname;
		port: self port;
		username: self user;
		password: self password;
		addPathSegment: self database;
		yourself) asString
