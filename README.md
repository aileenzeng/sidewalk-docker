NOTE: this `README` is mostly a brain dump of information to help me keep track of different thoughts I've had since starting to work with docker.

# Documentation:
1. Install Docker. I am using the Community Edition, version 18.03.1 (although having the exact same version is probably less important). The download link is [here](https://store.docker.com/search?type=edition&offering=community). You can check to see if Docker is running by typing `docker --version`. 
1. Clone the Project Sidewalk repository into the `website` folder of this directory. Check out the `593-sidewalk-docker` branch.
2. Obtain a database dump. Name it `sidewalk.sql` and place it into the `resources` folder.
3. Run `docker-compose build` in the project's root directory. This builds all the `Dockerfiles` in each service.
4. Run `docker-compose up -d db`. You may need to run this twice (?) until the message says '`Starting sidewalk-docker_db_1 ... done`'. (For some reason, `docker-compose up` isn't working?)
5. Run `docker exec -it sidewalk-docker_db_1 su - postgres -c "createdb -T template0 sidewalk"` then `docker exec -it sidewalk-docker_db_1 su - postgres -c "pg_restore -d sidewalk docker-entrypoint-initdb.d/sidewalk.sql"`. This step may take a while. Once this step is complete, there will be a message that says "Warning: 2 errors after pg_restore" - this is normal!
6. After the database is created, run `docker-compose up`. (If this doesn't work, maybe try `docker-compose up --force-recreate`)

## Current tasks
1. See if there is a way to speed up website loading times. (Sometimes takes 2-3 minutes, even after the first build)
2. Streamline the database setup process
3. Create volumes for the database and website.
4. Try setting up Sidewalk on different computers

This may help streamline the process later on? I haven't done a full setup with the database with these commands yet.
These commands could also probably be put into the `docker-compose.yml` file.

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
### Fix dependencies in `/build.sbt`
`javax.media#jai_core;1.1.3!jai_core.jar` is missing from the [Maven repository](http://repo1.maven.org/maven2/javax/media/jai_core/1.1.3/). This causes problems when `sbt compile` or `sbt run` is being built. A more detailed writeup of this issue is [here](https://github.com/aileenzeng/sidewalk-docker/issues/5). I can't figure out why these commands work when I build Sidewalk on my own computer. 

To fix this, I had to modify the `build.sbt` file in Sidewalk. These changes aren't reflected in this repository since SidewalkWebpage is part of the `.gitignore` file. I haven't tried integrating this change into the Sidewalk repository that is on my computer that isn't running on Docker yet.

This is the updated code for `libraryDependencies` in `build.sbt`:
```
libraryDependencies ++= Seq(
  jdbc,
  (...etc...)
  "javax.media" % "jai_core" % "1.1.3" from "http://download.osgeo.org/webdav/geotools/javax/media/jai_core/1.1.3/jai_core-1.1.3.jar",
  "javax.media" % "jai_codec" % "1.1.3" from "http://download.osgeo.org/webdav/geotools/javax/media/jai_codec/1.1.3/jai_codec-1.1.3.jar",
  "javax.media" % "jai_imageio" % "1.1" from "http://download.osgeo.org/webdav/geotools/javax/media/jai_imageio/1.1/jai_imageio-1.1.jar",
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
