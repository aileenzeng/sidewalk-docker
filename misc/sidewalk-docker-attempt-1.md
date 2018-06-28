This is the error that I get when I build the image using the (existing) attempt.

```
Aileens-MacBook-Pro:SidewalkWebpage aileen$ docker build -t sidewalk/web-app .
Sending build context to Docker daemon  462.1MB
Step 1/34 : FROM ubuntu:16.04
 ---> 5e8b97a2a082
Step 2/34 : RUN apt-get update
 ---> Using cache
 ---> 6c9a49b47206
Step 3/34 : RUN export DEBIAN_FRONTEND=noninteractive
 ---> Using cache
 ---> 602a7797995f
Step 4/34 : RUN apt-get -y install software-properties-common
 ---> Using cache
 ---> 9c5ef7c49245
Step 5/34 : RUN apt-get install -y sudo && rm -rf /var/lib/apt/lists/*
 ---> Using cache
 ---> 35404e1bad42
Step 6/34 : RUN add-apt-repository ppa:webupd8team/java
 ---> Using cache
 ---> 70fd8561b3de
Step 7/34 : RUN apt-get update
 ---> Using cache
 ---> 020ee7d9d79c
Step 8/34 : RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
 ---> Using cache
 ---> fec01c36d7ed
Step 9/34 : RUN apt-get install -y oracle-java8-installer
 ---> Using cache
 ---> 24d304e940d5
Step 10/34 : RUN apt-get install zip unzip
 ---> Using cache
 ---> 6e95d8246735
Step 11/34 : RUN apt-get install -y build-essential checkinstall
 ---> Using cache
 ---> 1a7746efcf2d
Step 12/34 : RUN apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
 ---> Using cache
 ---> 5128db7feb6c
Step 13/34 : WORKDIR /usr/src
 ---> Using cache
 ---> 3bcfab0c535c
Step 14/34 : RUN wget https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz && tar xzf Python-2.7.14.tgz
 ---> Using cache
 ---> 7f5bcdadc78b
Step 15/34 : WORKDIR /usr/src/Python-2.7.14
 ---> Using cache
 ---> 287121c32374
Step 16/34 : RUN ./configure
 ---> Using cache
 ---> b1eff8a636de
Step 17/34 : RUN make install
 ---> Using cache
 ---> 524e8ea439dd
Step 18/34 : RUN apt-get install -yq curl git nano
 ---> Using cache
 ---> 44df0222d088
Step 19/34 : ENV PROJECT_HOME /home/docker
 ---> Using cache
 ---> e3546226dd97
Step 20/34 : WORKDIR $PROJECT_HOME
 ---> Using cache
 ---> 90bb4ad27594
Step 21/34 : RUN mkdir -p $PROJECT_HOME/envt $PROJECT_HOME/app
 ---> Using cache
 ---> 26a0910b486c
Step 22/34 : WORKDIR $PROJECT_HOME/envt
 ---> Using cache
 ---> 7982e0e619ae
Step 23/34 : RUN mkdir -p $PROJECT_HOME/envt/npm_install
 ---> Using cache
 ---> 3877b76e3c07
Step 24/34 : RUN wget https://github.com/sbt/sbt/releases/download/v1.1.0/sbt-1.1.0.zip && unzip sbt-1.1.0.zip
 ---> Using cache
 ---> 6962e2bcf299
Step 25/34 : RUN wget https://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12.zip && unzip typesafe-activator-1.3.12.zip
 ---> Using cache
 ---> b14abc6245f7
Step 26/34 : RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo bash - && apt-get install -yq nodejs
 ---> Using cache
 ---> 10fd5abbb774
Step 27/34 : RUN npm install -g npm
 ---> Using cache
 ---> f90e704c2b45
Step 28/34 : ENV PATH $PROJECT_HOME/envt/activator-dist-1.3.12/bin:$PROJECT_HOME/envt/sbt-1.1.0/bin:$PATH
 ---> Using cache
 ---> 73e3f92c7622
Step 29/34 : COPY . $PROJECT_HOME/app
 ---> 7b5ac2aaa571
Step 30/34 : RUN npm install -g grunt-cli
 ---> Running in 7209b5ea77d4
/usr/lib/node_modules/npm/bin/npm-cli.js:79
      let notifier = require('update-notifier')({pkg})
      ^^^

SyntaxError: Block-scoped declarations (let, const, function, class) not yet supported outside strict mode
    at exports.runInThisContext (vm.js:53:16)
    at Module._compile (module.js:373:25)
    at Object.Module._extensions..js (module.js:416:10)
    at Module.load (module.js:343:32)
    at Function.Module._load (module.js:300:12)
    at Function.Module.runMain (module.js:441:10)
    at startup (node.js:140:18)
    at node.js:1043:3
The command '/bin/sh -c npm install -g grunt-cli' returned a non-zero code: 1
```