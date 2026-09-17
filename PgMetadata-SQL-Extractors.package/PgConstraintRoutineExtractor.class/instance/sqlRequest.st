parameters
sqlRequest
	^ 'SELECT DISTINCT c.oid AS constraint_oid, d.refobjid AS function_oid
FROM pg_constraint c
JOIN pg_depend d ON
 (d.classid = ''pg_constraint''::regclass AND d.objid = c.oid)
 OR (d.classid = ''pg_class''::regclass AND d.objid = c.conindid)
WHERE c.contype IN (''c'', ''x'')
AND d.refclassid = ''pg_proc''::regclass'
