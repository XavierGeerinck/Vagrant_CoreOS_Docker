# Pull base image.
FROM dockerfile/ubuntu

# ###############################
#        NODEJS & NPM SETUP
# https://github.com/dockerfile/nodejs
# ###############################

#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get clean
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get -y install python python-software-properties git build-essential libssl-dev curl ca-certificates wget
RUN apt-get -y install nodejs

# Expose ports.
EXPOSE 80
EXPOSE 443
EXPOSE 8080

# Start bash shell
CMD ["bash"]
