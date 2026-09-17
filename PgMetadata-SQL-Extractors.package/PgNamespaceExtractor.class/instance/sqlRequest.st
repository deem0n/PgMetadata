parameters
sqlRequest
	^'SELECT oid,nspname
	FROM pg_namespace
	WHERE nspname !~ ''^pg_'' AND nspname <> ''information_schema'''
