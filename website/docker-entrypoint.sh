#!/bin/bash
echo "I am the entrypoint!!"
grunt concat & grunt concat_css & sbt run
