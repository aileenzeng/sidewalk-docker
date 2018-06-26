# sidewalk-docker
Aileen's attempt at configuring Project Sidewalk with Docker

# Documentation:
1. Clone the Project Sidewalk repository into this project's root directory
2. Obtain a database dump. Name it `sidewalk.sql` and place it into the `resources` folder.
3. Run `docker-compose build`
4. Run `docker-compose up -d db`. You may need to run this twice (?) until the message says '`Starting sidewalk-docker_db_1 ... done`'.
5. Run `docker exec -it sidewalk-docker_db_1 su - postgres`. Then, type in `createdb -T template0 sidewalk` and `pg_restore -d sidewalk docker-entrypoint-initdb.d/sidewalk.sql`. 

# Helpful commands:
To check what the state of the database is, run `docker exec -it sidewalk-docker_db_1 psql -U sidewalk` to enter the interactive postgres container.
- `\du` to show all users.
- `\dt` to show all relations.
- `\q` to exit. 

`docker-compose run db bash` lets you run an interactive terminal to see what is happening in the `db` service. 

`docker-compose stop; sudo rm -rf ./data/postgres/` ??  `¯\_(ツ)_/¯`

# Useful resources (maybe):
Docker compose commands:
https://docs.docker.com/compose/reference/run/ -- inspect services from docker-compose up file

Postgres commands: 
https://stackoverflow.com/questions/769683/show-tables-in-postgresql

Docker + postgres initialization
https://github.com/docker-library/postgres/issues/203#issuecomment-255200501

# Things to investigate

1. Upon running `docker-compose up`, we get this message. It'd be ideal to initialize the database from docker-compose up directly.

```
db_1  | /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/sidewalk.sql
db_1  | The input is a PostgreSQL custom-format dump.
db_1  | Use the pg_restore command-line client to restore this dump to a database.
```

2. Find a way to check if the database is persisting. (I'm not convinced it is)
3. 

# Notes
The build command in `docker-compose` file lets you run the service from the dockerfile. You need to explicitly rebuild the container with `docker-compose build` when you have services that are using the build command in order to ensure that you are running the most recent version of each Dockerfile.




