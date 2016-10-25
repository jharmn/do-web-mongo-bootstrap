# do-web-mongo-bootstrap

A collection of simple bash scripts for creating droplets on DigitalOcean with `docker-machine`. Currently focused on `mongodb` for the database.

This simply sets up 2 droplets on DigitalOcean:
* A `mongodb` droplet, restored with your dump. Mongodb runs natively (not in Docker), but it's created with docker-machine so you can control it easy, and add dockers to it.
* A docker image running your web application.

Creates DigitalOcean droplets using docker-machine, using simple shell scripts. This is not super configurable, and doesn't use any fancy Ansible/Terraform/etc tools...call me old-fashioned, but bash scripts tend to last.   

Tested on Ubuntu 16.04, should work fine on any Linux or Mac (not sure about Windows).

This is probably not as secure as it should be for a real production web application. However, it should serve as a great starting point for a docker-based web app project deployed on DigitalOcean.

## Prerequisites

Install docker engine & docker-machine, you'll need a DigitalOcean account and personal API token.

* Set environment variable for `DOTOKEN` (your personal API token at DigitalOcean))
* Set environment variables for `QUAYUSER` and `QUAYTOKEN` if your Docker image is hosted at Quay.io (hub.docker.com if not specified).
* Set environment variables for `DDTOKEN` to enable basic Datadog monitoring.

## Configuration file

Copy `sample.cfg` to `default.cfg` and modify values for your own use. As it stands, all keys in `sample.cfg` must be provided. The majority of the scripts read from this file.

## Creating droplets with `_create.sh`

`_create.sh` is simply a collection of calls to the other `*.sh` scripts. Any individual script can be used to complete individual steps. Consider `_create.sh` a "quick start", and practical documentation for the other scripts.

* Specifies local `~/.ssh/id_rsa.pub` for `ssh_key` when creating droplets (creates key in DO account as well)). This means you can use `docker-machine ssh WEB_NAME|MONGO_NAME` or `ssh WEB_NAME|MONGO_NAME`, implictly using `ssh`.
* Tags all instances with `TAG` to keep your droplet list organized.
* Runs `apt update && apt upgrade` on all new Ubuntu-based droplets.
* Creates "mongodb" droplet (currently uses Ubuntu 14.04 per DO), restores from `DUMP_FOLDER` folder.
* Creates secure communication between web application and mongodb.
  * Uses private networking and `ufw` rules to secure mongodb.
  * Secures mongodb to only accept requests on private network from web host.
  * Caveat: uses no password on mongodb.
* *Assumes port 8080* running docker image, maps to port 80 on droplet.
* *Assumes* your docker image looks for `MONGO_HOST` as an environment variable
* Uses `centurylink/watchtower` to automagically update your `DOCKER_IMAGE`.
* If `DDTOKEN` is set, a `dd-agent` will be created on all boxes for Datadog basic monitoring.
* Updates floating IP if specified in `.cfg` file (`FLOATING_IP`).

### Usage

``` bash
./_create.sh
```

Or pass a specific `.cfg` file:

``` bash
./_create.sh my-site.cfg
```

## Generic scripts

### Droplet info

`droplet_info.sh` retrieves a single droplet's JSON object. That data can be piped into `droplet_id.sh` (for the DO Droplet ID) or `droplet_internal_ip.sh` (for the internal IP), both of which are not available from `docker-machine` directly.

## TODO

* Add HAProxy for load balancing.
  * Relay to private IP for web app server(s).
  * Script to add web app instances behind HAProxy.
  * Varnish for caching.
* Datadog app/db-specific monitoring.
* Maybe use `docker-compose` for more deploy flexibility.
* Production-level security configuration.
  * Don't use root on droplets for docker etc.
* Support for `https` on the docker web image.
* Add extra web application hosts behind load balancer.
  * Autoscaling would be nice.
* Geodistributed servers with geodns and mongo replication would be really nice.

## Contributing

PR from your fork, as usual. You might want to ping me on Twitter @jharmn, as I get too many Github notifications.
