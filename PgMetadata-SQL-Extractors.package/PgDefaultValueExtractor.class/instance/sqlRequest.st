parameters
sqlRequest
	^'
	SELECT
	adrelid as table_oid,
	adnum as num_column,
	pg_get_expr(adbin, adrelid) as content,
	adbin::text as nodes
FROM pg_attrdef
WHERE adrelid = {1}
'
