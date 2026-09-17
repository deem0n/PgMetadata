# PgMetadata
Extracts the PostgreSQL metadata and build an SQL Model (In progress).

## Current integration

The `integrate-scenario-tests` branch incorporates Aless Hosry's downstream
scenario tests and PostgreSQL catalog updates (development revision
`117c49af2ba159c99ba7ae1193bf8dd9b556e0d8`, the same tree as
`feature-scenario-tests`). It uses the current upstream P3 merged into deem0n/P3.

Validated with Pharo 13 / Moose 13 and PostgreSQL 15.14. Metadata extraction uses
one read-only, repeatable-read transaction and closes the connection afterwards.
It includes application schemas, partitioned and foreign tables, ordinary and
materialized views, functions/procedures, ordered unnamed arguments, triggers,
and CHECK/exclusion constraint routine dependencies. System schemas are excluded
from application objects; system routine stubs remain available for resolution.

```smalltalk
Metacello new
    baseline: 'PgMetadata';
    repository: 'github://deem0n/PgMetadata:integrate-scenario-tests';
    load: 'Core'.
```

Load the `Tests` group to run tests. Configure a disposable database before
running `PgScenarioTest`; each scenario creates and removes its own UUID schema:

```smalltalk
PgScenarioTest connectionParameters:
    (PgConnection hostname: 'localhost' port: 5435
        database: 'pgmetadata_validation_20260917' user: 'bi' password: nil).
```

Older Pharo compatibility is not validated by this integration. The original
upstream remains at `github://olivierauverlot/PgMetadata`.

## How to use PgMetadata

The class PgMetadata returns an instance of PgDatabase that describes the SQL schema. 

    | metadata sqlObjects |
    metadata := PgMetadata database: 'mydb' connection: (
	PgConnection
		hostname: 'localhost'
		port: 5432
		database: 'dbname'
		user: 'username'
		password: 'password'
    ).
    pgDB := metadata extractMetadata.
    sqlObjects := pgDB objects
