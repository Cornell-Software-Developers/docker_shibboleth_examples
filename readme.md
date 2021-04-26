# Shibboleth container examples

## About

[CUWebLogin/CUWebAuth is being retired in September 2021](https://it.cornell.edu/websso/cuweblogincuwebauth-retirement). 
The goal of this repo is to get ahead of the deadline and get a working demo into the community.  This repo uses Docker and counts on your having docker and docker-compose available.  It has not been tested directly on docker for windows or docker for mac, but pull requests appreciated.

This project was extracted from an SSIT project.  Hat tip to Mike for getting this started.  If there's any cruft or left overs that don't make sense in context, that's why.  Pull requests are welcome.

## Getting started

You should be sure you have docker and docker-compose working.  Most of the instructions are for shell, but it's heavily scripted, so you'll probably be fine.  If you're familiar with git clone, etc, skip this first code block and meet us in the second with this repo as your pwd.

```bash
# start by going to your projects directory, wherever that may be

cd ~/code/

# clone this repo and cd into that directory

git clone https://github.com/Cornell-Software-Developers/docker_shibboleth_examples.git

cd docker_shibboleth_examples
```

### project init
This project makes light use of a `.env` file and includes a dist version.  `cp .env.dist .env`.  There's no need to edit the dist version when starting out.

This project also uses a ./go.sh script to automate some common tasks.  If you're more comfortable with docker compose, you can use the normal commands instead of the wrapper script.

```
# Set up self signed ssl certs, shibboleth certs, etc.

./go.sh init
# This step starts by pulling an ubuntu container and generating your shibboleth certs
# you should see docker pull messages followed by apt-get messages, then many `.` and `+` characters.
# when finished, it will print "Done"
```

you'll also want to add dev.local to your hosts file.  On most systems this will take root or admin privileges.

On linux/osx, `sudo nano /etc/hosts`.  Add the line `127.0.0.1 dev.local` at the bottom. Save and exit.

That should take care of almost all of your setup.

### Running shibboleth containers

```
./go.sh build # shortcut for docker-compose build
./go.sh run # shortcut for docker-compose run.  Accepts arguments.
```

At this point, you should have 4 docker containers running.  Open a browser and visit dev.local.  You should expect a security warning because you're using self signed certificates.  This is normal and isn't a problem for you in development.

Once you accept the self signed certificate, you will get redirected to the TEST version of the shibboleth IDP.  Here, you can log in with your normal cornell credentials.  You'll then be sent back to dev.local where you should see your netid as REMOTE_USER.


### Architecture



























