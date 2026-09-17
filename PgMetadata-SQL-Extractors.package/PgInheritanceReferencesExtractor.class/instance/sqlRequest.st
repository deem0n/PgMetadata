parameters
sqlRequest
	"pg_inherits also contains partitioned indexes; import table relations only."
	^ 'SELECT i.inhrelid, i.inhparent
FROM pg_inherits i
JOIN pg_class child ON child.oid = i.inhrelid
JOIN pg_class parent ON parent.oid = i.inhparent
JOIN pg_namespace n ON n.oid = child.relnamespace
WHERE child.relkind IN (''r'', ''p'')
AND parent.relkind IN (''r'', ''p'')
AND n.nspname !~ ''^pg_'' AND n.nspname <> ''information_schema'''
