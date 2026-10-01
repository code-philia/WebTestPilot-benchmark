# DB baselines

Each app under `<app>/environment/` can have a `baseline.sql` - a `mysqldump`/
`pg_dump` of that app's own database taken immediately after a completely
fresh install/migration, before any task-specific `seed.sql` is loaded.

The benchmark runner copies `baseline.sql` into every generated task (same as
`seed.sql`), and each app's `docker-compose.yaml` mounts it into the DB
service's `/docker-entrypoint-initdb.d/` directory as `00-baseline.sql`. The
official `mysql`/`postgres` images only run files from that directory when
the data directory is still empty, and run them in filename order - so
`00-baseline.sql` (the schema) loads before `seed.sql` (the task's rows), and
a fresh task's DB starts already-migrated instead of the app running its own
slow first-boot migration/install from scratch.

`baseline.sql` is optional: an app with no baseline file just gets the
original from-scratch install behavior.

## What's in a baseline, and what isn't

`baseline.sql` only ever holds generic, app-level install scaffolding -
the admin account, roles/permissions, static lookup tables (currencies,
countries, timezones, ...), migration tracking. Verified for every app that
has one: it contains zero rows in any task-content table (books, pages,
invoices, quotes, clients, activities, events, ...). All task-specific,
test-relevant content still comes from `seed.sql`, loaded fresh at task-run
time exactly as before this mechanism existed - this file does not change
what data a test sees or when its timestamps get computed.

One caveat: rows a baseline *does* include (e.g. the admin user/account row)
carry `created_at`/`updated_at` timestamps frozen at whatever moment the
baseline was baked, not at each task's actual run time. No current
benchmark task checks an account's own age/join-date - they all check
task content from `seed.sql` (bookstack/prestashop's seed-loader.sh already
rewrites a `YYYY-MM-DD` placeholder in `seed.sql` to "yesterday" at load
time, independent of baseline.sql). If a future task type ever does check
account-level metadata like this, that's the thing to watch for.

## Regenerating

Re-run the bake whenever an app's base image version, environment config, or
`app.Dockerfile` changes in a way that could change its migrated schema - a
stale baseline that no longer matches what the app expects will surface as
migration or seed errors, not silently wrong data (the app's own migration
runner still runs on top of a mismatched baseline; it just doesn't start
from empty).

Launch the app against an empty database without loading a previous baseline
or task seed. Wait for installation and migrations to finish, then dump the
database to `<app>/environment/baseline.sql`. Validate the new baseline with
the app's seed loader before using it for benchmark tasks.

PrestaShop has no baseline here: its installer also needs a local filesystem
marker in the webapp volume, so a database dump alone would not skip setup.
