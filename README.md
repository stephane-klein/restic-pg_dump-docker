# Docker Image to backup PostgreSQL database with Restic

You can use this Docker image `stephaneklein/restic-pg_dump:latest` sidecar to backup your PostgreSQL database.

This Docker image is powered by:

- [`pg_back`](https://github.com/orgrim/pg_back/) - Simple backup tool for PostgreSQL.
- [`restic`](https://github.com/restic/restic/) - Fast, secure, efficient backup program.
- [`Rclone`](https://rclone.org/) - Rclone is a command-line program to manage files on cloud storage.
- [`supercronic`](https://github.com/aptible/supercronic) - Cron for containers.

If you are looking for a Restic based Docker image to backup your files, you can check out the following project: https://github.com/Its-Alex/restic-docker


## Getting started

To use this container you can launch it from docker cli:

```sh
$ docker run \
    -e AWS_ACCESS_KEY_ID="admin" \
    -e AWS_SECRET_ACCESS_KEY="password" \
    -e RESTIC_REPOSITORY="s3:http://minio:9000/bucket1" \
    -e RESTIC_PASSWORD="secret" \
    -e POSTGRES_USER="postgres" \
    -e POSTGRES_PASSWORD="password" \
    -e POSTGRES_HOST="postgres" \
    -e POSTGRES_DB="postgres" \
    stephaneklein/restic-pg_dump:latest
```

Or add it to a `docker-compose.yml`:

```yaml
restic-pg-dump:
  image: stephaneklein/restic-pg_dump:latest
  environment:
    AWS_ACCESS_KEY_ID: "admin"
    AWS_SECRET_ACCESS_KEY: "password"
    RESTIC_REPOSITORY: "s3:http://minio:9000/bucket1"
    RESTIC_PASSWORD: secret
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: password
    POSTGRES_HOST: postgres
    POSTGRES_DB: postgres
```

## Configuration

- Configure the PostgreSQL server to backup with this variable environments:
  - `POSTGRES_USER`;
  - `POSTGRES_PASSWORD`;
  - `POSTGRES_HOST`;
  - `POSTGRES_DB`;
  - `POSTGRES_PORT` (default: `5432`).
- `RESTIC_PASSWORD` to [encrypte your backup](https://restic.readthedocs.io/en/latest/faq.html#how-can-i-specify-encryption-passwords-automatically) (empty by default, i.e. no encrypted).
- `BACKUP_CRON` (default `0 3 * * *` daily).
- Configure [`restic forget`](https://restic.readthedocs.io/en/latest/060_forget.html#) (which allows removing old snapshots) with this variable environments:
  - `RESTIC_KEEP_HOURLY` (default: `24`);
  - `RESTIC_KEEP_DAILY` (default: `7`);
  - `RESTIC_KEEP_WEEKLY`  (default: `4`);
  - `RESTIC_KEEP_MONTHLY` (default: `12`).
  - Set `RESTIC_DOCKER_IS_FORGET_DISABLED=1` to disable [`restic forget`](https://restic.readthedocs.io/en/latest/060_forget.html).

You can configure many target storage. For instance:

- Store your backup to S3 like Object Storage:
  - `AWS_ACCESS_KEY_ID`;
  - `AWS_SECRET_ACCESS_KEY`;
  - `RESTIC_REPOSITORY` : `s3:http://minio:9000/bucket1`.
- Store your backup to ftp:
  - `RESTIC_REPOSITORY`: `rclone:ftpd_server:backup`.

More options, see [Restic environment variables documentation](https://restic.readthedocs.io/en/stable/040_backup.html#environment-variables).

## Demo

Go to [`demo/`](demo/) to see how to use `stephaneklein/restic-pg_dump` Docker Image.

## Why use pg_back?

Why this project use [`pg_back`](https://github.com/orgrim/pg_back/) instead `pg_dumpall`?

> The goal of `pg_back` is to dump all or some databases with globals at once in the format you want, because a simple call to pg_dumpall only dumps databases in the plain SQL format.


## How do I publish a version?

When a project iteration is deemed stable, it is possible to tag this version by following these instructions:

```sh
$ git tag $(date +'%Y%m%d_%H%M')
$ git push --tags
```

## License

Restic sftp docker is licensed under [BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause). You can find the
complete text in [`LICENSE`](LICENSE).
