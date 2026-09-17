# PgMetadata

PgMetadata reads PostgreSQL catalogs and builds a Smalltalk object model of a
database. Its entry point, `PgMetadata>>extractMetadata`, returns a `PgDatabase`
containing schemas, tables, views, routines, triggers and their catalog
relationships. PostgreSQL connections use [P3](https://github.com/svenvc/P3).

PgMetadata preserves routine and view source. Parsing SQL/PL/pgSQL and building
FAMIX dependencies is the job of the optional
[FAMIXNGSQL importer](https://github.com/deem0n/FAMIXNGSQL), described below.

## Compatibility

Validation recorded on **2026-09-17**:

| Component | Version/status |
| --- | --- |
| Pharo | **13.1.0SNAPSHOT**, tested in the running image |
| Moose | **13.0.0**, tested with the FAMIXNGSQL integration |
| PostgreSQL | **15.14**, metadata extraction and 24 PgMetadata tests passed |
| P3 | `d45f0d358f41ff809fd85f26046a63630a3a7bef`, upstream code synchronized into `deem0n/P3:master` |
| Older Pharo, including 7 and 10 | Not validated with this version of PgMetadata |
| Other Moose versions | Not validated with the current FAMIXNGSQL integration |
| Other PostgreSQL versions | Not validated by this test run |

**PgMetadata Core has no Moose/Famix dependency.** Moose 13 is the tested
environment for the optional FAMIX integration, not a requirement imposed by
PgMetadata's baseline. Standalone loading in a fresh plain Pharo image has not
yet been validated; the tests above ran in an existing Pharo 13/Moose 13 image.
The catalog queries contain version-dependent handling for PostgreSQL before
11 (`prokind`) and before 14 (SQL-standard routine bodies), but that is not a
claim that those server versions have passed the current suite.

The P3 baseline currently tracks `github://deem0n/P3:master`. At validation time,
the fork and upstream `svenvc/P3:master` both pointed to the revision above.
Since this dependency is a moving branch, pinning PgMetadata alone does not pin
the complete dependency stack.

## Installation

Evaluate in a Pharo Playground:

```smalltalk
Metacello new
    baseline: 'PgMetadata';
    repository: 'github://deem0n/PgMetadata:master';
    load: 'Core'.
```

The repository uses FileTree packages at its root: do not append `/src` to the
PgMetadata repository URL. The default group is also `Core`.

| Group | Contents |
| --- | --- |
| `Core` | Connection/metadata API, SQL model objects and catalog extractors |
| `Tests` | Core plus unit tests and scenarios requiring a PostgreSQL database |

The historical `PgMetadata-Node-Tree-Parser` package is not loaded by these
groups. It is not the SQL/PL/pgSQL parser used by FAMIXNGSQL.

## Extract a database

This example uses the local `mi` database at port `5435`, role `bi`, and the
existing local authentication configuration:

```smalltalk
| connection pgDB |
connection := PgConnection
    hostname: 'localhost'
    port: 5435
    database: 'mi'
    user: 'bi'
    password: nil.

pgDB := (PgMetadata
    database: 'mi'
    connection: connection) extractMetadata.

pgDB inspect.
```

Use the same database name in both places. Replace the connection values for
your server; supply a password if its authentication method requires one.
`password: nil` does not obtain a password automatically from `psql` or `.pgpass`.
Use a role allowed to connect and read the relevant catalog metadata; superuser
access is not required for ordinary extraction.

Extraction runs in one **read-only, repeatable-read transaction**, ends the
transaction with `ROLLBACK`, and closes the connection before returning the
object model. The returned objects can be inspected without an open connection.
The higher-level `extractMetadata` entry point also closes on extraction errors.

All non-system schemas are included: schema names starting with `pg_` and
`information_schema` are excluded from application schema extraction. There is
currently no schema allowlist argument. A non-system schema belonging to an
extension or test suite (for example `pgtap`) is therefore included too.
System routine/type stubs needed by references can still appear in the model;
not every object in `pgDB objects` is an application-owned object.

## Inspect the model

In the Inspector opened on the `PgDatabase`, evaluate these expressions with
`self` bound to that database:

```smalltalk
Dictionary new
    at: #schemas put: self getNamespaces size;
    at: #tables put: self getTables size;
    at: #foreignTables put: self getForeignTables size;
    at: #views put: self getViews size;
    at: #materializedViews put: self getMaterializedViews size;
    at: #routines put: (self getFunctions reject: #isStub) size;
    at: #triggerFunctions put: (self getTriggerFunctions reject: #isStub) size;
    at: #triggers put: self getTriggers size;
    yourself.
```

Tables include partitioned tables. Ordinary views, materialized views and
foreign tables have separate accessors. `getFunctions` includes trigger
functions; `getTriggerFunctions` returns that subset, so those counts overlap.
System stubs are excluded explicitly above.

Inspect routine source, language and ordered arguments:

```smalltalk
self getFunctions
    reject: [ :routine | routine isStub or: [ routine isSqlTriggerFunction ] ]
    thenCollect: [ :routine |
        { routine namespace name.
          routine name.
          routine oid.
          routine language name.
          routine code.
          (routine arguments collect: [ :argument |
              { argument position. argument name. argument mode.
                argument datatype } ]) } ].
```

The argument example excludes trigger functions, whose model class does not
have the `arguments` accessor. Argument modes use PostgreSQL's catalog codes
(`i`, `o`, `b`, `v`, `t`). Unnamed
arguments receive positional names such as `$1`. Routine names are not unique:
retain the OID and argument types when distinguishing overloads. Functions and
procedures are represented by the current routine model; it does not expose a
separate procedure entity class.

Inspect trigger ownership and the invoked trigger function:

```smalltalk
self getTriggers collect: [ :trigger |
    { trigger name.
      trigger table namespace name.
      trigger table name.
      trigger function name.
      trigger function code.
      trigger isBefore.
      trigger isInstead.
      trigger isRow } ].
```

`trigger table` is the owning relation; it can also be a view (for example an
`INSTEAD OF` trigger). The trigger function's code is retained independently of
the trigger's event/timing metadata.

Inspect routines referenced by CHECK and exclusion constraints:

```smalltalk
self getConstraints
    select: [ :constraint |
        constraint isSqlCheckConstraint
            or: [ constraint isKindOf: SqlExclusionConstraint ] ]
    thenCollect: [ :constraint |
        { constraint oid. constraint name. constraint code.
          (constraint calledFunctions collect: [ :routine |
              { routine oid. routine name } ]) } ].
```

These links come from PostgreSQL catalog dependencies, including exclusion
index expressions. They do not imply that all calls inside routine bodies have
been resolved. Constraint identity uses OIDs because names can repeat in
different tables or schemas.

## Optional: build a FAMIX model

Use the tested **Pharo 13/Moose 13** environment. The FAMIXNGSQL migration is
published on `pharo13-pgmetadata-integration`; its default `master` is older.

```smalltalk
Metacello new
    baseline: 'FAMIXNGSQL';
    repository: 'github://deem0n/FAMIXNGSQL:pharo13-pgmetadata-integration/src';
    load: 'Core'.
```

That baseline pins PgMetadata to `5abe3134238b4f84f7d1e02e28d9aee45aee5c61`, the
integration code included in this repository's `master`, and pins its parser to
`deem0n/PostgreSQLParser` revision
`f9d1b0850cb7cde2839760d87f54f04ba9de315e`. The tested FAMIXNGSQL revision is
`9dedd5edfca93725423b6c3ab4a11b739fa99f0d`. Full fresh-image installation and the
legacy UI remain unverified.

Build all application schemas from `mi`:

```smalltalk
| connection builder model |
connection := PgConnection
    hostname: 'localhost'
    port: 5435
    database: 'mi'
    user: 'bi'
    password: nil.

builder := FmxSQLModelBuilder new
    databaseName: 'mi';
    connection: connection;
    yourself.
model := builder buildModel.
model inspect.
```

In the resulting model's Inspector, inspect source-analysis coverage:

```smalltalk
self analysisReport.
```

Or export an MSE file to the image's working directory:

```smalltalk
'mi.mse' asFileReference writeStreamDo: [ :stream |
    self exportToMSEStream: stream ].
```

Choose a new filename when retaining previous exports. The separate
`analysisReport` contains per-object statuses and diagnostics and is not stored
in MSE. Retain it alongside exports when assessing analysis completeness.

The importer builds `FmxSQL*` entities and preserves source, triggers,
constraints and references. Catalog extraction succeeding does **not** mean
every SQL/PL/pgSQL body was successfully parsed: unsupported syntax, unresolved
names, dynamic SQL and timeouts are reported. The September 2026 `mi` run still
had 520 parser syntax failures; those are parser limitations, not PostgreSQL
reporting invalid stored code. See the
[migration audit](https://github.com/deem0n/FAMIXNGSQL/blob/pharo13-pgmetadata-integration/docs/pharo13-migration-audit.md)
for measured coverage and remaining work.

## Run the tests

Load the test group:

```smalltalk
Metacello new
    baseline: 'PgMetadata';
    repository: 'github://deem0n/PgMetadata:master';
    load: 'Tests'.
```

Create a **disposable database** outside this library, owned by the test role.
Configure the scenario tests before running the package. For example:

```smalltalk
PgScenarioTest connectionParameters:
    (PgConnection
        hostname: 'localhost'
        port: 5435
        database: 'pgmetadata_validation_20260917'
        user: 'bi'
        password: nil).
```

The database must already exist, and the role must be allowed to create schemas,
tables, routines and triggers. Each scenario creates a unique
`pgmetadata_test_<uuid>` schema and drops it with `CASCADE` during teardown.
These tests perform DDL; do not point them at the application database.

Run the unit and scenario classes together:

```smalltalk
| suite result |
suite := TestSuite named: 'PgMetadata'.
{ PgConnectionTest. PgDatabaseTest. PgTriggerTest. PgScenarioTest }
    do: [ :testClass | suite addTest: testClass suite ].
result := suite run.
result inspect.
```

The latest validation passed **24 tests, zero failures, zero errors** against
PostgreSQL 15.14. Scenarios cover tables, columns, routines, argument modes and
positions, ordinary/materialized views, partitions, triggers, SQL-standard
routine bodies, and CHECK/exclusion constraint routine dependencies. No CI
matrix currently establishes support for other Pharo/Moose/PostgreSQL versions.

## History and license

This fork builds on [Olivier Auverlot's PgMetadata](https://github.com/olivierauverlot/PgMetadata)
and incorporates [Aless Hosry's scenario-test work](https://github.com/alesshosry/PgMetadata/tree/feature-scenario-tests).
The integrated downstream development revision is
`117c49af2ba159c99ba7ae1193bf8dd9b556e0d8`, whose tree matches that scenario-test
branch. The integration adds current P3 support, catalog type conversions,
connection cleanup, richer metadata relationships and additional scenarios.

PgMetadata is distributed under the [MIT license](LICENSE).
