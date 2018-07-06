NOTE: this `README` is mostly a brain dump of information to help me keep track of different thoughts I've had since starting to work with docker.

# Documentation:
## Prequisites
1. Docker (18.03.1). I am using the Community Edition, version 18.03.1, which can be downloaded [here](https://store.docker.com/search?type=edition&offering=community).
2. Docker Compose (1.21.1). NOTE: Docker for Windows/Mac already come with Docker Compose. Linux users will need to download compose separately from [here]( https://docs.docker.com/compose/install/).

You to see which Docker version you have installed by running the following commands:
```
docker --version
docker-compose --version
```

## Setup
## Additional Steps for Windows Users
Windows users *must* do the following before cloning 
* Give Docker access to drives. Go to Docker > Settings > Shared Drives, and select the drive that you are going to use.
* Change git's autocrlf setting. (This must happen before you clone the repository!) Type: `git config --global core.autocrlf false`

## General Steps
1. Clone this repository (sidewalk-docker). Run `git clone https://github.com/aileenzeng/sidewalk-docker`.
2. Clone the Project Sidewalk repository into the `website` folder of this directory. Check out the `593-sidewalk-docker` branch for now - this branch contains a few updates to the config files that are needed to make this project work properly with Docker. Run `git checkout 593-sidewalk-docker`.
3. Obtain a database dump. Name it `sidewalk.sql` and place it into the `resources` folder.
4. Run `docker-compose build` in the project's root directory - this is the directory with the `docker-compose.yml` file. This command builds the `Dockerfile`s for the `website` and `db` services. This step can take ~3-4 minutes the first time. 
5. Run `docker-compose up -d db`. You will need to run this twice until the message says '`Starting sidewalk-docker_db_1 ... done`'.
6. Run `docker exec -it sidewalk-docker_db_1 su - postgres -c "createdb -T template0 sidewalk"` then `docker exec -it sidewalk-docker_db_1 su - postgres -c "pg_restore -d sidewalk docker-entrypoint-initdb.d/sidewalk.sql"`. This step may take a while. Once this step is complete, there will be a message that says "Warning: 2 errors after pg_restore" - this is normal!
7. After the database is created, run `docker-compose up`. (If this doesn't work, try `docker-compose up --force-recreate`. This takes care of problems related to environment variables) This step can take ~5-10 minutes the first time.

## Running (general purpose)
1. (Optional: if no changes to ProjectSidewalk) Run `docker-compose build`.
2. Run `docker-compose up`

Assuming all is running smoothly, you expect to see see the following line: 
```
website_1  | (Server started, use Ctrl+D to stop and go back to the console...)
```

3. Use Ctrl+C to exit. (NOTE: Do not use `docker-compose down`)

## Importing data
1. Obtain a database dump. Name it `sidewalk.sql` and place it into the `resources` folder.
2. Run the following commands:

```
docker-compose build db
docker start sidewalk-docker_db_1
```

Todo: fix these commands
```
docker exec -it sidewalk-docker_db_1 su - postgres -c  "dropdb sidewalk"
docker exec -it sidewalk-docker_db_1 su - postgres -c "createdb -T template0 sidewalk"
docker exec -it sidewalk-docker_db_1 su - postgres -c "pg_restore -d sidewalk 
docker-entrypoint-initdb.d/sidewalk.sql"
```

## Exporting data
Run the following commands:
```
docker start sidewalk-docker_db_1
docker exec -it sidewalk-docker_db_1 bash
root@cc4c527d7e19:/# psql -U sidewalk
sidewalk=# \! pg_dump -U sidewalk sidewalk -Fc -f dump.sql
sidewalk=# \q
exit
docker cp sidewalk-docker_db_1:/dump.sql /host/path/target/sidewalk.sql
```

Explanation of commands:
1. Starts the docker containers. (`docker-compose up db` is probably sufficient).
2. Enters the bash interactive terminal in the Sidewalk database container. 
3. Enters the postgres terminal (inside the bash terminal) as the Sidewalk user. 
4. Dumps the sidewalk database into a file called `dump.sql` in the root directory of the database container.  
5. Exits the postgres terminal
6. Exits the interactive bash terminal.
7. Copies `dump.sql` from the Docker container to `sidewalk.sql` on a path on the host machine. EX: `docker cp sidewalk-docker_db_1:/dump.sql ~/Documents/sidewalk.sql` would copy the `dump.sql` to a file called `sidewalk.sql` in the Documents folder.

## Current tasks
1. Streamline the database setup process
2. Create volumes for the database and website.
3. Deploy onto test site?

# Helpful commands:
`docker rm $(docker ps -a -q)` deletes all containers (note: if the database container is deleted, then any changes since the dump will not be saved)

`docker rmi $(docker images -q)` deletes all images

`docker kill <container id>` kills an active container


To check what the state of the database is, run `docker exec -it sidewalk-docker_db_1 psql -U sidewalk` to enter the interactive postgres container.
- `\du` to show all users.
- `\dt` to show all relations.
- `\q` to exit. 

`docker inspect <container>` returns a list of low-level information about the container.
`docker-compose run <service> bash` lets you run an interactive terminal to see what is happening inside a service. 
- It's helpful to ping `sidewalk` (or `db`, same thing) from the website container to make sure that they are connected.
```
docker exec -it sidewalk-docker_website_1 bash
~/app # ping sidewalk
```
- This also allows us to see config files that aren't necessarily visible from outside the docker container. (although these would be tricky to modify)

`docker-compose stop; sudo rm -rf ./data/postgres/` ????  `¯\_(ツ)_/¯`


# Useful resources (maybe):
Docker compose commands:
https://docs.docker.com/compose/reference/run/ -- inspect services from docker-compose up file

Postgres commands: 
https://stackoverflow.com/questions/769683/show-tables-in-postgresql

Docker + postgres initialization
https://github.com/docker-library/postgres/issues/203#issuecomment-255200501

# Notes
The build command in `docker-compose` file lets you run the service from the dockerfile. You need to explicitly rebuild the container with `docker-compose build` when you have services that are using the build command in order to ensure that you are running the most recent version of each Dockerfile.

## Changes made to SidewalkWebpage
These changes are on the `593-move-to-docker` branch.

### Fix dependencies in `/build.sbt`
Many `javax.media` files are missing. For example, `javax.media#jai_core;1.1.3!jai_core.jar` is missing from the [Maven repository](http://repo1.maven.org/maven2/javax/media/jai_core/1.1.3/). It is also missing from [osgeo](http://download.osgeo.org/webdav/geotools/javax/media/jai_core/1.1.3/jai_core-1.1.3.jar). Additionally, `downloads.osgeo` no longer seems to be supported. This prevents `geotools` dependencies from being downloaded. 

These cause problems during `sbt compile` and `sbt run`. More detailed writeups of these issues are [here](https://github.com/aileenzeng/sidewalk-docker/issues/5) and [here](https://github.com/aileenzeng/sidewalk-docker/issues/26).

To fix this, I had to modify the `build.sbt` file in Sidewalk. These changes aren't reflected in this repository since SidewalkWebpage is part of the `.gitignore` file. I haven't tried integrating this change into the Sidewalk repository that is on my computer that isn't running on Docker yet.

This is the updated code for `build.sbt`:
```
resolvers ++= Seq(
  "geosolutions" at "http://maven.geo-solutions.it/",
  "boundlessgeo" at "https://repo.boundlessgeo.com/main/org/"
)

libraryDependencies ++= Seq(
  jdbc,
  (...etc...)
  "javax.media" % "jai_core" % "1.1.3" from "http://maven.geomajas.org/nexus/content/groups/public/javax/media/jai-core/1.1.3",
  "javax.media" % "jai_codec" % "1.1.3" from "http://maven.geomajas.org/nexus/content/groups/public/javax/media/jai_codec/1.1.3",
  "javax.media" % "jai_imageio" % "1.1" from "http://maven.geomajas.org/nexus/content/groups/public/javax/media/jai_imageio/1.1",
  "org.geotools" % "gt-coverage" % "14.3",
  "org.geotools" % "gt-epsg-hsql" % "14.3",
  "org.geotools" % "gt-geotiff" % "14.3",
  "org.geotools" % "gt-main" % "14.3",
  "org.geotools" % "gt-referencing" % "14.3" exclude("javax.media", "jai_core")
).map(_.force())
```

### Add database url in `/conf/application.conf`
This line allows the website service to connect with the Postgres database. The location `db.default.url` is based off an environment variable that is the `docker-compose.yml` file. A more detailed writeup of the initial issue is [here](https://github.com/aileenzeng/sidewalk-docker/issues/8). 

This is the updated code in `application.conf`. This can go below the `db.default.url` that already exists for `localhost:5432`. 

```
# This is for docker.
# Pulls the from the DOCKER_DB environment variable from the compose file.
db.default.url="jdbc:postgresql://"${?DOCKER_DB}"/sidewalk"
```
