parameters
sqlRequest

	^'SELECT
	c.oid,
	connamespace as namespace_oid,
	contype::text as contype,
	conname as constraint_name,
	t.oid as constrained_table,
	conkey::integer[] as num_constrained_columns,
	t2.oid as referenced_table,
	c.confkey::integer[] as num_referenced_columns,
   pg_get_constraintdef(c.oid) as consrc
FROM pg_constraint c
	LEFT JOIN pg_class t  ON c.conrelid  = t.oid
	LEFT JOIN pg_class t2 ON c.confrelid = t2.oid
WHERE	t.oid = {1}
'
