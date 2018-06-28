# Documentation:
1. Clone the Project Sidewalk repository into the `website` folder of this directory.
2. Obtain a database dump. Name it `sidewalk.sql` and place it into the `resources` folder.
3. Run `docker-compose build`. This builds all the `Dockerfiles` in each service.
4. Run `docker-compose up -d db`. You may need to run this twice (?) until the message says '`Starting sidewalk-docker_db_1 ... done`'. (For some reason, `docker-compose up` isn't working?)
5. Run `docker exec -it sidewalk-docker_db_1 su - postgres`. Then, type in `createdb -T template0 sidewalk` and `pg_restore -d sidewalk docker-entrypoint-initdb.d/sidewalk.sql`. 

## Work in Progress
This gets the website to run (not correctly!)
```
cd website
docker build . -t sidewalk-docker_website
docker run -it -p 9000:9000 -name sidewalk-docker_website sidewalk-docker_website
```

`docker-compose up` does not work yet. 

## To check
Alternate setup commands in Step 5:
```
docker exec -it sidewalk-docker_db_1 su - postgres -c "createdb -T template0 sidewalk"
docker exec -it sidewalk-docker_db_1 su - postgres -c "pg_restore -d sidewalk docker-entrypoint-initdb.d/sidewalk.sql"
```

This may help streamline the process later on? I haven't done a full setup with the database with these commands yet.

# Helpful commands:
To check what the state of the database is, run `docker exec -it sidewalk-docker_db_1 psql -U sidewalk` to enter the interactive postgres container.
- `\du` to show all users.
- `\dt` to show all relations.
- `\q` to exit. 

`docker-compose run db bash` lets you run an interactive terminal to see what is happening in the `db` service. 

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
`javax.media#jai_core;1.1.3!jai_core.jar` is missing from the [Maven repository](http://repo1.maven.org/maven2/javax/media/jai_core/1.1.3/). This causes problems when `sbt compile` or `sbt run` is being built. A more detailed writeup of this issue is [here](https://github.com/aileenzeng/sidewalk-docker/issues/5). I can't figure out why these commands work when I build Sidewalk on my own computer. 

To fix this, I had to modify the `build.sbt` file in Sidewalk. These changes aren't reflected in this repository since SidewalkWebpage is part of the `.gitignore` file. I haven't tried integrating this change into the Sidewalk repository that is on my computer that isn't running on Docker yet.

This is the updated code for `libraryDependencies`:
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
