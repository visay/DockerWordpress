# DockerWordpress helps you developing Wordpress projects

DockerWordpress creates the necessary Docker containers (webserver, database, php, mail, redis, elasticsearch, couchdb)
to run your Wordpress project. The package provides a wrapper script in `vendor/bin/dockerwordpress` which simplifies
the handling of docker and does all the configuration necessary.

We created this package to make development on Wordpress projects easier and to create a simple reusable package which
can easily be maintained and serves well for the standard project.

Development will continue further as the package is already reused in several projects.
Contributions and feedback are very welcomed.

## Install docker

    https://docs.docker.com/installation/ (tested with docker v17.03)

## Install docker-compose

We use docker-compose to do all the automatic configuration:

    http://docs.docker.com/compose/install/ (tested with docker-compose v1.12)

The repository contains a Dockerfile which will automatically be built in the
[docker hub](https://registry.hub.docker.com/u/visay/dockerwordpress/) after each change and used by docker-compose
to build the necessary containers.

## Install dockerwordpress into your distribution

Add `visay/dockerwordpress` as dev dependency in your composer.

*Example*:

```
composer require --dev visay/dockerwordpress dev-master
```

*Note*:

DockerWordpress uses port 80 for web access so you need to make sure that your host machine does not have any software
using that port. Usually this happens if you have apache or nginx installed in your host machine, so you can stop it with:

```
sudo service apache2 stop
sudo service nginx stop
```

## Run dockerwordpress

    vendor/bin/dockerwordpress up -d

The command will echo the url with which you can access your project. Add the hostname then to your `/etc/hosts`
and set the ip to your docker host (default for linux is 0.0.0.0). You can also use any subdomain with *.hostname and
it will point to the same server. What you need to do is to add exact subdomain name to your `/etc/hosts`.
The parameter `-d` will keep it running in the background until you run:

    vendor/bin/dockerwordpress stop

The default database configuration for your `wp-config.php` is:

    <?php

    ## Database connection
    define('DB_NAME', 'dockerwordpress');
    define('DB_USER', 'root');
    define('DB_PASSWORD', 'root');
    define('DB_HOST', 'db');

Also note that there is a second database `dockerwordpress_test` available for your testing context.
The testing context url would be `test.hostname` and this hostname should be added to your `/etc/hosts` too.

## Check the status

    vendor/bin/dockerwordpress ps

This will show the running containers. The `data` container can be inactive to do it's work.

# Tips & Tricks

## Configure remote debugging from your host to container

DockerWordpress installs by the default xdebug with the following config on the server:

    xdebug.remote_enable = On
    xdebug.remote_host = 'dockerhost'
    xdebug.remote_port = '9001'
    xdebug.max_nesting_level = 500

So you can do remote debugging from your host to the container through port 9001. From your IDE, you need to configure
the port accordingly.

## Running a shell in one of the service containers

    vendor/bin/dockerwordpress run SERVICE /bin/bash

SERVICE can currently be `app`, `web`, `data`, `db`, `redis`, `elasticsearch` or `couchdb`.

## Access project url when inside `app` container

As of current docker doesn't support bi-directional link, you cannot access web container from app container.
But in some case you will need this connection. For example in behat tests without selenium, you need the url of
your site in `Testing` context while running the tests has to be done inside the `app` container.

DockerWordpress adds additional script after starting all containers to fetch the IP address of web container and
append it to `/etc/hosts` inside app container as below:

```
WEB_CONTAINER_IP    project-url
WEB_CONTAINER_IP    test.project-url
```

You need to define the default test suite url in your `behat.yml` to use `http://test.project-url` and then you can
run the behat tests without having to connect external selenium server

```
vendor/bin/dockerwordpress run app vendor/bin/behat -c Path/To/Your/Package/Tests/Behaviour/behat.yml
```

## Access database inside container from docker host

While you can easily login to shell of the `db` container with `vendor/bin/dockerwordpress run db /bin/bash`
and execute your mysql commands, there are some cases that you want to run mysql commands directly
from your host without having to login to the `db` container first. One of the best use cases,
for example, is to access the databases inside the container from MySQL Workbench tool.
To be able to do that, we have mapped database port inside the container (which is `3306`) to your
host machine through `3307` port.

![Screenshot of MySQL Workbench interface](/docs/MySQL-Workbench.png "MySQL Workbench interface")

## Access CouchDB

From your host machine, you can access couchdb from web interface or command line:

__Web__: [http://0.0.0.0:5984/_utils/](http://0.0.0.0:5984/_utils/)

__Cli__: `curl -X GET http://0.0.0.0:5984/_all_dbs`

From inside your `app` container, you can also access couchdb through the command line:

```
vendor/bin/dockerwordpress run app /bin/bash
curl -X GET http://couchdb:5984/_all_dbs
```

## Attach to a running service

Run `vendor/bin/dockerwordpress ps` and copy the container's name that you want to attach to.

Run `docker exec -it <containername> /bin/bash` with the name you just copied.
With this you can work in a running container instead of creating a new one.

## Check open ports in a container

    vendor/bin/dockerwordpress run SERVICE netstat --listen

## Wordpress CLI included

From v1.0.1 we support the WordPress CLI. The installation of WordPress CLI must be done on your composer level.
Your WordPress composer should look like:

```
	"require": {
		"wp-cli/wp-cli" : "~1.1"
	},
```

In order to execute WordPress CLI command first to need to access to the App container

```
vendor/bin/dockerwordpress run app /bin/bash
# check the WP CLI
wp --info
```

More detail about [Worpress CLI](http://wp-cli.org/)

# Further reading

* [blog post on php-fpm](http://mattiasgeniar.be/2014/04/09/a-better-way-to-run-php-fpm/)
* [Docker documentation](http://docs.docker.com/reference/builder/)
* [docker-compose documentation](http://docs.docker.com/compose)
