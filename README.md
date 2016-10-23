# do-web-mongo-bootstrap

Creates DigitalOcean droplets using docker-machine, using simple shell scripts. No crazy environment setup or crazy configurability. This simply sets up mongodb and a docker image running your web application.

Tested on Ubuntu 16.04, should work fine on any Linux or Mac (not sure about Windows).

This is probably not as secure as it should be for a real production web application. However, it should serve as a great starting point for a docker-based web app project deployed on DigitalOcean.

## Prerequisites

Install docker-machine, you'll need a DigitalOcean account and personal API token.

* Set environment variable for `DOTOKEN` (your personal API token at DigitalOcean))
* Set environment variables for `QUAYUSER` and `QUAYTOKEN` if your Docker image is hosted at Quay.io (hub.docker.com if not specified).
* Set environment variables for `DDTOKEN` to setup basic Datadog monitoring.

## Usage for `create.sh`

`create.sh` is just a collection of calls to the other `*.sh` scripts. Any individual script can be used to complete individual steps. Consider `create.sh` a "quick start", and practical documentation for the other scripts.

* Uses smallest DigitalOcean instance sizes...edit if you want to pay more.
* Specifies local `~/.ssh/id_rsa.pub` for `ssh_key` when creating droplets (creates key in DO as well)). This means you can use `docker-machine ssh WEB_NAME|MONGO_NAME` or `ssh WEB_NAME|MONGO_NAME`, implictly using `ssh`.
* Tags all instances with `TAG` to keep your droplet list organized.
* Runs `apt update && apt upgrade` on all new droplets.
* Creates mongodb droplet (currently with Ubuntu 14.04), restores from `DUMP` folder.
* Creates secure communication between web application and mongodb.
  * Uses private networking and `ufw` rules to secure mongodb.
  * Secures mongodb to only accept requests on private network from web host.
  * Caveat: uses no password on mongodb.
* Creates docker Ubuntu 16.04 droplet, installs `DOCKER_IMAGE`.
* *Assumes port 8080* running docker image, maps to port 80 on droplet.
* *Assumes* your docker image looks for `MONGO_HOST` as an environment variable
* Uses `centurylink/watchtower` to automagically update your `DOCKER_IMAGE`.

``` bash
create.sh REGION MONGO_NAME WEB_NAME DOCKER_IMAGE DUMP_FOLDER DB_NAME TAG
```

``` bash
./create.sh "fra1" "mongo-1" "web-1" "quay.io/user/docker-image" "~/dump/my_db/*" "db_name" "cool-tag"
```

## Usage for `update_domain.sh`

If you have DNS hosting with DigitalOcean, run this script to update the hostname for the docker droplet you created with docker-machine.

``` bash
./update_domain.sh "@" "mywebsite.com" "web-1"
```

## TODO

* Datadog app/db-specific monitoring
* Maybe use `docker-compose` for more deploy flexibility.
* Production-level security configuration.
  * Don't use root on droplets for docker etc.
* Support for `https`.
* Add HAProxy for load balancing.
  * Listen to private IP for web app server(s).
* Varnish for caching.
* Add extra web application hosts behind load balancer.
  * Autoscaling would be nice.
* Geodistributed servers with geodns and mongo replication would be really nice.
