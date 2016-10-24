# do-web-mongo-bootstrap

This simply sets up 2 droplets on DigitalOcean:
* A mongodb, restored with your dump. Mongodb runs natively (not in Docker), but it's created with docker-machine so you can control it easy, and add dockers to it.
* A docker image running your web application.

Creates DigitalOcean droplets using docker-machine, using simple shell scripts. This is not super configurable, and doesn't use any fancy Ansible/Terraform/etc tools...call me old-fashioned, but bash scripts tend to last.   

Tested on Ubuntu 16.04, should work fine on any Linux or Mac (not sure about Windows).

This is probably not as secure as it should be for a real production web application. However, it should serve as a great starting point for a docker-based web app project deployed on DigitalOcean.

## Prerequisites

Install docker engine & docker-machine, you'll need a DigitalOcean account and personal API token.

* Set environment variable for `DOTOKEN` (your personal API token at DigitalOcean))
* Set environment variables for `QUAYUSER` and `QUAYTOKEN` if your Docker image is hosted at Quay.io (hub.docker.com if not specified).
* Set environment variables for `DDTOKEN` to setup basic Datadog monitoring.

## Configuration file

Copy `sample.cfg` to `default.cfg` and modify values for your own use. Scripts starting with `_` (e.g. `_create.sh` and `_restore.sh`) read from `default.cfg`. 

## Creating droplets with `_create.sh`

`_create.sh` is just a collection of calls to the other `*.sh` scripts. Any individual script can be used to complete individual steps. Consider `_create.sh` a "quick start", and practical documentation for the other scripts.

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
./_create.sh
```

## Usage for `update_domain.sh`

If you have DNS hosting with DigitalOcean, run this script to update the hostname for the docker droplet you created with docker-machine.

``` bash
./update_domain.sh "@" "mywebsite.com" "web-1"
```

## TODO

* Add HAProxy for load balancing.
  * Relay to private IP for web app server(s).
  * Script to add web app instances behind HAProxy.
* Add floating IP configuration.
* Classier bash parameter handling, more config-driven scripts.
* Datadog app/db-specific monitoring.
* Maybe use `docker-compose` for more deploy flexibility.
* Production-level security configuration.
  * Don't use root on droplets for docker etc.
* Support for `https`.
 Varnish for caching.
* Add extra web application hosts behind load balancer.
  * Autoscaling would be nice.
* Geodistributed servers with geodns and mongo replication would be really nice.

## Contributing

PR from your fork, as usual. You might want to ping me on Twitter @jharmn, as I get too many Github notifications.
