# Source: https://hub.docker.com/r/ysihaoy/scala-play/
# Some of the intermediate lines are removed -- I don't think they're important for our purposes

FROM anapsix/alpine-java:jdk8
MAINTAINER Tianhao Li <ysihaoy@gmail.com>

ENV SBT_VERSION 0.13.15
ENV CHECKSUM 18b106d09b2874f2a538c6e1f6b20c565885b2a8051428bd6d630fb92c1c0f96

# Install sbt
RUN apk add --update bash curl openssl ca-certificates && \
  curl -L -o /tmp/sbt.zip \
    https://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.zip && \
  openssl dgst -sha256 /tmp/sbt.zip \
    | grep ${CHECKSUM} \
    || (echo 'shasum mismatch' && false) && \
  mkdir -p /opt/sbt && \
  unzip /tmp/sbt.zip -d /opt/sbt && \
  rm /tmp/sbt.zip && \
  chmod +x /opt/sbt/sbt/bin/sbt && \
  ln -s /opt/sbt/sbt/bin/sbt /usr/bin/sbt && \
  rm -rf /tmp/* /var/cache/apk/*

RUN apk add --update nodejs

# NOTE: I haven't used the Activator UI, so I'm not sure if this is necessary
# Expose 8888 for the Activator UI
EXPOSE 8888

# Expose 9000 to run locally
EXPOSE 9000

# Install grunt and npm dependencies
RUN npm install -g grunt-cli
RUN npm install grunt

# Create working directory
WORKDIR /root/app

# Copy ivy2 and misc jar caches
COPY ./cache/ /root/

# Copy code
COPY ./SidewalkWebpage /root/app/
COPY ./docker-entrypoint.sh /root/app/

# Compiles Scala sources and downloads dependencies. If needed, this line could be changed to 
# RUN (sbt compile || sbt compile || sbt compile). 
# This gives scala 3 tries to compile sources, in case there are network connectivity issues
# RUN sbt compile

RUN npm install
RUN grunt concat
RUN grunt concat_css
RUN sbt compile

#$CMD ["sbt"]
#ENTRYPOINT ["/root/app/docker-entrypoint.sh"]
ENTRYPOINT ["sbt"]
CMD ["run"]


