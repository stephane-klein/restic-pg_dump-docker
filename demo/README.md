# How to use stephaneklein/restic-pg_dump Docker Image

```
$ source .envrc
$ docker compose build # optional, only used for development activities
$ ./scripts/up.sh
```

Default backup cron configuration: `BACKUP_CRON="0 3 * * *"`

This is how to execute backup now:

```
$ docker compose exec restic-pg-dump start-backup-now
```

## Restoration scenario

Now I would like to restore file outside Docker.

Read the ["Installation" section](https://restic.readthedocs.io/en/stable/020_installation.html) of the Restic documentation to install the restic command on your workstation


Load secret environment variables:

```
$ source .envrc
```

Here's how to display the snapshot list:

```
$ restic -r s3:http://127.0.0.1:9000/bucket1 snapshots
enter password for repository: secret
repository a29e6bd8 opened successfully, password is correct
created new cache in /Users/stephane/Library/Caches/restic
found 2 old cache directories in /Users/stephane/Library/Caches/restic, run `restic cache --cleanup` to remove them
ID        Time                 Host          Tags        Paths
--------------------------------------------------------------
c5e34bfe  2020-05-17 21:40:15  4671f34479e7              /data
7faaaa94  2020-05-17 21:45:30  8981c517e95a              /data
e0b88d91  2020-05-17 21:49:08  f95050207680              /data
--------------------------------------------------------------
3 snapshots
```

```
$ restic -r s3:http://127.0.0.1:9000/bucket1 check
```

Restore `e0b88d91` snapshot to `backup/`:

```
$ restic -r s3:http://127.0.0.1:9000/bucket1 restore e0b88d91 --target ./backup/
```

```
$ ls -1 backup/var/backups/postgresql
hba_file_2024-06-08T16:07:39Z.out
ident_file_2024-06-08T16:07:39Z.out
pg_globals_2024-06-08T16:07:39Z.sql
pg_settings_2024-06-08T16:07:39Z.out
postgres_2024-06-08T16:07:39Z.dump
```

At this point, you need to have `pg_restore` installed on your workstation.

Check PostgreSQL custom file content:

```
$ pg_restore -l backup/var/backups/postgresql/postgres_2024-06-08T16:07:39Z.dump
;
; Archive created at 2024-06-08 17:07:39 CEST
;     dbname: postgres
;     TOC Entries: 11
;     Compression: gzip
;     Dump Version: 1.15-0
;     Format: CUSTOM
;     Integer: 4 bytes
;     Offset: 8 bytes
;     Dumped from database version: 16.1 (Debian 16.1-1.pgdg120+1)
;     Dumped by pg_dump version: 16.3
;
;
; Selected TOC Entries:
;
2; 3079 16384 EXTENSION - uuid-ossp
3369; 0 0 COMMENT - EXTENSION "uuid-ossp"
216; 1259 16395 TABLE public contacts postgres
3361; 0 16395 TABLE DATA public contacts postgres
3217; 2606 16403 CONSTRAINT public contacts contacts_pkey postgres
3215; 1259 16404 INDEX public contacts_email_index postgres
```

Restore the `postgres_2024-06-08T16:07:39Z.dump` file to the `postgres-restore-test` instance:

```
$ PGPASSWORD=password pg_restore -v -c --if-exists -d postgres -U postgres -h 127.0.0.1 -p 5433 backup/var/backups/postgresql/postgres_2024-06-08T16:07:39Z.dump
$ PGPASSWORD=password psql -U postgres -h 127.0.0.1 -p 5433
psql (16.1)
Saisissez « help » pour l'aide.

postgres=# \dt
           Liste des relations
 Schéma |   Nom    | Type  | Propriétaire
--------+----------+-------+--------------
 public | contacts | table | postgres
(1 ligne)

postgres=# select * from contacts limit 2;
                  id                  |           email           |   firstname   |   lastname   |          created_at
--------------------------------------+---------------------------+---------------+--------------+-------------------------------
 1de9c987-08ab-32fe-e218-89c124cd0001 | firstname0001@example.com | firstname0001 | lastname0001 | 2024-06-08 14:03:29.992154+00
 1de9c987-08ab-32fe-e218-89c124cd0002 | firstname0002@example.com | firstname0002 | lastname0002 | 2024-06-08 14:03:29.992154+00
(2 lignes)

```


## Teardown

```sh
$ docker compose down -v
```
