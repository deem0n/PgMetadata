sql
sqlRequest
	"Partitioned tables own columns and constraints just like ordinary tables."
	^ super sqlRequest copyReplaceAll: 'relkind = ''r''' with: 'relkind IN (''r'', ''p'')'
