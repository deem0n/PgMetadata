sql
sqlRequest
	^'SELECT oid,relname,relnamespace
FROM pg_class
WHERE
	relkind = ''{1}''
AND relnamespace IN (
	SELECT oid
	FROM pg_namespace
	WHERE nspname !~ ''^pg_'' AND nspname <> ''information_schema''
)' format: { self relkind }
