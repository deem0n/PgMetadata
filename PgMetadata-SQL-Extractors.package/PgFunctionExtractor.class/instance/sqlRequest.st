parameters
sqlRequest
	^ 'SELECT
	pg_proc.oid,
	proname,
	pronamespace,
	pg_namespace.nspname as pronamespacename,
	proargnames,
	proargmodes::text[] AS proargmodes,
	proargtypes,
	proallargtypes,
	prolang,
	pg_language.lanname as prolangname,
	prorettype,
	proretset,
	pg_type.typname as prorettypename,
	{2} AS prosrc,
	{1}
FROM 	pg_proc,pg_type,pg_language,pg_namespace
WHERE
	prorettype = pg_type.oid
AND	 prolang = pg_language.oid
AND	 pronamespace = pg_namespace.oid
AND 	pronamespace IN (
	SELECT oid
	FROM pg_namespace
	WHERE nspname !~ ''^pg_'' AND nspname <> ''information_schema'')'
		format:
			{(self database postgresql databaseMajorVersion >= 11
				ifTrue: [ 'prokind::text AS prokind' ]
				ifFalse: [ 'case when proisagg then $$a$$ when proiswindow then $$w$$ else $$f$$ end as prokind' ]).
			(self database postgresql databaseMajorVersion >= 14
				ifTrue: [ 'CASE WHEN prosqlbody IS NOT NULL THEN pg_get_function_sqlbody(pg_proc.oid) ELSE prosrc END' ]
				ifFalse: [ 'prosrc' ])}
