connection
connect
	connection := parameters newClient.
	connection connect.
	connection execute: 'BEGIN ISOLATION LEVEL REPEATABLE READ READ ONLY'.
	[
		self postgresql: (PgPostgresql about: self).
		self extractObjects
	] ensure: [ connection execute: 'ROLLBACK' ]
