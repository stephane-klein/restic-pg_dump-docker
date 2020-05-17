# How to use stephaneklein/restic-pg_dump Docker Image

```
$ ./scripts/up.sh
```

Default backup cron configuration: `BACKUP_CRON="0 */6 * * *"`

This is how to execute backup now:

```
$ docker-compose exec restic-pg-dump /bin/backup
```

## Restoration scenario

Now I would like restore file outside Docker.

```
$ brew install restic
```

```
$ source source.env
```

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

Restore data to `data2/`:

```
$ restic -r s3:http://127.0.0.1:9000/bucket1 restore e0b88d91 --target ./backup/
```

Check PostgreSQL custom file content:

```
$ pg_restore -l backup/data/database.Fc.dump
;
; Archive created at 2020-05-17 20:49:06 CEST
;     dbname: postgres
;     TOC Entries: 11
;     Compression: -1
;     Dump Version: 1.14-0
;     Format: CUSTOM
;     Integer: 4 bytes
;     Offset: 8 bytes
;     Dumped from database version: 11.2
;     Dumped by pg_dump version: 12.2
;
;
; Selected TOC Entries:
;
2; 3079 16384 EXTENSION - uuid-ossp
2906; 0 0 COMMENT - EXTENSION "uuid-ossp"
197; 1259 16411 TABLE public contacts postgres
2898; 0 16411 TABLE DATA public contacts postgres
2776; 2606 16420 CONSTRAINT public contacts contacts_pkey postgres
2774; 1259 16421 INDEX public contacts_email_index postgres
```