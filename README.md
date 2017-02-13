Docker Mautic Image
===================
# License

Mautic (and this Docker Recipe) is distributed under the GPL v3 license. Full details of the license can be found in the [Mautic GitHub repository](https://github.com/mautic/mautic/blob/staging/LICENSE.txt).

# How to use this image

1. you need a Docker host configured to use both a current Docker and Docker Compose with network access and git installed.  

1. make sure you have a MySQL or MariaDB running either on your Docker host, or in a container

1. clone this repo: 
`git clone git@github.com:oeru/docker-mautic.git`
which will, by default, create a directory called 'docker-mautic'

1. create a local docker-compose.yml by copying docker-compose.yml-sample:
`cd docker-mautic`
`cp docker-compose.yml-sample docker-compose.yml`
and the edit the file to specify the details of your MySQL or MariaDB database. You need to specify a user who has the ability to create a database. Also, if you're running an nginx container, you can tweak the ports assignments to make it publicly visible (I encourage defaulting to SSL!).

If you're running MySQL or MariaDB in another container, add another stanza to this yml file to describe it and link it with the mautic stanza!

    mautic:
	  image: kiwilightweight/mautic
	  links:
	    - mauticdb:mysql
	  ports:
	    - ...
    mauticdb:
	  image: mariadb
	

1. adjust the nginx "default.conf" (replace it with "ssl.conf" if you want to offer secure hosting!) and set up the path to your repo in the yml file so that the nginx container can find the conf file.

1. you also need to create a directory on your Docker host for your Mautic code, and reference it in the yml file. 

1. then run 
`docker-compose up` 
to pull (if necessary) and run your mautic (and, if you're using it) your nginx container. If you're running it locally, access it via `http://localhost:8083` in a browser.

1. Run `docker-compose up`, wait for it to initialize completely, and visit `http://localhost:8080` or `http://host-ip:8080`.

# Supported Docker versions

This has been tested on Docker 1.13.1

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/oeru/docker-mautic/issues). We will endeavour to assist, although we're doing this through enlightened self-interest, so can't provide any guarantees!
