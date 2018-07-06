#!/bin/bash
echo "I am the entrypoint!!"
npm install
grunt concat & grunt concat_css & sbt run
